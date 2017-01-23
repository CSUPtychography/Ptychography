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
weak_phase = true;

% coordinates of image to display
a = 2;
b = 2;

% distance between sub-images in k-space in pixels
% this will later be determined by LED spacing, distance, and other things
delta_k_px = r;

% string with parameters for filename
if weak_phase
    paramstr = sprintf('r%d_dk%d_weak-phase',r,delta_k_px);
else
    paramstr = sprintf('r%d_dk%d',r,delta_k_px);
end % weak phase if

% add magnitude and phase source indicators
paramstr = strcat(magnitude_file(1), '_', phase_file(1), '_', paramstr);

filename = strcat('mockim_', paramstr);

%% Import and normalize image data

mag = normgray(imread(magnitude_file));
phase = normgray(imread(phase_file));

% check size
if size(mag) ~= size(phase)
    error('Images are not the same size');
end

% check squareness (?)

%% Generate Phase Object

I = mag .* exp(1i * 2 * pi * (phase - 0.5));

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
        blurred = blurred(k_y-r+1:k_y+r, k_x-r+1:k_x+r);
        % inverse fourier transform
        sub_image = fftshift(ifft2(fftshift(blurred)));
        % measure intensity
        sub_image = abs(sub_image).^2;
        % store in cell array
        Images{imagesY,imagesX} = sub_image;

        imagesY = imagesY+1;        % increment image index
        k_y = k_y + delta_k_px;     % move center of circle
    end % while
    imagesX=imagesX+1;          % increment image index
    k_x = k_x + delta_k_px;     % move center of circle
end % while

%% display image

figure(1)
image(Images{a,b})
colormap gray;
title(sprintf('Subimage (%d,%d)',a,b));

%% save images
save(filename,'Images');