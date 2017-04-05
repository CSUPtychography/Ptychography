function[image] = takephoto(vid,vidsrc)
%prev = preview(vid);
%mbox_preview = msgbox('Preview looks good, click to take photo');
%uiwait(mbox_preview);
image_raw = getsnapshot(vid);
exposure = vidsrc.ExposureTimeAbs;
double_image = double(image_raw);
scaled_double_image = double_image./255;
exp_scaled_double_image = scaled_double_image./exposure;
%mbox_image = msgbox('Camera took a photo,scaled it, and stored it');
%uiwait(mbox_image);
image = exp_scaled_double_image;
end