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
y_offset = 0;           % (in meters)
arraysize = 15;         % size of one side of the square of LEDs
No_LEDs = arraysize^2;  % Number of LEDs (should probably be square)

NA_obj = 0.08;          % numerical aperture of the objective

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

%% Calculated parameters

% position of the farthest LED
LED_limit = LED_spacing * (arraysize - 1) / 2;
LED_positions = -LED_limit:LED_spacing:LED_limit;   % list of LED positions
k = 2 * pi / wavelength;    % wavevector magnitude
% lists of transverse wavevectors
kx_list = k * sin(atan((LED_positions + x_offset) / matrix_spacing));
ky_list = k * sin(atan((LED_positions + y_offset) / matrix_spacing));

NA_led = sin(atan(LED_limit / matrix_spacing)); % NA of LEDs
NA_syn = NA_led + NA_obj;   % synthetic numerical aperture

enhancement_factor = 2 * NA_syn / NA_obj;       % resolution increase

% calculate pixel size
oversampling_factor = 1.5;          % how much over Nyquist to sample

% pixel size for sub-images (in meters)
% For the actual setup, this will be determined by the CCD pixel size,
% and magnification factor.
sub_px_size = wavelength / 2 / NA_obj / oversampling_factor;
% pixel size for reconstructed image (in meters)
% can also be determined by sub_px_size / enhancement_factor
rec_px_size = wavelength / 4 / NA_syn / oversampling_factor;

kt_max_sub = 1/sub_px_size; % maximum spatial frequency for sub-image
kt_max_rec = 1/rec_px_size; % for reconstructed image
kt_max_obj = 1 * pi / wavelength * NA_obj;  % for objective

% calculate subimage resolution
[m_r,n_r] = size(I);        % size of reconstructed image
% size of sub images in pixels
m_s = floor(m_r / enhancement_factor);
n_s = floor(n_r / enhancement_factor);

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

% add magnitude and phase source indicators to filename
paramstr = strcat(magnitude_file(1), '_', phase_file(1), '_', paramstr);

filename = strcat('mockim_', paramstr);

%% sub image construction

% perform FFT on I
IF = fftshift(fft2(I));

% preparing variables for transfer function
[kx_g,ky_g] = meshgrid(linspace(-kt_max_rec,kt_max_rec,m_r), ...
    linspace(-kt_max_rec,kt_max_rec,n_r));  % grid of k_t coordinates
[X,Y] = meshgrid(1:n_r,1:m_r);              % grid of coordinates
Images = cell(floor([m_r,n_r] / r - 1));    % initialize cell array
kx_px = r:delta_k_px:n_r-r; % transverse k in pixels
ky_px = r:delta_k_px:m_r-r; % transverse k in pixels

%%
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
