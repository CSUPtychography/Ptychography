function object = reconstruct(filename, iterations)
%reconstruct: perform fourier ptychographic phase-retrieval using the
%images and data stored in the file <filename>.
%    usage:  object = reconstruct(filename, iterations);
%    input:  filename:   the name of the file containing the data to use
%            iterations: the number of iterations to perform
%    output: the reconstructed object

    %% Parameters and constants
    
    % process parameters
    min_overlap = 50;       % (%) overlap between adjacent sub-apertures
    
    %% import images and other data
    
    import = load(filename);
    
    try
        version = import.version;
    catch Vexp
        if strcmp(Vexp.identifier,'MATLAB:nonExistentField')
            cause = MException('MATLAB:reconstruct:noVersion', ...
                'File %s contains no version information', filename);
            Vexp = Vexp.addCause(cause);
        end % identifier if
        Vexp.rethrow;
    end % version try/catch
    
    if version ~= 1
        error('This algorithm is incompatible with file version %d.', ...
            version);
    end % version if
    
    % optical parameters
    try
        wavelength = import.wavelength;
        LED_spacing = import.LED_spacing;
        matrix_spacing = import.matrix_spacing;
        x_offset = import.x_offset;
        y_offset = import.y_offset;
        NA_obj = import.NA_obj;
        px_size = import.px_size;
        Images = import.Images;
    catch Pexp
        if strcmp(Pexp.identifier,'MATLAB:nonExistentField')
            % find out which parameter is missing
            indices = find(Pexp.message == '''');
            missing_param = Pexp.message(indices(1)+1:indices(2)-1);
            cause = MException('MATLAB:reconstruct:missingParam', ...
                'File %s is missing the %s parameter', filename, missing_param);
            Pexp = Pexp.addCause(cause);
        end % identifier if
        Pexp.rethrow;
    end % parameter try/catch
    
    [m_s,n_s] = size(Images{1});    % size of sub-images
    array_dimensions = size(Images);
    
    % check if array is square
    if (array_dimensions(1) ~= array_dimensions(2))
        error('nonsquare (%d x %d) array is not supported', ...
            array_dimensions(1), array_dimensions(2));
    else
        arraysize = array_dimensions(1);
    end % array dimension if
    
    %% Calculated parameters
    
    % recalculate LED number just in case
    No_LEDs = arraysize^2;  % Total number of LEDs (should be square)
    
    % position of the farthest LED
    LED_limit = LED_spacing * (arraysize - 1) / 2;
    LED_positions = -LED_limit:LED_spacing:LED_limit;   % LED position list
    k = 2 * pi / wavelength;    % wavevector magnitude
    % lists of transverse wavevectors
    kx_list = k * sin(atan((LED_positions + x_offset) / matrix_spacing));
    ky_list = k * sin(atan((LED_positions + y_offset) / matrix_spacing));
    
    NA_led = sin(atan(LED_limit / matrix_spacing)); % NA of LEDs
    NA_syn = NA_led + NA_obj;   % synthetic numerical aperture
    
    enhancement_factor = 2 * NA_syn / NA_obj;       % resolution increase
    
    % check overlap criteria
    NA_single_led = sin(atan(LED_spacing / matrix_spacing));
    overlap = 100 - NA_single_led / 2 / NA_obj * 100; % sub-aperture overlap
    if (overlap < min_overlap)
        if (overlap < 0)
            error('Sub-apertures do not overlap. Increase matrix spacing');
        else
            error(strcat('Sub apertures only overlap by % 3.0f%%. ', ...
                'Increase matrix spacing.'), overlap);
        end % less than zero if
    end % overlap if
    
    % maximum spatial frequency for sub-image
    kt_max_sub = pi / px_size;
    % and for reconstructed image
    kt_max_rec = kt_max_sub * enhancement_factor;
    % and for objective
    kt_max_obj = k * NA_obj;
    
    % calculate pixel size
    sub_px_size = px_size;
    rec_px_size = pi / kt_max_rec;
    
    % calculate reconstructed image size
    m_r = ceil(m_s * kt_max_rec / kt_max_sub);
    n_r = ceil(n_s * kt_max_rec / kt_max_sub);
    
    % spatial frequency axes for spectrums of images
    kx_axis_sub = linspace(-kt_max_sub,kt_max_sub,n_s);
    ky_axis_sub = linspace(-kt_max_sub,kt_max_sub,m_s);
    kx_axis_rec = linspace(-kt_max_rec,kt_max_rec,n_r);
    ky_axis_rec = linspace(-kt_max_rec,kt_max_rec,m_r);
    
    % grid of spatial frequencies for each pixel of reconstructed spectrum
    [kx_g_rec,ky_g_rec] = meshgrid(kx_axis_rec,ky_axis_rec);
    % same for sub-image spectrum
    [kx_g_sub,ky_g_sub] = meshgrid(kx_axis_sub,ky_axis_sub);
    
    %% retrieve phase iteratively
    
    % initialize object
    object = complex(zeros(m_r,n_r));
    objectFT = fftshift(fft2(ifftshift(object)));
    % interpolate on-axis image maybe?  
    % this is equivalent to doing the on-axis image first,
    % and will be done eventually if a spiral scheme is used
    
    % only need to generate one CTF, since it will be applied to the
    % sub-images after they are extracted from the reconstructed image
    % spectrum, and thus will not move around (relative to the sub-image).
    CTF = ((kx_g_sub.^2 + ky_g_sub.^2) < kt_max_obj^2);
    
    for iter = 1:iterations         % one per iteration
        for i = 1:arraysize         % one per row of LEDs
            for j = 1:arraysize     % one per column of LEDs
                % calculate limits
                kx_center = round((kx_list(j) + kt_max_rec) ...
                    / 2 / kt_max_rec * (n_r - 1)) + 1;
                ky_center = round((ky_list(i) + kt_max_rec) ...
                    / 2 / kt_max_rec * (m_r - 1)) + 1;
                kx_low = round(kx_center - (n_s - 1) / 2);
                kx_high = round(kx_center + (n_s - 1) / 2);
                ky_low = round(ky_center - (m_s - 1) / 2);
                ky_high = round(ky_center + (m_s - 1) / 2);
                % extract piece of spectrum
                pieceFT = objectFT(ky_low:ky_high, kx_low:kx_high);
                pieceFT_constrained = pieceFT .* CTF;   % apply CTF
                % iFFT
                % may need a scale factor here due to size difference
                piece = fftshift(ifft2(ifftshift(pieceFT_constrained)));
                % Replace intensity
                piece_replaced = sqrt(Images{i,j}) ...
                    .* exp(1i * angle(piece));
                % FFT
                % also a scale factor here
                piece_replacedFT=fftshift(fft2(ifftshift(piece_replaced)));
                % put it back
                objectFT(ky_low:ky_high, kx_low:kx_high) = ...
                    piece_replacedFT .* CTF + pieceFT .* (1 - CTF);
            end % column for
        end % row for
    end % iteration for
    
    %% compute reconstructed object
    object = fftshift(ifft2(ifftshift(objectFT)));
end % function
