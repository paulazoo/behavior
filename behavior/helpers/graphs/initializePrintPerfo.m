function lineHandle = initializePrintPerfo(nTrials)


% INITIALIZE PERFORMANCE FIGURE ========================================================================================
c = setColor;

% PAST 50 TRIALS
nPast = 50;
x = nan(1,nTrials);
xPast = nan(1,nTrials-nPast+1);
y = nan(1,nTrials);
yPast = nan(1,nTrials-nPast+1);

figure;
pos = get(gcf,'position');
set(gcf,'position',[pos(1)-pos(3)/2 pos(2) pos(3)*2 pos(4)]);

subplot(1,2,1);
hold all;
lineHandle.l1 = line(x,y,'linewidth',1,'color',c.blue2);
lineHandle.l2 = line(x,y,'linewidth',1,'color',c.red);
lineHandle.l3 = line(x,y,'linewidth',2,'color','k');
lineHandle.l4 = line(x,y,'linewidth',1,'color',c.orange);
setUpPlotCompact;
legend('Hit corr.','False alarm','Perfo','Early','location','southwest');
legend('boxoff')
grid on
xlabel('Trial #');
ylabel('%');
ylim([0 101]);
title('Cummulative performance');

subplot(1,2,2);
hold all;
lineHandle.l5 = line(xPast,yPast,'linewidth',1,'color',c.blue2);
lineHandle.l6 = line(xPast,yPast,'linewidth',1,'color',c.red);
lineHandle.l7 = line(xPast,yPast,'linewidth',2,'color','k');
lineHandle.l8 = line(xPast,yPast,'linewidth',1,'color',c.orange);
setUpPlotCompact;
grid on
xlabel('Trial #');
ylabel('%');
ylim([0 101]);
title(['Average of past ' num2str(nPast) ' trials']);

drawnow


