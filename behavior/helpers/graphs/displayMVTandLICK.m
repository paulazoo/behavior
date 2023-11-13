function displayMVTandLICK(data.response)
    dataArd = data.response.dataArduino;
t = dataArd(:,1);
mvt = dataArd(:,2);
lickR = [diff(dataArd(:,3)); 0] > 0;
lickL = [diff(dataArd(:,4)); 0] > 0;

figure;
ax(1) = subplot(3,1,1);
hold all;
plot(t,mvt,'b');
plot(data.response.timeTrialStart,max(mvt)*ones(size(response.timeTrialStart)),'dg');
plot(response.timeLeverPressed,response.leverPressed*max(mvt),'xr');
plot(response.timeDecision,max(mvt)*ones(size(response.timeDecision)),'om');
legend('Lever','Trial start','Lever pressed','Decision','Location','best'); legend boxoff
setUpPlotCompact
ylabel('MVT (V)');

response.blockType = response.blockType(1:length(response.timeTrialStart));
idL = response.blockType == 2;
idCorr = idL & response.decision == 2;
ax(2) = subplot(3,1,2);
hold all;
plot(t,lickL,'k');
plot(response.timeDecision(idCorr > 0),1,'om')
setUpPlotCompact;
xlabel('Time (s)');
ylabel('Lick I/O (LEFT)');
ylim([0 1])

response.blockType = response.blockType(1:length(response.timeTrialStart));
idR = response.blockType == 1;
idCorr = idR & response.decision == 1;
ax(3) = subplot(3,1,3);
hold all;
plot(t,lickR,'k');
plot(response.timeDecision(idCorr > 0),1,'om')
setUpPlotCompact;
xlabel('Time (s)');
ylabel('Lick I/O (RIGHT)');
ylim([0 1])

linkaxes(ax,'x');
