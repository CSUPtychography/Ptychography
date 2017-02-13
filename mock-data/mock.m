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
weak_phase_factor = 0.5;

% coordinates of image to display
a = 2;
b = 2;

% optical parameters
wavelength = 600e-9;    % wavelength in meters (different for R,G,B)
LED_spacing = 5e-3;     % LED spacing in meters
matrix_spacing = 20e-3; % distance from matrix to sample in meters
x_offset = 0;           % distance from center of matrix to optic axis
y_offset = 0;
arraysize = 15;         % size of one side of the square of LEDs
No_LEDs = arraysize^2;  % Number of LEDs (should be square)

NA_obj = 0.08;          % numerical aperture of the objective

% position of the farthest LED
LED_limit = LED_spacing * (arraysize - 1) / 2;
LED_positions = -LED_limit:LED_spacing:LED_limit;   % list of LED positions
k = 2 * pi / wavelength;    % wavevector magnitude
% lists of transverse wavevectors
kx_list = k * sin(atan((LED_positions + x_offset) / matrix_spacing));
ky_list = k * sin(atan((LED_positions + y_offset) / matrix_spacing));

NA_led = sin(atan(LED_limit / matrix_spacing));     % NA of LEDs
NA_syn = NA_led + NA_obj;   % synthetic numerical aperture

scale_factor = NA_syn / NA_obj;     % resolution increase

% distance between sub-images in k-space in pixels
% this will now be determined by LED spacing, distance, and other things
delta_k_px = r;

% handle weak phase
if weak_phase
    % string with parameters for filename
    paramstr = sprintf('r%d_dk%d_weak-phase',r,delta_k_px);
    phase_factor = weak_phase_factor;
else
    paramstr = sprintf('r%d_dk%d',r,delta_k_px);
    phase_factor = 1;
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

I = mag .* exp(1i * 2 * pi * (phase - 0.5) * phase_factor);

%% sub image construction

% perform FFT on I
IF = fftshift(fft2(I));

% preparing variables for transfer function
[m,n] = size(I);                        % size variables
[X,Y] = meshgrid(1:n,1:m);              % grid of coordinates
Images = cell(floor([m,n] / r - 1));    % initialize cell array

kx_px = r:delta_k_px:n-r;   % transverse k in pixels
ky_px = r:delta_k_px:m-r;   % transverse k in pixels

for i = 1:length(kx_px)
    for j = 1:length(ky_px)
        % preparing transfer function
        % it's a circle of radius r with center (kx,ky)
        CTF = (sqrt((X - kx_px(i)).^2 + (Y - ky_px(j)).^2) < r);
        % multiply transfer function by FFt'd image
        blurred = CTF .* IF;
        % crop out region of interest
        blurred = blurred(ky_px(j)-r+1:ky_px(j)+r, kx_px(i)-r+1:kx_px(i)+r);
        % inverse fourier transform
        sub_image = ifft2(ifftshift(blurred));
        % measure intensity
        sub_image = abs(sub_image).^2;
        % store in cell array
        Images{j,i} = sub_image;
    end % ky for
end % kx for

%% display image

figure(1)
image(Images{a,b})
colormap gray;
title(sprintf('Subimage (%d,%d)',a,b));

%% save images
save(filename,'Images');
