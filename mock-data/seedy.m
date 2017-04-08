function y = seedx(n)
% creates y seed for nth spiral bit
    
    y = [0:n n(ones(1,2*n-1)) n:-1:-n -n(ones(1,2*n)) -n:-1];
end % function
