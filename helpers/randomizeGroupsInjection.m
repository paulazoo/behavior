clear all; close all; clc;

injection = {'Saline','dmPFC','MC'};
ANID = {'Gi01','Gi02','Gi03'};


X = vecOfRandPerm(length(injection),9);
X  = reshape(X,3,3);

condition = injection(X)';

T = table(ANID',condition)