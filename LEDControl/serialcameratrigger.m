%% setup variables
% folder should be...
% U:\Senior Design\ptychography\LEDControl
% Save the serial port name in comPort variable.
% define variables
%% set variables for size of array
xmin = 0;                           %define starting x for array
ymin = 0;                           %define starting y for array
xmax = 15;                          %define ending x for array
ymax = 15;                          %define ending y for array
x = xmax - xmin;
y = ymax - ymin;
n = x*y;

% optical parameters
wavelength = 600e-9;    % wavelength in meters (different for R,G,B)
LED_spacing = 5e-3;     % Distance between LEDs in meters
matrix_spacing = 70e-3; % Distance from matrix to sample in meters
x_offset = 0;           % Distance from center of matrix to optic axis
y_offset = 0;           % (in meters)
arraysize = 15;         % Number of LEDs in one side of the square
No_LEDs = arraysize^2;  % Total number of LEDs (should probably be square)
NA_obj = 0.08;          % Numerical aperture of the objective
px_size = 2.5e-6;       % Pixel spacing projected onto sample (in meters)

% x = arraysize;
% y = arraysize;
% n = No_LEDs

% serial and camera parameters
trigger = '1';                      %define serial communication trigger
comPort = 'COM6';                   %define serial port (this may change each time)
%res = 1080;                        %define resolution of camera (may not need to do this)
%exp = 2;                           %define exposure time, may need to change conditionally with x and y
%% setup serial
%It creates a serial element calling the function "serialsetup"
%This should only run if the setup has not been completed before
if(~exist('serialFlag','var'))
    [arduino,serialFlag] = serialsetup(comPort);
elseif(exist('cameraFlag','var'))
    ser_setup = msgbox('Serial is already setup','Serial');
    uiwait(ser_setup);
end
%% setup camera
%Creates a camera element, and returns the camera information for the
%attached camera
if(~exist('cameraFlag','var'))
    [vid,cameraFlag] = camerasetup();
elseif(exist('cameraFlag','var'))
    cam_setup = msgbox('Camera is already setup','Camera');
    uiwait(cam_setup);
end  
%% Preview image
preview(vid);
%pause for autoexposure
mbox_preview = msgbox('Preview looks good, begin acquisition','Preview');
uiwait(mbox_preview);
closepreview(vid);
%% if the next part fails, use imaqreset, then delete cameraFlag and re-run
% setup
%% Image Acquisition, storage in cell array in x and y slots

%allimages=LCchat(arduino,xmin,xmax,ymin,ymax,res,exp);
%setup final image array

% create directory to store files
directory = datestr(now,'yyyy-mm-dd_HH-MM-SS');
mkdir(directory);
% format string for image filenames
fileformat = 'image-x%d_y%d';
previewfileformat = 'preview-%dx%d';
fullformat = strcat(directory, '/', fileformat);
previewfullformat = strcat(directory, '/', previewfileformat);
% save parameters in directory
param_filename = strcat(directory, '/parameters');
version = 2;
save(param_filename, 'version', 'fileformat', ...
    'LED_spacing', 'matrix_spacing', 'x_offset', 'y_offset', ...
    'wavelength', 'NA_obj', 'px_size');
%Create Preview Image to Compare reconstruction to
Prev = takephoto(vid);
% save Preview
save(sprintf(previewfullformat,x,y), 'Prev');
%light first led
serialpass(arduino,trigger);
%setup while loop variables
ImageArrayX = 1;
ImageArrayY = 1;
k = 1;
n = x*y;
%for loop
while(k<=x)
    j = 1;
    ImageArrayY = 1;
    while(j<=y) 
       Image = takephoto(vid);
       imagesc(Image);
       colormap gray;
       % save image for memory conservation
       save(sprintf(fullformat,ImageArrayX,ImageArrayY), 'Image');
       %step variables
       ImageArrayY = ImageArrayY + 1;
       j = j + 1;
       %light next LED, pause for autoexposure
       serialpass(arduino,trigger);
       pause(.2)
    end
    ImageArrayX = ImageArrayX + 1;
    k = k + 1;
end
%% run this section to restart image acquisition
fclose(arduino)
clear cameraFlag;
clear serialFlag;
clear vid;
%% End the session
% Clean the drivers off
make clean;
