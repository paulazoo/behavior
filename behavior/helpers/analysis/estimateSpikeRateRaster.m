function [sRate, m, err] = estimateSpikeRateRaster(R,res,bandwidth,style)
% function [sRate, m, err] = estimateSpikeRateRaster(R,res,bandwidth,style)
%
% INPUTS
% R - logical 'Trials X Samples'
% res - resolution of R (in the form 10^res)
% bandwidth - size of the approximation
% style - 'gaussian' or 'exponential'
%
% OUTPUTS
% sRate - approximation of spike rate for raster R
% m - session average
% err - session error

if nargin < 4
    style = 'gaussian';
end
if ~(strcmp(style,'gaussian') || strcmp(style,'exponential'))
    warning('There might be a typo in the spelling of ''gaussian'' or ''exponential''.');
    style = 'gaussian';
end

nTrials = size(R,1);
binSize = 10^res;
raster = double(R);

switch style
    case 'gaussian'
        tmax = 2*ceil(sqrt(-2*bandwidth^2*log((sqrt(2*pi)*bandwidth)/10000))/binSize)*binSize;
        tKernel = -tmax:binSize:tmax;
        kernel = 1/(sqrt(2*pi)*bandwidth)*exp(-tKernel.^2/(2*bandwidth^2));
    case 'exponential'
        tmax = abs(ceil(log((sqrt(2)*bandwidth)/10000)*bandwidth/sqrt(2)/binSize)*binSize);
        tKernel = -tmax:binSize:tmax;
        kernel = 1/(sqrt(2)*bandwidth)*exp(-sqrt(2)*abs(tKernel./bandwidth));
end
sRate = nan(size(raster));
for i = 1:nTrials
    sRate(i,:) = conv(raster(i,:),kernel,'same');
end

[m,err] = mean_sem(sRate,1);

