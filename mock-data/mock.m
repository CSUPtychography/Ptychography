%% create mock data to test phase retrieval algorithm


%% Import image data

raw_image = imread('world.jpg');

% split into magnitude and phase
% use left half for magnitude and right half for phase
% use green channel for good contrast and computational simplicity
% normalize between 0 and 1 for magnitude,
%   and -0.5 to 0.5 for phase
mag = double(raw_image(:,1:12000,2)) / 255;
phase = double(raw_image(:,12001:24000,2)) / 255 - 0.5;

% pack into single phase image
I = mag .* exp(1i * 2 * pi * phase);

% conserve memory ('cause we're gonna need it)
clear('raw_image','mag','phase');
