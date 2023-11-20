function [m,s] = mean_sem(X,dim)

if nargin < 2
    dim = 1;
end

if any(isnan(X(:)))
    m = mean(X,dim,'omitnan');
    s = bsxfun(@rdivide,std(X,0,dim,'omitnan'),sqrt(sum(~isnan(X),dim)));
elseif isempty(X)
    m = nan;
    s = nan;
else  
    m = mean(X,dim);
    s = std(X,0,dim)/sqrt(size(X,dim));
end