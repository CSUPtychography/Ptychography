%% setup variables
% folder should be...
% U:\Senior Design\ptychography\LEDControl
% Save the serial port name in comPort variable.
% define variables
%% set variables for size of array
xmin = 1;                           %define starting x for array
ymin = 1;                           %define starting y for array
xmax = 10;                          %define ending x for array
ymax = 11;                          %define ending y for array
x = xmax - xmin;
y = ymax - ymin;
n = x*y;
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
%light LED square (middle 12 most likely)

%pause for autoexposure
mbox_preview = msgbox('Preview looks good, begin acquisition','Preview');
uiwait(mbox_preview);
closepreview(vid);
%% if the next part fails, use imaqreset, then delete cameraFlag and re-run
% setup
%% Image Acquisition, storage in cell array in x and y slots
%THIS WILL RUN OUT OF MEMORY IF RUN TOO MANY TIMES BEFORE CLEARING
    %not running out of memory, when the images aren't stored, it still
    %runs into a problem at 80 loops
%allimages=LCchat(arduino,xmin,xmax,ymin,ymax,res,exp);
%setup final image array

%code to create folder to store images one at a time

ImageArray = cell(x,y);
%light first led

%setup while loop variables
ImageArrayX = 1;
ImageArrayY = 1;
k = 1;
counter = 1
n = x*y;
%for loop
while(k<x+1)
    j = 1;
    ImageArrayY = 1;
    while(j<y+1)
        %build cell array of images
        %ImageArray{ImageArrayY,ImageArrayX} = takephoto(vid,vidsrc);
        %test to see how many times it can loop without storing images
        Image = step(vid);
        %code to store in the folder made above one at a time to save
        %memory.

        %step variables
        ImageArrayY = ImageArrayY + 1;
        j = j + 1;
        counter = counter+1
        %light next LED
        pause(2)
    end
    ImageArrayX = ImageArrayX + 1;
    k = k + 1;
end
%% Send the images as a cell array to file for FPM
%ImageArray = allimages;
%% End the session
% Clean the drivers off
make clean;
% Close the serial port
fclose(arduino);
