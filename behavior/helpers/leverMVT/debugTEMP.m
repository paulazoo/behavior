clear all; close all; clc;
% function [mvt,t] = lever_monitorMVT(timeOut)
% - To test the mvt of the lever -
% - 2018 VBP -

% if nargin < 1;
    timeOut = 30;
% end
setUpDirHFB_GF

% Initilialize =================================
estSamplingRate = 100;
% timeOut = 1000;
n = estSamplingRate*timeOut;
mvt = nan(n,1);
t = nan(n,1);

% Keyboard
if strcmp(computer,'MACI64'); escapeKey = KbName('ESCAPE');
else escapeKey = KbName('esc'); end
ESC = true;
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Create a figure window to monitor the live data ===========
Tmax = timeOut; % Total time for data collection (s)
figure;
xlabel ('Time (s)'), ylabel('MVT (V)'),
xlim([0 Tmax+1]),
l = line(t,mvt);
setUpPlot;
%%
% Open communication with Arduino ========
[ardIn,ardOut] = lever_cardSetUpInOutV2_GF;
lever_readArduino(ardIn);

%%
i = 1;
flushinput(ardIn);
t0 = GetSecs;
deltaT = 0;

while deltaT < timeOut && ESC
% for i = 1:n

    d = lever_readArduino(ardIn,t0,true);
    t(i) = d(1);
    mvt(i) = d(2);
    
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
%     tic
    set(l,'Xdata',t,'Ydata',mvt);
    drawnow
%     toc
    deltaT = GetSecs - t0;
    i = i+1;
end
%%
t = t(~isnan(t));
mvt = mvt(~isnan(mvt));
lever_cleanArduino(ardIn);
lever_cleanArduino(ardOut);



