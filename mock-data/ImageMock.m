function [blur] = ImageMock(magnitude_file,phase_file,r,a,b)
% This function can be used to take any two images, and create images with
% less resolution, to act as mock data.
% magnitude_file is the file you'd like to act as the magnitude
% phase_file is the file you'd like to act as the phase
% r is the radius you'd like to use for the transfer function
% a is the x coordinate of the location you'd like to have as the output
% b is the y coordinate of the location you'd like to have as the output
% try the following: 
%       ImageMock('cameraman.png','lena.png',32,1,1);
%% create mock data to test phase retrieval algorithm and ptychography Algorithm

%% Import image data

mag = imread(magnitude_file);
phase = imread(phase_file);
% check size and squareness
if size(mag) ~= size(phase)
    error('Images are not the same size');
end
%% Prepare imported data
% normalize between 0 and 1 for magnitude,
% and -0.5 to 0.5 for phase
mag2 = double(mag) / 255;
phase2 = double(phase) / 255 - 0.5;
% pack into single phase image
I = mag2 .* exp(1i * 2 * pi * phase2);
% conserve memory ('cause we're gonna need it)
%% small image construction
% perform FFT on I
IF = fft2(I);
% preparing variables for transfer function
k = r+1;
[m,n] = size(mag);
Images = cell((size(mag)/r)-1);
imagesX=1;
while(k < m);
j=r+1;
imagesY=1;
    while (j < n);
        % preparing transfer function
    TF = zeros(size(mag));
    TF(k-r:k+r-1,j-r:j+r-1) = 255;
        % multiplying transfer function by FFt'd function, and assigning to
        % cell array
    Images{imagesX,imagesY} = TF.*IF;
        % counting through the image
    imagesY = imagesY+1;
    j = j+r;
    end
imagesX=imagesX+1;
k=k+r;
end
%% to be done with each segment
A = Images{a,b};
%trim each image
AC = A(A~=0);
%reshape after trimming zeros
ACR = reshape(AC,2*r,2*r);
%perform ifft2 on fewer pixels to show fft
blur = abs(ifft2(ACR));
%display image
figure ()
image(blur)
colormap(gray(256));
% problem here: will need to make this a circle instead of a rectangle
% possible solution to the transfer function:
% CIRCLE = insertShape(blank,'filled circle',[128 128 8]);
end

