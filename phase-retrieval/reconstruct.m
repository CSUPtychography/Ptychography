%% reconstruction algorithm
% a script to reconstruct phase information 
% from a set of fourier ptychographic images

%% Parameters and constants

filename = '../mock-data/mockim_r64_dk64.mat';

iterations = 5;             % number of iterations

% optical parameters
% not all of these are necessary or desirable, but we will include them all
% now, and remove the unnecessary ones later.

wavelength = 600e-9;    % wavelength in meters (different for R,G,B)
LED_spacing = 5e-3;     % Distance between LEDs in meters
matrix_spacing = 70e-3; % Distance from matrix to sample in meters
x_offset = 0;           % Distance from center of matrix to optic axis
y_offset = 0;           % (in meters)
arraysize = 15;         % Number of LEDs in one side of the square
No_LEDs = arraysize^2;  % Total number of LEDs (should probably be square)

NA_obj = 0.08;          % Numerical aperture of the objective
min_overlap = 50;       % (%) overlap between adjacent subimage apertures
oversampling_factor = 1.5;  % how much over nyquist to sample

%% import images and other data (?)

import = load(filename);

Images = import.Images;
array_dimensions = size(Images);
[m_s,n_s] = size(Images{1});    % size of sub-images

% check if array is square
if (array_dimensions(1) ~= array_dimensions(2))
    error('nonsquare (%d x %d) array is not supported', ...
        array_dimensions(1), array_dimensions(2));
else
    arraysize = array_dimensions(1);
end % array dimension if

%% Calculated parameters

% recalculate LED number just in case
No_LEDs = arraysize^2;  % Total number of LEDs (should probably be square)

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
overlap = 100 - NA_single_led / 2 / NA_obj * 100; % sub-aperture % overlap
if (overlap < min_overlap)
    if (overlap < 0)
        error('Sub-apertures do not overlap. Increase matrix spacing');
    else
        error('Sub apertures only overlap by % 3.0f%%. Increase matrix spacing.', overlap);
    end % less than zero if
end % overlap if

% maximum spatial frequency for sub-image
kt_max_sub = k * NA_obj * oversampling_factor;
% and for reconstructed image
kt_max_rec = k * 2 * NA_syn * oversampling_factor;
% and for objective
kt_max_obj = k * NA_obj;

% calculate pixel size
sub_px_size = pi / kt_max_sub;
rec_px_size = pi / kt_max_rec;

% calculate reconstructed image size
m_r = ceil(m_s * kt_max_rec / kt_max_sub);
n_r = ceil(n_s * kt_max_rec / kt_max_sub);

% spatial frequency axes for spectrums of images
kx_axis_sub = linspace(-kt_max_sub,kt_max_sub,n_s);
ky_axis_sub = linspace(-kt_max_sub,kt_max_sub,m_s);
kx_axis_rec = linspace(-kt_max_rec,kt_max_rec,n_r);
ky_axis_rec = linspace(-kt_max_rec,kt_max_rec,m_r);

% grid of spatial frequencies for each pixel of reconstructed spectrum
[kx_g_rec,ky_g_rec] = meshgrid(kx_axis_rec,ky_axis_rec);
% same for sub-image spectrum
[kx_g_sub,ky_g_sub] = meshgrid(kx_axis_sub,ky_axis_sub);

%% retrieve phase iteratively

% initialize object
object = complex(zeros(m_r,n_r));
objectFT = fftshift(fft2(object));
% interpolate on-axis image maybe?  

% only need to generate one CTF, since it will be applied to the sub-images
% after they are extracted from the reconstructed image spectrum, and thus
% will not move around (relative to the sub-image).
CTF = ((kx_g_sub.^2 + ky_g_sub.^2) < kt_max_obj^2);

% setup figure
figure(1);
subplot(1,2,1);
subplot(1,2,2);
colormap gray;

for iter = 1:iterations         % one per iteration
    for i = 1:arraysize         % one per row of LEDs
        for j = 1:arraysize     % one per column of LEDs
            % calculate limits
            kx_center = round((kx_list(i) + kt_max_rec) ...
                / 2 / kt_max_rec * (n_r - 1)) + 1;
            ky_center = round((ky_list(j) + kt_max_rec) ...
                / 2 / kt_max_rec * (m_r - 1)) + 1;
            kx_low = round(kx_center - (n_s - 1) / 2);
            kx_high = round(kx_center + (n_s - 1) / 2);
            ky_low = round(ky_center - (m_s - 1) / 2);
            ky_high = round(ky_center + (m_s - 1) / 2);
            % extract piece of spectrum
            pieceFT = objectFT(ky_low:ky_high, kx_low:kx_high);
            pieceFT_constrained = pieceFT .* CTF;   % apply size constraint
            % iFFT
            % may need a scale factor here due to size difference
            piece = ifft2(ifftshift(pieceFT_constrained));
            % Replace intensity
            piece_replaced = sqrt(Images{i,j}) .* exp(1i * angle(piece));
            % FFT
            % also a scale factor here
            piece_replacedFT = fftshift(fft2(piece_replaced));
            % put it back
            objectFT(ky_low:ky_high, kx_low:kx_high) = ...
                piece_replacedFT .* CTF + pieceFT .* (1 - CTF);
            % display thingas
            subplot(1,2,1);
            imagesc(Images{i,j});
            axis image;
            title('sub-image');
            subplot(1,2,2);
            imagesc(angle(objectFT));
            axis image;
            title('object Fourier Transform');
            drawnow;
        end % column for
    end % row for
end % iteration for

%% compute & display reconstructed object

% compute
object = ifft2(ifftshift(objectFT));
% display
figure(1)
subplot(1,2,1);
imagesc(abs(object));
axis image;
title('Reconstructed Object Amplitude');

subplot(1,2,2);
imagesc(angle(object));
axis image;
colormap gray;
title('Reconstructed Object Phase');
