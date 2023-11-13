function leverLickAccMonitor(timeOut)
% % - Replace the old lever monitorMVT function -
% % - 2020 VBP - With accelero data
%
if nargin < 1
    timeOut = 120;
end
% setUpDirHFB

% Initilialize =================================
estSamplingRate = 100;
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
title('Close figure window to stop!')
setUpPlotCompact

ax(2) = subplot(3,1,2);
xlabel('Time (s)');
ylabel('MVT (V)');
xlim([0 Tmax+1]);
ylim([-5 0]);
l2 = line(t,mvt);
setUpPlotCompact

ax(3) = subplot(3,1,3);
xlabel('Time (s)');
ylabel('ACC (a.u.)');
xlim([0 Tmax+1]);
ylim([50 200])
l3 = line(t,acc);
legend('x','y','z')
setUpPlotCompact

linkaxes(ax,'x');

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
        d = lever_readArduinoV2(ardIn,t0,true);
        
        t(i) = d(1);
        mvt(i) = d(2);
        lick(i,:) = d(3:4);
        acc(i,:) = d(5:7);

        % Update figure
        set(l1,'Xdata',t,'Ydata',lick(:,1));
        set(l2,'Xdata',t,'Ydata',mvt);        
        set(l3(1),'Xdata',t,'Ydata',acc(:,1));
        set(l3(2),'Xdata',t,'Ydata',acc(:,2));
        set(l3(3),'Xdata',t,'Ydata',acc(:,3));
        drawnow
        
        deltaT = toc(t0);
        i = i+1;
    end
catch
end

%%
lever_cleanArduino(ardIn,'IN');
[~,systName] = system('hostname');
systName = systName(1:end-1);
if ~strcmp(systName,'DESKTOP-TC5GOAV')    

lever_cleanArduino(ardOut,'OUT');
end


