clear all;
%% create mock data to test phase retrieval algorithm

%% parameters
magnitude_file = 'cameraman.png';
phase_file = 'lena.png';
r = 16;

%% Import image data

mag = imread(magnitude_file);
phase = imread(phase_file);
% check size and squareness
if size(mag) ~= size(phase)
    error('Images are not the same size');
end

% normalize between 0 and 1 for magnitude,
%   and -0.5 to 0.5 for phase
mag2 = double(mag) / 255;
phase2 = double(phase) / 255 - 0.5;

% pack into single phase image
I = mag2 .* exp(1i * 2 * pi * phase2);

% conserve memory ('cause we're gonna need it)
%% small image construction
% perform FFT on I
IF = fft2(I);

% Create Transfer Function
k = r+1;
TF = zeros(size(mag));
[m,n] = size(mag);
Images = cell(size(mag)/r);
imagesX=1;
while(k < m);
j=r+1;
imagesY=1;
    while (j < n);
    TF(k-r:k+r-1,j-r:j+r-1) = 255;
    Images{imagesX,imagesY} = TF.*IF;
    imagesY = imagesY+1;
    j = j+r;
    TF = zeros(size(mag));
    end
imagesX=imagesX+1;
k=k+r;
end
%% to be done with each segment
A = Images{2,2};
%trim each image
AC = A(A~=0);
%reshape each after trimming
ACR = reshape(AC,2*r,2*r);
%perform ifft2
blur = abs(ifft2(ACR));
%display image
figure ()
image(blur)
colormap(gray(256));
% problem here: will need to make this a circle instead of a rectangle,
% CIRCLE = insertShape(blank,'filled circle',[128 128 8]);   ?
% moving on...

% Measure Intensity

% Save small image in cell array


