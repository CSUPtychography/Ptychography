function [vid,Flag]=camerasetup()
% this function sets up the drivers, finds all connected cameras, sets up
% the camera, and returns the camera information to the main code
a = imaqhwinfo;
vid = imaq.VideoDevice();

%% anything down here can be changed, optional parameters in comments
vid.DeviceProperties.ExposureAuto = 'Continuous';
vid.ReturnedDataType = 'double';
Flag = 1;
% mbox_cam = msgbox('Camera setup');
% uiwait(mbox_cam)
end
