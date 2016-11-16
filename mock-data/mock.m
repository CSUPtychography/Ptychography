% clear all;
% %% create mock data to test phase retrieval algorithm
% 
% %% parameters
magnitude_file = 'cameraman.png';
phase_file = 'lena.png';
% r = 16;
% 
% %% Import image data
% 
% mag = imread(magnitude_file);
% phase = imread(phase_file);
% % check size and squareness
% if size(mag) ~= size(phase)
%     error('Images are not the same size');
% end
% 
% % normalize between 0 and 1 for magnitude,
% %   and -0.5 to 0.5 for phase
% mag2 = double(mag) / 255;
% phase2 = double(phase) / 255 - 0.5;
% 
% % pack into single phase image
% I = mag2 .* exp(1i * 2 * pi * phase2);
% 
% % conserve memory ('cause we're gonna need it)
% %% small image construction
% % perform FFT on I
% IF = fft2(I);
% 
% % Create Transfer Function
% k = r+1;
% TF = zeros(size(mag));
% [m,n] = size(mag);
% Images = cell(size(mag)/r);
% imagesX=1;
% while(k < m);
% j=r+1;
% imagesY=1;
%     while (j < n);
%     TF(k-r:k+r-1,j-r:j+r-1) = 255;
%     Images{imagesX,imagesY} = TF.*IF;
%     imagesY = imagesY+1;
%     j = j+r;
%     TF = zeros(size(mag));
%     end
% imagesX=imagesX+1;
% k=k+r;
% end
% %% to be done with each segment
% A = Images{2,2};
% %trim each image
% AC = A(A~=0);
% %reshape each after trimming
% ACR = reshape(AC,2*r,2*r);
% %perform ifft2
% blur = abs(ifft2(ACR));
% %display image
% figure ()
% image(blur)
% colormap(gray(256));
% % problem here: will need to make this a circle instead of a rectangle,
% % CIRCLE = insertShape(blank,'filled circle',[128 128 8]);   ?
% % moving on...
% 
% % Measure Intensity
% 
% % Save small image in cell array

% This function can be used to take any two images, and create images with
% less resolution, to act as mock data.
% magnitude_file is the file you'd like to act as the magnitude
% phase_file is the file you'd like to act as the phase
% r is the radius you'd like to use for the transfer function
% a is the x coordinate of the location you'd like to have as the output
% b is the y coordinate of the location you'd like to have as the output
% try the following: 
%       ImageMock('cameraman.png','lena.png',32,16,16);
%% create mock data to test phase retrieval algorithm and ptychography Algorithm

%% Import image data

mag = imread(magnitude_file);
phase = imread(phase_file);
% check size and squareness
if size(mag) ~= size(phase)
    error('Images are not the same size');
end
%% Prepare imported data
% normalize between 0 and 1 for magnitude,
% and -0.5 to 0.5 for phase
mag2 = double(mag) / 255;
phase2 = double(phase) / 255 - 0.5;

% pack into single phase image
I = mag2 .* exp(1i * 2 * pi * phase2);

%% small image construction

% perform FFT on I
IF = fftshift(fft2(fftshift(I)));

% preparing variables for transfer function
k = r;
[m,n] = size(I);
[X,Y] = meshgrid(1:n,1:m);
Images = cell(floor([m,n] / r - 1));
imagesX=1;
while(k < m);
    j=r;
    imagesY=1;
    while (j < n);
        % preparing transfer function
        OTF = (sqrt((X - k).^2 + (Y - j).^2) < r);
        OTF(k-r+1:k+r,j-r+1:j+r) = 255;
        % multiply transfer function by FFt'd image
        blurred = OTF .* IF;
        % crop out region of interest
        blurred = blurred(k-r+1:k+r, j-r+1:j+r);
        % inverse fourier transform
        sub_image = fftshift(ifft2(fftshift(blurred)));
        % measure intensity
        sub_image = abs(sub_image).^2;
        % store in cell array
        Images{imagesX,imagesY} = sub_image;

        % counting through the image
        imagesY = imagesY+1;
        j = j+r;
    end % while
    imagesX=imagesX+1;
    k=k+r;
end
%% to be done with each segment
A = Images{a,b};

%display image
% figure ()
image(A)
colormap gray;
% problem here: will need to make this a circle instead of a rectangle
% possible solution to the transfer function:
% CIRCLE = insertShape(blank,'filled circle',[128 128 8]);

