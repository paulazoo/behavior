function sRate = estimateSpikeRate(spikes,t,bandwidth,style)
%     function estimateSpikeRate(spikes,t,bandwidth,style)
% Inputs:
% spikes = time stamps of spikes
% t = time vector to estimate spikes. Need to be created with equal bins
% bandwidth = FWHM of the exponential or gaussian function.
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
sRate = conv(spVector,kernel,'same');
