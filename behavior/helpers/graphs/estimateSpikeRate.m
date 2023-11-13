function sRate = estimateSpikeRate(spikes,t,FWHM,style)
% function sRate = estimateSpikeRate(spikes,t,FWHM,style)
% Inputs:
% spikes = time stamps of spikes
% t = time vector to estimate spikes. Need to be created with equal bins
% FWHM of the exponential or gaussian function.
% style of estimation 'gaussian' or 'exponential'. Default is gaussian

    if nargin < 4
        style = 'gaussian';
    end
    
    if size(t,2) == 1;
        t = t';
    end
binSize = mean(diff(t));
e = [t t(end)+binSize] - binSize/2;
spVector = histcounts(spikes,e);
sigma = FWHM/(2*sqrt(2*log(2)));

switch style
    case 'gaussian'
        tmax = 2*ceil(sqrt(-2*sigma^2*log((sqrt(2*pi)*sigma)/10000))/binSize)*binSize;
        tKernel = -tmax*10:binSize:tmax*10;
        kernel = 1/(sqrt(2*pi)*sigma)*exp(-tKernel.^2/(2*sigma^2));
%         kernel = 1/(sqrt(2*pi)*sigma)*exp(-tKernel.^2/(2*sigma^2));
    case 'exponential'
        tmax = abs(ceil(log((sqrt(2)*sigma)/10000)*sigma/sqrt(2)/binSize)*binSize);
        tKernel = -tmax:binSize:tmax;
        kernel = 1/(sqrt(2)*sigma)*exp(-sqrt(2)*abs(tKernel./sigma));
end
sRate = conv(spVector,kernel,'same');
