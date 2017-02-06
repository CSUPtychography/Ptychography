function normalized = normgray(image)
%normgray: convert an image to grayscale and normalize to between 0 and 1
%    usage:  normalized = normgray(image);
%    input:  2- or 3-dimensional matrix
%    output: normalized 2-dimensional matrix

    % squeeze and convert to B&W
    dimension = length(size(image));
    if dimension == 3
        % convert to black & white using lightness algorithm
        image = (min(image,[],3) + max(image,[],3)) / 2;
    elseif dimension ~= 2
        error('normgray: input image must be 2- or 3-dimensional');
    end % dimension if
    
    % normalize
    image = double(image);
    minimum = min(image(:));
    maximum = max(image(:));
    normalized = (image - minimum) / (maximum - minimum);
    
end % function