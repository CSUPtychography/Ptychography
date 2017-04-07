function[image] = takephoto(vid)
%prev = preview(vid);
%mbox_preview = msgbox('Preview looks good, click to take photo');
%uiwait(mbox_preview);
image = step(vid);
exposure = vid.DeviceProperties.ExposureTimeAbs;
% normalize image by exposure, so that all images are equally scaled.
exp_scaled_image = image./exposure;
%mbox_image = msgbox('Camera took a photo,scaled it, and stored it');
%uiwait(mbox_image);
image = exp_scaled_image;
end