function varargout = squiral(length)
%squiral: generates a sequence of points in an outward square spiral
%    usage:  sequence = squiral(length);
%        or: [x, y] = squiral(length);
%    input:  the length (number of points) in the spiral 
%              (choose a square for a square spiral)
%    output: a 2 x length list of points ([x; y])
%        or: two 1 x length lists of points, one each for x & y

    nargoutchk(0,2);    % check for correct number of outputs

    rotate = [0 1; -1 0];
    delta = [1; 0];
    steps = 1;              % number of steps in this line
    step = 0;               % which step are we on? 

    sequence = zeros(2, length);

    for i = 2:length
        % step in the current direction
        sequence(:,i) = sequence(:,i-1) + delta;
        step = step + 1;
        if (step == steps)
            % end of a line
            step = 0;               % reset steps
            delta = rotate * delta; % rotate clockwise
            if (delta(2) == 0)
                % if new direction is horizontal, increase number of steps
                steps = steps + 1;
            end % delta if
        end % step if
    end % for

    if (nargout == 1 || nargout == 0)
        varargout{1} = sequence;
    elseif (nargout == 2)
        varargout{1} = sequence(1,:);
        varargout{2} = sequence(2,:);
    else
        error('Wrong number of outputs');
    end % nargout if

end % function
