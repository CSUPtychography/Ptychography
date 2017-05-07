function fixed = fixphase(object)
%fixphase: remove vertical gradient that causes wrapping & discontinuity
%Does not work on very complicated images.
%    input:  object: the object to fix
%    output: fixed: the fixed object
    
    phase = angle(object);

    % generate grid of y values same size as object
    [~,Y] = meshgrid(1:size(object,2),1:size(object,1));

    % find halfway point
    half = (size(object,1)-1) / 2 + 1;

    % mask high-wrapped phase at bottom of image
    high_mask = ((phase < -1) & (Y > half));
    % mask the low-wrapped phase at top of image
    low_mask = ((phase > 1) & (Y < half));

    % unwrap phase
    phase(high_mask) = phase(high_mask) + 2*pi;
    phase(low_mask) = phase(low_mask) - 2*pi;

    % detrend
    phase = detrend(phase);

    % put back into object
    fixed = abs(object) .* exp(1i * phase);
end % function
