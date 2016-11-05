function s = seed(n)
% creates seed for nth spiral bit
    
    s = [0:n n(ones(1,2*n-2)) n:-1:-n -n(ones(1,2*n-1)) -n:-1];
end % function
