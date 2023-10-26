function plotSessionAverages(dataBeh)


%% setUp
tArd = dataBeh.response.dataArduino(:,1);
sr = 1/mean(diff(tArd));
lever = dataBeh.response.dataArduino(:,2);
lick = abs([0; diff(dataBeh.response.dataArduino(:,3)) > 0]);
if size(dataBeh.response.dataArduino,2) > 4
    acc = dataBeh.response.dataArduino(:,5:7);
end
MTXResp = dataBeh.response.respMTX;
MTXTrialType = dataBeh.params.MTXTrialType;
nTrials = size(MTXResp,1);
MTXTrialType = MTXTrialType(1:nTrials,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1- Figure full traces of lever, lick, accelerometer

tTrial = MTXResp(:,[1 2 4]);
tTrial = tTrial(~isnan(tTrial(:,1)),:);

figure;
setFigure('tall')

% LEVER
ax(1) = subplot(3,1,1);
hold all;
plot(tArd,lever,'-k','linewidth',0.5);
YL = ylim;
Y = diff(YL)*0.95+YL(1);
plot(tTrial(:,1),Y,'xr')
plot(tTrial(:,2),Y,'db')
plot(tTrial(:,3),Y,'vm')
setUpPlotCompact;
xlabel('Time (s)');
ylabel('Lever (V)');

% Lick
ax(2) = subplot(3,1,2);
hold all;
plot(tArd,lick,'-k','linewidth',0.5);
YL = ylim;
Y = YL(2);
plot(tTrial(:,1),Y,'xr')
plot(tTrial(:,2),Y,'db')
plot(tTrial(:,3),Y,'mv')
setUpPlotCompact;
xlabel('Time (s)');
ylabel('Lick (I/O)');

if size(dataBeh.response.dataArduino,2) > 4
    
    % Accelerometer
    ax(3) = subplot(3,1,3);
    hold all;
    plot(tArd,acc(:,1),'-k','linewidth',0.5);
    plot(tArd,acc(:,2),'-y','linewidth',0.5);
    plot(tArd,acc(:,3),'-g','linewidth',0.5);
    YL = ylim;
    Y = YL(2);
    plot(tTrial(:,1),Y,'xr')
    plot(tTrial(:,2),Y,'db')
    plot(tTrial(:,3),Y,'mv')
    setUpPlotCompact;
    xlabel('Time (s)');
    ylabel('Acc (a.u.)');
    
end
linkaxes(ax,'x')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2- Figure rasters of lever, lick, accelero align to tone

% Find index 'idx' for tone -----------------
tAlign = MTXResp(:,2);
idxAlign = nan(size(tAlign));
for i = 1:length(tAlign)
    if ~isempty(find(tArd > (tAlign(i)) ,1))
        idxAlign(i) = find(tArd > (tAlign(i)),1)-1;
    end
end

% Sort trials -----------------

% Determine trial type
H = MTXTrialType(:,3) >= 5 & MTXResp(:,3) > 0;
FA = MTXTrialType(:,3) < 5 & MTXResp(:,3) > 0;

% Difficulty
diffLevel = nan(nTrials,1);
idx = MTXTrialType(:,3) > 4; % GO
diffLevel(idx) = 9-MTXTrialType(idx,3);
idx = MTXTrialType(:,3) < 5; % NO-GO
diffLevel(idx) = 5-MTXTrialType(idx,3);

% Make raster of lever ---------------------

win = [-2 3];
A = makeRaster(lever,idxAlign(~isnan(idxAlign)),round(win*sr));
tR = linspace(win(1),win(2),size(A,2));
R = nan(length(idxAlign),size(A,2));
R(~isnan(idxAlign),:) = A;

% Plot lever -------------------------
figure;
set(gcf,'name','Hit trials');
setFigure('tall')
ylb = {'Low stim',' ',' ','High stim'};
m = nan(size(R,2),4);
for i = 1:4
    selR = R(H & diffLevel == i,:);
    subplot(5,2,1+2*(i-1))
    imagesc(selR,[prctile(lever,1) prctile(lever,99.5)])
    if i == 1
        title('Lever')
    end
    set(gca,'xtick',[])
    if size(selR,1) > 1
        set(gca,'ytick',[1 size(selR,1)])
    end
    ylabel(ylb{i})
    setUpPlotCompact
    
    m(:,i) = mean(selR,1,'omitnan');
end

subplot(5,2,1+2*4)
plot(tR,m)
setUpPlotCompact
xlim(win)
xlabel('Time from stim (s)')
ylabel('Lever (V)')
title('Average')

%%
% Make raster of lick ---------------------

win = [-2 3];
A = makeRaster(lick,idxAlign(~isnan(idxAlign)),round(win*sr));
tR = linspace(win(1),win(2),size(A,2));
R = nan(length(idxAlign),size(A,2));
R(~isnan(idxAlign),:) = A;
R(isnan(R)) = 0;
R = logical(R);

% Plot licks -------------------------
m = nan(size(R,2),4);
for i = 1:4
    selR = R(H & diffLevel == i,:);
    subplot(5,2,2+2*(i-1))
    plotSpikeRaster(selR);
    if i == 1
        title('Licks')
    end
    set(gca,'xtick',[])
    if size(selR,1) > 1
        set(gca,'ytick',[1 size(selR,1)])
    end
    setUpPlotCompact
    
    binSelR = movmean(selR,round(sr*0.1),2);
    m(:,i) = mean(binSelR,1);
end

subplot(5,2,2+2*4)
plot(tR,m*round(sr*0.1)/0.1)
setUpPlotCompact
xlim(win)
xlabel('Time from stim (s)')
ylabel('Lick rate (Hz)')
title('Average')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3- Figure session average perfo (%) and RT

% Determine trial type
H = MTXTrialType(:,3) >= 5 & MTXResp(:,3) > 0;
go = MTXTrialType(:,3) >= 5 & (MTXResp(:,6) == 0);
FA = MTXTrialType(:,3) < 5 & MTXResp(:,3) > 0;
CR = MTXTrialType(:,3) < 5 & MTXResp(:,3) == 0;
noGo = MTXTrialType(:,3) < 5 & (MTXResp(:,6) == 0);
laser = MTXTrialType(:,5) == 1;

% Determine reaction time
RT = MTXResp(:,4)-MTXResp(:,2);

% Determine response
for i = 1:4
    HR(i) = sum(H & diffLevel == i & ~laser)/sum(go & diffLevel == i & ~laser);
    FAR(i) = sum(FA & diffLevel == i & ~laser)/sum(noGo & diffLevel == i & ~laser);
    PERF(i) = (sum(H & diffLevel == i & ~laser) + sum(CR & diffLevel == i & ~laser))/(sum(go & diffLevel == i & ~laser) + sum(noGo & diffLevel == i & ~laser));
    mRT(i,1) = mean(RT(H & diffLevel == i & ~laser),'omitnan');
    mRT(i,2) = mean(RT(FA & diffLevel == i & ~laser),'omitnan');
end

dp = d_prime(HR,FAR);

figure;
setFigure('large')

% H, FA, Perf
subplot(1,3,1)
hold all
plot(1:4,HR*100,'o-b')
plot(1:4,FAR*100,'o-r')
plot(1:4,PERF*100,'o-k')
set(gca,'xtick',1:4,'xticklabel',ylb)
ylabel('(%)')
xlabel('Stim intensities')
setUpPlotCompact
legend('Hits','FA','Performance')
ylim([0 100])

% D PRIME
subplot(1,3,2)
plot(1:4,dp,'o-k')
set(gca,'xtick',1:4,'xticklabel',ylb)
ylabel('d-prime')
xlabel('Stim intensities')
setUpPlotCompact

% REACTION TIME
subplot(1,3,3)
hold all;
plot(1:4,mRT(:,1),'o-b')
plot(1:4,mRT(:,2),'o-r')
set(gca,'xtick',1:4,'xticklabel',ylb)
ylabel('Reaction time (s)')
xlabel('Stim intensities')
setUpPlotCompact


%%% IF LASER
%%% (WARNING: poor copy paste coding here need to improve sometime in the future)

if dataBeh.params.laser(1) > 0
    % Determine response
    for i = 1:4
        HR(i) = sum(H & diffLevel == i & laser)/sum(go & diffLevel == i & laser);
        FAR(i) = sum(FA & diffLevel == i & laser)/sum(noGo & diffLevel == i &laser);
        PERF(i) = (sum(H & diffLevel == i & laser) + sum(CR & diffLevel == i & laser))/(sum(go & diffLevel == i & laser) + sum(noGo & diffLevel == i & laser));
        mRT(i,1) = mean(RT(H & diffLevel == i & laser),'omitnan');
        mRT(i,2) = mean(RT(FA & diffLevel == i & laser),'omitnan');
    end
    
    dp = d_prime(HR,FAR);
    
    % H, FA, Perf
    subplot(1,3,1)
    hold all
    plot(1:4,HR*100,'o:b')
    plot(1:4,FAR*100,'o:r')
    plot(1:4,PERF*100,'o:k')
    set(gca,'xtick',1:4,'xticklabel',ylb)
    ylabel('(%)')
    xlabel('Stim intensities')
    setUpPlotCompact
    legend('Hits','FA','Performance')
    ylim([0 100])
    
    % D PRIME
    subplot(1,3,2)
    hold all
    plot(1:4,dp,'o:k')
    set(gca,'xtick',1:4,'xticklabel',ylb)
    ylabel('d-prime')
    xlabel('Stim intensities')
    setUpPlotCompact
    
    % REACTION TIME
    subplot(1,3,3)
    hold all;
    plot(1:4,mRT(:,1),'o:b')
    plot(1:4,mRT(:,2),'o:r')
    set(gca,'xtick',1:4,'xticklabel',ylb)
    ylabel('Reaction time (s)')
    xlabel('Stim intensities')
    setUpPlotCompact
    
end
