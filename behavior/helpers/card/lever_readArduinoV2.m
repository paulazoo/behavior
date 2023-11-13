function d = lever_readArduinoV2(ard,t0,msgOn)
% function d = lever_readArduino(ard,t0,message)
%
% d(1) = absolute time
% d(2) = lever value
% d(3) = lickspout1 value
% d(4) = lickspout2 value
% d(5) = accelerator X value
% d(6) = accelerator Y value
% d(7) = accelerator Z value
%
% - 2020 VBP - NOW WITH ACCELEROMETER INPUTS; DOES NOT USE getSecs FUNCTION
% ANYMORE. TRYING TO GET RID OF PSYCH TOOLBOX EVENTUALLY. t0 = tic in at
% the start of session
if nargin < 3
    msgOn = false;
    if nargin < 2
        t0 = tic;
    end
end
nBytes = 6;
maxI = 10;
nLanesLag = 3;

if ard.BytesAvailable > nLanesLag*(nBytes+2)
    flushinput(ard); % to avoid lags
    a = fscanf(ard);
    i = 1;
    while length(a) ~= nBytes +2 && i < maxI
        a = fscanf(ard);
        i = i+1;
    end
else
    a = fscanf(ard);
end

d(1) = toc(t0);
if length(a) == nBytes + 2    
    x = double(a);
    d(2) = x(1) * 255 + x(2); % lever
    d(2) = d(2) * -0.0049;
    x(3) = x(3) - 100;
    d(3) = floor(x(3)/10);
    d(4) = mod(x(3),10);
    d(5:7) = x(4:6);
else
    d(2:7) = nan;
end
if msgOn; fprintf('%3.3f\t%2.3f\t%d\t%d\t%d\t%d\t%d\n',d(1),d(2),d(3),d(4),d(5),d(6),d(7)); end
