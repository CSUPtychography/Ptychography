function normalized = normgray(image)
%normgray: convert an image to grayscale and normalize to between 0 and 1
%    usage:  normalized = normgray(image);
%    input:  2- or 3-dimensional matrix
%    output: normalized 2-dimensional matrix

    % convert to float and normalize to between 0 and 1
    if isinteger(image)
        image = double(image) / double(intmax(class(image)));
    else
        image = double(image);
    end % integer if

    % squeeze and convert to B&W
    dimension = ndims(image);
    if dimension == 3
        % convert to black & white using lightness algorithm
        image = (min(image,[],3) + max(image,[],3)) / 2;
    elseif dimension ~= 2
        error('normgray: input image must be 2- or 3-dimensional');
    end % dimension if
    
end % function
