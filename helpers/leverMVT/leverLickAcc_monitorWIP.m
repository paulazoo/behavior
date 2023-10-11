% function [mvt,t] = leverLickAccMonitor(timeOut)
% % - Replace the old lever monitorMVT -
% % - 2020 VBP - With accelero data
% 
% if nargin < 1;
%     timeOut = 120;
% end
%setUpDirHFB_GF
clear all; close all; clc;
timeOut = 60;

% Initilialize =================================
estSamplingRate = 100;
% timeOut = 1000;
n = estSamplingRate*timeOut;
mvt = nan(n,1);
lick = nan(n,2);
acc = nan(n,3);
t = nan(n,1);

% Create a figure window to monitor the live data ===========
Tmax = timeOut; % Total time for data collection (s)
figure;
setFigure('tall')

ax(1) = subplot(3,1,1);
xlabel('Time (s)');
ylabel('Lick (I/O)');
xlim([0 Tmax+1]);
ylim([-0.1 1.1]);
l1 = line(t,lick(:,1));
title('Lick')
setUpPlotCompact

ax(2) = subplot(3,1,2);
xlabel('Time (s)');
ylabel('MVT (V)');
xlim([0 Tmax+1]);
ylim([-5 0]);
l2 = line(t,mvt);
title('MVT')
setUpPlotCompact

ax(3) = subplot(3,1,3);
xlabel('Time (s)');
ylabel('ACC (a.u.)');
xlim([0 Tmax+1]);
ylim([50 200])
l3 = line(t,acc);
title('Acc');
setUpPlotCompact

linkaxes(ax,'x');

% % % Keyboard
% % if strcmp(computer,'MACI64'); escapeKey = KbName('ESCAPE');
% % else escapeKey = KbName('esc'); end
% escapeKey = 27;
% ESC = false;
% button = double(get(gcf,'CurrentCharacter'));
% % [~,~,keyCode] = KbCheck;
% % ESC = keyCode(escapeKey) == 0;


% Open communication with Arduino ========
[ardIn,ardOut] = lever_cardSetUpInOutV2_GF;
lever_readArduinoV2(ardIn);
flushinput(ardIn);
%%
i = 1;
t0 = tic;
deltaT = 0;
try
while deltaT < timeOut
%     flushinput(ardIn);
    d = lever_readArduinoV2_GF(ardIn,t0,true);
    
    t(i) = d(1);
    mvt(i) = d(2);
    lick(i,:) = d(3:4);
    acc(i,:) = d(5:7);
%     [~,~,keyCode] = KbCheck;
%     ESC = keyCode(escapeKey) == 0;
%     button = double(get(gcf,'CurrentCharacter'));
%     if ~isempty(button)
%         ESC = (escapeKey == button);
%     end
%     set(l1,'Xdata',t,'Ydata',lick(:,1));
%     set(l2,'Xdata',t,'Ydata',mvt);
% 
%     set(l3(1),'Xdata',t,'Ydata',acc(:,1));
%     set(l3(2),'Xdata',t,'Ydata',acc(:,2));
%     set(l3(3),'Xdata',t,'Ydata',acc(:,3));
%     drawnow    
    
    deltaT = toc(t0);
    i = i+1;
end
end
%     set(l1,'Xdata',t,'Ydata',lick(:,1));
%     set(l2,'Xdata',t,'Ydata',mvt);
% 
%     set(l3(1),'Xdata',t,'Ydata',acc(:,1));
%     set(l3(2),'Xdata',t,'Ydata',acc(:,2));
%     set(l3(3),'Xdata',t,'Ydata',acc(:,3));
%     drawnow    

%%
t = t(~isnan(t));
mvt = mvt(~isnan(mvt));
lever_cleanArduino(ardIn);
% lever_cleanArduino(ardOut);



