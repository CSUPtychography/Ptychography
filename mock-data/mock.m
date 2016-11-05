%% create mock data to test phase retrieval algorithm

%% parameters
magnitude_file = 'cameraman.png';
phase_file = 'lena.png';

%% Import image data

mag = imread(magnitude_file);
phase = imread(phase_file);

% check size and squareness
if size(mag) ~= size(phase)
    error('Images are not the same size');
end % if

% normalize between 0 and 1 for magnitude,
%   and -0.5 to 0.5 for phase
mag = double(mag) / 255;
phase = double(phase) / 255 - 0.5;

% pack into single phase image
I = mag .* exp(1i * 2 * pi * phase);

% conserve memory ('cause we're gonna need it)
clear('raw_image','mag','phase');
