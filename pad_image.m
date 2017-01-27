function padded = pad_image(image, no_pixels)
%pad_image: add zero-padding to the edges of an image to avoid FFT problems
%    usage:  padded = pad_image(image, no_pixels);
%    input:  image: The image to pad with zeros
%            no_pixels: The number of pixels to add
%    output: The padded image

    [m,n] = size(image);
    corner = zeros(no_pixels);      % corner square
    h_edge = zeros(no_pixels, n);   % horizontal (top & bottom) edge
    v_edge = zeros(m, no_pixels);   % vertical (left & right) edge
    
    padded = [corner  h_edge corner; ...
              v_edge  image  v_edge; ...
              corner  h_edge corner];

end % function
