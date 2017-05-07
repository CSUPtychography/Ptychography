function similarity = imcmp(image,original);
%imcmp: compare two images irrespective of size, scale, or offset using
%        the Pearson correlation coefficient
%    inputs: image:      The image to compare
%            original:   The image to compare it against
%    output: similarity: The quantitative similarity between the images

    image = imresize(image,size(original));

    image = image(:);
    original = original(:);

    im_mean = mean(image);
    orig_mean = mean(original);

    im_std = std(image);
    orig_std = std(original);

    covariance = abs(mean(image.*original) - im_mean*orig_mean);

    similarity = covariance / im_std / orig_std;

end % imcmp
