function [cam,Flag]=camerasetup
% this function sets up the drivers, finds all connected cameras, sets up
% the camera, and returns the camera information to the main code
make();
available_cams = baslerFindCameras();
cameraIndex = available_cams(1,1);
cam = baslerCameraInfo(cameraIndex);
end