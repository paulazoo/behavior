function dp = d_prime(hit_rate,falarm_rate,truncation)

if nargin < 3
    truncation = 0.01;
end

hit_rate(hit_rate>1-truncation) = 1-truncation;
falarm_rate(falarm_rate>1-truncation) = 1-truncation;
hit_rate(hit_rate<truncation) = truncation;
falarm_rate(falarm_rate<truncation) = truncation;

dp = norminv(hit_rate,0,1) - norminv(falarm_rate,0,1);