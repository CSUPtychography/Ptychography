%% setup variables
% Save the serial port name in comPort variable.
% define variables
x = 1;                              %define starting x for array
y = 1;                              %define starting y for array
xmax = 12;                          %define ending x for array
ymax = 12;                          %define ending y for array
trigger = '1';                      %define serial communication
comPort = '/dev/tty.usbmodem411';   %define serial port (this may change each time)
res = 1080;                         %define resolution of camera (may not need to do this)
exp = 2;                            %define exposure time, may need to change conditionally with x and y
%% setup serial
%It creates a serial element calling the function "serialsetup"
%This should only run if the setup has not been completed before
if(~exist('serialFlag','var'))
    [arduino,serialFlag] = serialsetup(comPort);
end
%% setup camera
%Creates a camera element, and returns the camera information for the
%attached camera
if(~exist('cameraFlag','var'))
    [camstruct,cameraFlag] = camerasetup;
end
    
%% Run the loop
%Calls the function to run the loop, given x and y parameters
allimages=LCchat(arduino,x,xmax,y,ymax,res,exp);
%% Send the images to ptychography
finalimage = ptychography(allimages);
%% End the session
% Clean the drivers off
make clean;
% Close the serial port
fclose(arduino);
