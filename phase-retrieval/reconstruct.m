%% reconstruction algorithm
% a script to reconstruct phase information 
% from a set of fourier ptychographic images

%% Parameters and constants

filename = '../mock-data/mockim_r64_dk64.mat';

r = 64;                     % CTF radius in pixels
delta_k = r;                % space between adjacent images in pixels
pad_px = 10;                % number of pixels to zero pad

object_size = [256 256];    % final object size in pixels

iterations = 5;             % number of iterations

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
% todo: center the grid on zero
k_x = r:delta_k:object_size(2) - r;
k_y = r:delta_k:object_size(1) - r;

% prepare CTF (circle of radius r)
[X,Y] = meshgrid(-r+1:r);
CTF = X.^2 + Y.^2 < r^2;

% setup figure
figure(1);
subplot(1,2,1);
subplot(1,2,2);
colormap gray;

for iter = 1:iterations         % one per iteration
    for i = 1:array_size        % one per row of LEDs
        for j = 1:array_size    % one per column of LEDs
            % extract piece of spectrum
            pieceFT = objectFT(k_x(i)-r+1:k_x(i)+r,k_y(j)-r+1:k_y(j)+r);
            pieceFT_constrained = pieceFT .* CTF;   % apply size constraint
            % zero pad to avoid problems
            pieceFT_constrained = zero_pad(pieceFT_constrained, pad_px);
            % iFFT
            % may need a scale factor here due to size difference
            piece = ifft2(ifftshift(pieceFT_constrained));
            % crop to fix zero-padding
            piece = piece(pad_px:end-pad_px, pad_px:end-pad_px);
            % Replace intensity
            piece_replaced = sqrt(Images{i,j}) .* exp(1i * angle(piece));
            % zero pad again (this is so hacky)
            piece_replaced = zero_pad(piece_replaced, pad_px);
            % FFT
            % also a scale factor here
            piece_replacedFT = fftshift(fft2(piece_replaced));
            % resize
            piece_replacedFT = piece_replacedFT(pad_px:end-pad_px, pad_px:end-pad_px); % gross
            % put it back
            objectFT(k_x(i)-r+1:k_x(i)+r,k_y(j)-r+1:k_y(j)+r) = ...
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
