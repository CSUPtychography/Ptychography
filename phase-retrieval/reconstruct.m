%% reconstruction algorithm
% a script to reconstruct phase information 
% from a set of fourier ptychographic images

%% Parameters and constants

filename = '../mock-data/mockim_r64_dk64.mat';

r = 64;             % CTF radius in pixels
delta_k = r;        % space between adjacent images in pixels

object_size = 256;  % final object size in pixels

iterations = 1;     % number of iterations

%% import images and other data (?)

import = load(filename);

Images = import.Images;
arraysize = size(Images);

