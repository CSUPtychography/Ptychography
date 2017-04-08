%% reconstruction algorithm
% a script to reconstruct phase information 
% from a set of fourier ptychographic images

%% Parameters and constants

% process parameters
min_overlap = 50;       % (%) overlap between adjacent subimage apertures
iterations = 5;         % number of iterations
% whether and what to display data at every step
% severely decreases performance
% plotprogress overrides plotobject
plotprogress = true;    % display data at every step if true
plotobject = true;      % plot object in addition to spectrum if true
filename = '../mock-data/mock_cl_3x3_5_7_15_6_8_w50';

% optical parameters
% will be overwritten by data import
wavelength = 600e-9;    % wavelength in meters (different for R,G,B)
LED_spacing = 5e-3;     % Distance between LEDs in meters
matrix_spacing = 70e-3; % Distance from matrix to sample in meters
x_offset = 0;           % Distance from center of matrix to optic axis
y_offset = 0;           % (in meters)
arraysize = 15;         % Number of LEDs in one side of the square
No_LEDs = arraysize^2;  % Total number of LEDs (should probably be square)
NA_obj = 0.08;          % Numerical aperture of the objective
px_size = 2.5e-6;       % Pixel spacing projected onto sample (in meters)


%% import images and other data

import = load(filename);

try
    version = import.version;
catch ME
    if strcmp(ME.identifier,'MATLAB:nonExistentField')
        cause = MException('MATLAB:reconstruct:noVersion', ...
            'File %s contains no version information', filename);
        ME = ME.addCause(cause);
    end % identifier if
    ME.rethrow;
end % version try/catch

if version ~= 1
    error('This algorithm is incompatible with file version %d.', version);
end % version if

wavelength = import.wavelength;
LED_spacing = import.LED_spacing;
matrix_spacing = import.matrix_spacing;
x_offset = import.x_offset;
y_offset = import.y_offset;
NA_obj = import.NA_obj;
px_size = import.px_size;
Images = import.Images;

[m_s,n_s] = size(Images{1});    % size of sub-images
array_dimensions = size(Images);

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
kt_max_sub = pi / px_size;
% and for reconstructed image
kt_max_rec = kt_max_sub * enhancement_factor;
% and for objective
kt_max_obj = k * NA_obj;

% calculate pixel size
sub_px_size = px_size;
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
objectFT = fftshift(fft2(ifftshift(object)));
% interpolate on-axis image maybe?  
% this is equivalent to doing the on-axis image first,
% and will be done eventually if a spiral scheme is used

% only need to generate one CTF, since it will be applied to the sub-images
% after they are extracted from the reconstructed image spectrum, and thus
% will not move around (relative to the sub-image).
CTF = ((kx_g_sub.^2 + ky_g_sub.^2) < kt_max_obj^2);

% setup figure for plotting
figure(1);
subplot(1,2,1);
subplot(1,2,2);
colormap gray;

% generate sequence of indices
% first make grids
[ig,jg] = meshgrid(1:arraysize);
% unwrap into sequences
i_seq = ig(:); j_seq = jg(:);

for iter = 1:iterations         % one per iteration
    for LED = 1:No_LEDs
        % calculate limits
        kx_center = round((kx_list(i_seq(LED)) + kt_max_rec) ...
            / 2 / kt_max_rec * (n_r - 1)) + 1;
        ky_center = round((ky_list(j_seq(LED)) + kt_max_rec) ...
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
        piece = fftshift(ifft2(ifftshift(pieceFT_constrained)));
        % Replace intensity
        piece_replaced = sqrt(Images{i_seq(LED),j_seq(LED)}) ...
            .* exp(1i * angle(piece));
        % FFT
        % also a scale factor here
        piece_replacedFT = fftshift(fft2(ifftshift(piece_replaced)));
        % put it back
        objectFT(ky_low:ky_high, kx_low:kx_high) = ...
            piece_replacedFT .* CTF + pieceFT .* (1 - CTF);
        % display thingas
        if plotprogress
            if plotobject, subplot(2,2,1), else subplot(1,2,1), end
            imagesc(Images{i_seq(LED),j_seq(LED)});
            axis image;
            title('sub-image');
            if plotobject, subplot(2,2,2), else subplot(1,2,2), end
            imagesc(log(abs(objectFT)));
            axis image;
            xlim([n_r/4, n_r*3/4]);
            ylim([m_r/4, m_r*3/4]);
            title('object Fourier Transform');
            if plotobject
                object = fftshift(ifft2(ifftshift(objectFT)));
                subplot(2,2,3);
                imagesc(abs(object));
                axis image;
                title('Reconstructed object magnitude');
                subplot(2,2,4);
                imagesc(angle(object));
                axis image;
                title('Reconstructed object phase');
            end % plotobject if
            drawnow;
         end % plotprogress if
    end % LED for
end % iteration for

%% compute & display reconstructed object

% compute
object = fftshift(ifft2(ifftshift(objectFT)));
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
