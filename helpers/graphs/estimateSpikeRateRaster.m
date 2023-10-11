function [sRate, m, err] = estimateSpikeRateRaster(R,res,FWHM,style)
% function [sRate, m, err] = estimateSpikeRateRaster(R,res,bandwidth,style)
%
% INPUTS
% R - logical 'Trials X Samples'
% res - resolution of R (in the form 10^res)
% FWHM of the exponential or gaussian function.
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
sigma = FWHM/(2*sqrt(2*log(2)));

switch style
    case 'gaussian'
        tmax = 2*ceil(sqrt(-2*sigma^2*log((sqrt(2*pi)*sigma)/10000))/binSize)*binSize;
        tKernel = -tmax:binSize:tmax;
        kernel = 1/(sqrt(2*pi)*sigma)*exp(-tKernel.^2/(2*sigma^2));
    case 'exponential'
        tmax = abs(ceil(log((sqrt(2)*sigma)/10000)*sigma/sqrt(2)/binSize)*binSize);
        tKernel = -tmax:binSize:tmax;
        kernel = 1/(sqrt(2)*sigma)*exp(-sqrt(2)*abs(tKernel./sigma));
end
sRate = nan(size(raster));
for i = 1:nTrials
    sRate(i,:) = conv(raster(i,:),kernel,'same');
end

[m,err] = mean_sem(sRate,1);

