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

% optical parameters
wavelength = 600e-9;    % wavelength in meters (different for R,G,B)
LED_spacing = 5e-3;     % LED spacing in meters
matrix_spacing = 70e-3; % distance from matrix to sample in meters
x_offset = 0;           % distance from center of matrix to optic axis
y_offset = 0;           % (in meters)
arraysize = 15;         % size of one side of the square of LEDs
No_LEDs = arraysize^2;  % Number of LEDs (should probably be square)

NA_obj = 0.08;          % numerical aperture of the objective
min_overlap = 50;       % (%) minimum overlap between adjacent subimages 
oversampling_factor = 1.5;  % how much over Nyquist to sample

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

% check overlap criteria
NA_single_led = sin(atan(LED_spacing / matrix_spacing));
overlap = 100 - NA_single_led / 2 / NA_obj * 100; % sub-aperture percent overlap
if (overlap < min_overlap)
    if (overlap < 0)
        error('Sub-apertures do not overlap. Increase matrix spacing')
    else
        error('Sub-Apertures only overlap by % 3.0f%%. Increase matrix spacing', overlap);
    end % less than zero if
end % overlap if

% calculate pixel size

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

% spatial frequency axes for spectrums of images
kx_axis_sub = linspace(-kt_max_sub,kt_max_sub,m_s);
ky_axis_sub = linspace(-kt_max_sub,kt_max_sub,n_s);
kx_axis_rec = linspace(-kt_max_rec,kt_max_rec,m_r);
ky_axis_rec = linspace(-kt_max_rec,kt_max_rec,n_r);

% grid of spatial frequencies for each pixel of reconstructed spectrum
[kx_g_rec,ky_g_rec] = meshgrid(kx_axis_rec,ky_axis_rec);

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

Images = cell(arraysize);   % initialize cell array

% synthetic_CTF = false(m_r,n_r);

for i = 1:arraysize
    for j = 1:arraysize
        % prepare transfer function
        % it's a circle of radius kt_max_obj with center (kx,ky)
        CTF = ((kx_g_rec - kx_list(i)).^2 ...
            + (ky_g_rec - ky_list(j)).^2) < kt_max_obj^2;
%         imagesc(kx_axis_rec,ky_axis_rec,abs(CTF)); title('CTF');
%         synthetic_CTF = synthetic_CTF | CTF;
        % multiply transfer function by FFt'd image
        blurred = CTF .* IF;
%         imagesc(kx_axis_rec,ky_axis_rec,abs(blurred)); title('blurred');
        % crop out region of interest
        kx_center = round((kx_list(i) + kt_max_rec) ...
            / 2 / kt_max_rec * (m_r - 1)) + 1;
        ky_center = round((ky_list(j) + kt_max_rec) ...
            / 2 / kt_max_rec * (n_r - 1)) + 1;
        kx_low = round(kx_center - (m_s - 1) / 2);
        kx_high = round(kx_center + (m_s - 1) / 2);
        ky_low = round(ky_center - (n_s - 1) / 2);
        ky_high = round(ky_center + (n_s - 1) / 2);
        blurred = blurred(ky_low:ky_high, kx_low:kx_high);
%         imagesc(kx_axis_sub,ky_axis_sub,abs(blurred)); title('blurred');
        % inverse fourier transform
        sub_image = ifft2(ifftshift(blurred));
%         imagesc(abs(sub_image)); title('sub-image');
        % measure intensity
        sub_image = abs(sub_image).^2;
        % store in cell array
        Images{j,i} = sub_image;
    end % ky for
end % kx for

%% save images
save(filename,'Images');
