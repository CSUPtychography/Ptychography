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

% prepare CTF (circle of radius r)
[X,Y] = meshgrid(-r:r);
CTF = X.^2 + Y.^2 < r^2;

for iter = 1:iterations         % one per iteration
    for i = 1:array_size        % one per row of LEDs
        for j = 1:array_size    % one per column of LEDs
            % extract piece of spectrum
            pieceFT = objectFT(k_x(i)-r:k_x(i)+r,k_y(j)-r:k_y(j)+r);
            pieceFT_constrained = pieceFT .* CTF;   % apply size constraint
            % iFFT
            piece = ifft2(ifftshift(pieceFT_constrained));
            % Replace intensity
            piece_replaced = Images{i,j} .* exp(1i * angle(piece));
            % FFT
            piece_replacedFT = fftshift(fft2(piece_replaced));
            % put it back

        end % column for
    end % row for
end % iteration for

