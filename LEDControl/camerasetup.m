function [vid,vidsrc,Flag]=camerasetup()
% this function sets up the drivers, finds all connected cameras, sets up
% the camera, and returns the camera information to the main code
a = imaqhwinfo;
CON = char(a.InstalledAdaptors);
vid = videoinput(CON);
vidsrc = getselectedsource(vid);
%% anything down here can be changed, optional parameters in comments
vidsrc.ExposureAuto = 'Continuous'; %'Off', 'Once', 'Continuous'
Flag = 1;
mbox_cam = msgbox('Camera setup');
uiwait(mbox_cam)
end