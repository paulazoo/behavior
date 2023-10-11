clear all; close all; clc;


% Test arduino on mac

% ARDUINO SET UP
[ardIn,~] = lever_cardSetUpInOutV3;
flush(ardIn);
t0 = tic;
dur = 2;
n = round(dur/(11/19200*8)*2);
d = nan(n,7);
k = 0;
while toc(t0) < dur
    x = lever_readArduinoV3beta(ardIn,t0);
    nLines = size(x,1);
    d((1:nLines)+k,:) = x;
    k = k+nLines;
    toc(t0)
end

selIdx = ~isnan(d(:,1));
d = d(selIdx,:);

figure;
plot(d(:,1),d(:,2))