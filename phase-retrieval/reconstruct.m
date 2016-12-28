%% reconstruction algorithm
% a script to reconstruct phase information 
% from a set of fourier ptychographic images

%% Parameters and constants

filename = '../mock-data/mockim_r64_dk64.mat';

r = 64;                     % CTF radius in pixels
delta_k = r;                % space between adjacent images in pixels

object_size = [256 256];    % final object size in pixels

iterations = 1;             % number of iterations

%% import images and other data (?)

import = load(filename);

Images = import.Images;
array_size = size(Images);

%% retrieve phase iteratively

% initialize object
object = complex(zeros(object_size));
objectFT = fftshift(fft2(object));
% interpolate on-axis image maybe?  

% create list of k vectors
k_x = r:delta_k:object_size(1) - r;
k_y = r:delta_k:object_size(2) - r;

% grid of indices
[X,Y] = meshgrid(1:object_size(1),1:object_size(2));

for iter = 1:iterations         % one per iteration
    for i = 1:array_size        % one per row of LEDs
        for j = 1:array_size    % one per column of LEDs
            % prepare CTF (circle radius R center (k_x,k_y))
            CTF = ((X - k_x(i)).^2 + (Y - k_y(j)).^2 < r^2);
            % extract piece of spectrum
            
            % FFT

            % Replace intensity

            % put it back

        end % column for
    end % row for
end % iteration for

