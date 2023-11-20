function P = vecOfRandPerm(n,N)
% Successive random permutation of integers n on a vector of length N.
% n : 1 to n inclusive integers to randomly permute
% N : length of final vector
% EXAMPLE: 
% vecOfRandPerm(3,11)
% ans =     2     3     1     1     2     3     3     1     2     2     3

P = [];
for i = 1:ceil(N/n)
    A = randperm(n);
    P = [P A];
end
P = P(1:N);