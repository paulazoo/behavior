function wm = wmean(X,n,dim)
% function wm = wmean(X,n,dim);
% Calculate the weighted mean of a matrix X with n observation.
% EXAMPLE
% X = [2 5 3 3 1; 2 5 8 9 0];
% n = [23 34 56 12 11; 45 57 89 23 30];
% dim = 2;

% Check ups
sX = size(X);
sn = size(n);
if sX(1) ~= sn(1) || sX(2) ~= sn(2)
    error('Size of n must match size of X');
end

if dim > ndims(X)
    error('Value of dim is greater than the ndims of X (%d)',ndims(X));
end

% Calculate weighted mean
wm = nansum((X.*n),dim)./nansum(n,dim);