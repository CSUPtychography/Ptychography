%% create mock data to test phase retrieval algorithm
% This script takes any two images, and creates sub-images with
% less resolution, to act as mock data for ptychography

%% parameters
magnitude_file = 'cameraman.png';
phase_file = 'lena.png';

weak_phase = true;
weak_phase_factor = 0.5;

% optical parameters
wavelength = 600e-9;    % wavelength in meters (different for R,G,B)
LED_spacing = 4e-3;     % LED spacing in meters
matrix_spacing = 65e-3; % distance from matrix to sample in meters
x_offset = -150e-6;     % distance from center of matrix to optic axis
y_offset = 500e-6;      % (in meters)
arraysize = 15;         % size of one side of the square of LEDs
No_LEDs = arraysize^2;  % Number of LEDs (should probably be square)

NA_obj = 0.12;          % numerical aperture of the objective
min_overlap = 50;       % (%) minimum overlap between adjacent subimages 
oversampling_factor = 1.5;  % how much over Nyquist to sample

%% Generate Phase Object

% Import and normalize image data

mag = normgray(imread(magnitude_file));
phase = normgray(imread(phase_file));

% check size
if size(mag) ~= size(phase)
    error('Images are not the same size');
end

% check squareness (?)

% handle weak phase
if weak_phase
    phase_factor = weak_phase_factor;
else
    phase_factor = 1;
end % weak phase if

% combine into complex object
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

% maximum spatial frequency for sub-image
kt_max_sub = k * NA_obj * oversampling_factor;
% and for reconstructed image
% fuckery to use as much of the complex object as possible. ideally want no
% oversampling on complex object, but subimages need oversampling, and
% using none on object puts subimage's spectrum outside object's spectrum.
% Use synthetic NA plus only the margin needed for subimage oversampling.
% also take matrix offset into account
max_offset = max(abs([x_offset, y_offset]));
NA_matrix = sin(atan((LED_limit + max_offset) / matrix_spacing));
kt_max_rec = k * (NA_matrix + NA_obj * oversampling_factor);
kt_max_obj = k * NA_obj;  % for objective

% calculate pixel size
sub_px_size = pi / kt_max_sub;
rec_px_size = pi / kt_max_rec;

% calculate subimage size
[m_r,n_r] = size(I);        % size of reconstructed image
% size of sub images in pixels
m_s = floor(m_r * kt_max_sub / kt_max_rec);
n_s = floor(n_r * kt_max_sub / kt_max_rec);

% spatial frequency axes for spectrums of images
kx_axis_sub = linspace(-kt_max_sub,kt_max_sub,n_s);
ky_axis_sub = linspace(-kt_max_sub,kt_max_sub,m_s);
kx_axis_rec = linspace(-kt_max_rec,kt_max_rec,n_r);
ky_axis_rec = linspace(-kt_max_rec,kt_max_rec,m_r);

% grid of spatial frequencies for each pixel of reconstructed spectrum
[kx_g_rec,ky_g_rec] = meshgrid(kx_axis_rec,ky_axis_rec);
% same for subimage spectrum
[kx_g_sub,ky_g_sub] = meshgrid(kx_axis_sub,ky_axis_sub);

%% sub image construction

% perform FFT on I
IF = fftshift(fft2(ifftshift(I)));

Images = cell(arraysize);   % initialize cell array

CTF = ((kx_g_sub.^2 + ky_g_sub.^2) < kt_max_obj^2);

for i = 1:arraysize
    for j = 1:arraysize
        % crop out region of interest
        kx_center = round((kx_list(j) + kt_max_rec) ...
            / 2 / kt_max_rec * (n_r - 1)) + 1;
        ky_center = round((ky_list(i) + kt_max_rec) ...
            / 2 / kt_max_rec * (m_r - 1)) + 1;
        kx_low = round(kx_center - (n_s - 1) / 2);
        kx_high = round(kx_center + (n_s - 1) / 2);
        ky_low = round(ky_center - (m_s - 1) / 2);
        ky_high = round(ky_center + (m_s - 1) / 2);
        region = IF(ky_low:ky_high, kx_low:kx_high);
%         imagesc(kx_axis_sub,ky_axis_sub,abs(region)); title('Subregion');
        % multiply transfer function by FFt'd image
        blurred = CTF .* region;
%         imagesc(kx_axis_rec,ky_axis_rec,abs(blurred)); title('blurred');
        % flip
        blurred = flip(flip(blurred,2),1);
        % inverse fourier transform
        sub_image = fftshift(ifft2(ifftshift(blurred)));
%         imagesc(abs(sub_image)); title('sub-image');
        % flop
        sub_image = flip(flip(sub_image,2),1);
        % measure intensity
        sub_image = abs(sub_image).^2;
        % store in cell array
        Images{i,j} = sub_image;
        drawnow;
    end % ky for
end % kx for

%% save data

% Generate filename with parameters
% example filename: mock_ab_1x2_3_4_5_6_7_w50
% a: 1st letter of magnitude filename
% b: 1st letter of phase filename
% 1: height of object in 100s of pixels
% 2: width of object in 100s of pixels
% 3: LED_spacing in mm
% 4: matrix_spacing in cm
% 5: array size (on a side)
% 6: wavelength in 100s of nm
% 7: Numerical aperture in 100ths
% w: indicates weak phase
% 50: phase factor in 100ths if weak phase used

filename = sprintf('mockff_%c%c_%.0fx%.0f_%.0f_%.0f_%d_%.0f_%.0f', ...
    magnitude_file(1), phase_file(1), m_r/100, n_r/100, ...
    LED_spacing*1e3, matrix_spacing*1e2, arraysize, ...
    wavelength*1e7, NA_obj*100);
if weak_phase
    filename = strcat(filename, sprintf('_w%.0f', phase_factor*1e2));
end % filename weak phase if

% save file
version = 1;
rec_size = [m_r,n_r];
px_size = sub_px_size;

save(filename,'version', 'LED_spacing', 'matrix_spacing', ...
    'x_offset', 'y_offset', ...
    'wavelength', 'NA_obj', 'px_size', 'Images');
