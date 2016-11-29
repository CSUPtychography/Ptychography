%% create mock data to test phase retrieval algorithm
% This script takes any two images, and creates sub-images with
% less resolution, to act as mock data for ptychography
% magnitude_file is the file you'd like to act as the magnitude
% phase_file is the file you'd like to act as the phase
% r is the radius you'd like to use for the transfer function
% a and b are the coordinates of the subimage to display

%% parameters
magnitude_file = 'cameraman.png';
phase_file = 'lena.png';

r = 64;     % CTF radius in pixels

% coordinates of image to display
a = 2;
b = 2;

% distance between sub-images in k-space in pixels
% this will later be determined by LED spacing, distance, and other things
delta_k_px = r;

%% Import image data

mag = imread(magnitude_file);
phase = imread(phase_file);

% check size
if size(mag) ~= size(phase)
    error('Images are not the same size');
end

% check squareness (?)

%% Prepare imported data

% normalize between 0 and 1 for magnitude,
% and -0.5 to 0.5 for phase
mag2 = double(mag) / 255;
phase2 = double(phase) / 255 - 0.5;

% pack into single phase image
I = mag2 .* exp(1i * 2 * pi * phase2);

%% sub image construction

% perform FFT on I
IF = fftshift(fft2(fftshift(I)));

% preparing variables for transfer function
k_x = r;                                % initial k_x coordinate
[m,n] = size(I);                        % size variables
[X,Y] = meshgrid(1:n,1:m);              % grid of coordinates
Images = cell(floor([m,n] / r - 1));    % initialize cell array
imagesX = 1;                            % initial image index

while(k_x <= m - r);
    k_y = r;            % initial k_y coordinate
    imagesY = 1;        % initial image index
    while (k_y <= n - r);
        % preparing transfer function
        % it's a circle of radius r with center (k_x,k_y)
        CTF = (sqrt((X - k_x).^2 + (Y - k_y).^2) < r);
        % multiply transfer function by FFt'd image
        blurred = CTF .* IF;
        % crop out region of interest
        blurred = blurred(k_x-r+1:k_x+r, k_y-r+1:k_y+r);
        % inverse fourier transform
        sub_image = fftshift(ifft2(fftshift(blurred)));
        % measure intensity
        sub_image = abs(sub_image).^2;
        % store in cell array
        Images{imagesX,imagesY} = sub_image;

        imagesY = imagesY+1;        % increment image index
        k_y = k_y + delta_k_px;     % move center of circle
    end % while
    imagesX=imagesX+1;          % increment image index
    k_x = k_x + delta_k_px;     % move center of circle
end % while

A = Images{a,b};

% display image
figure(1)
image(A)
colormap gray;
title(sprintf('Subimage (%d,%d)',a,b));
