function [lineHandle,results] = printPerfo(respMTX,MTXTrialType,N,lineHandle)
respWindow4Hit = 0.8; % Used for Hrate corrected

% PRINT PERFORMANCE ========================================================================================
RT = respMTX(:,4) - respMTX(:,2);
nH = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) > 0);
nM = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) < 1);
nFA = sum(MTXTrialType(:,2) < 1 & respMTX(:,3) > 0);
nCR = sum(MTXTrialType(:,2) < 1 & respMTX(:,3) < 1);
HRate = nH/sum(MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3)))*100;
HRateCorr = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) > 0 & RT < respWindow4Hit)/sum(MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3)))*100;
FARate = nFA/sum(MTXTrialType(:,2) < 1 & ~isnan(respMTX(:,3)))*100;
Perfo = (nH + nCR)/(nH + nM + nFA + nCR)*100;
Early = sum(respMTX(:,6) > 0)/N*100;

fprintf('SUMMARY TRIAL #%i:\n',N);
fprintf('H=%i\tM=%i\tFA=%i\tCR=%i\n',nH, nM,nFA,nCR)
fprintf('HR = %3.1f%%\tHRCORR = %3.1f%%\tFAR = %3.1f%%\tOVERALL = %3.1f%%\n',HRate,HRateCorr,FARate,Perfo)

results = [HRate,FARate,Perfo,Early];

%%
% DISPLAY PERFORMANCE ========================================================================================
% CUMULATIVE
nH = cumsum(MTXTrialType(:,2) > 0 & respMTX(:,3) > 0 & RT < respWindow4Hit);
nGo = cumsum(MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3)));
nM = cumsum(MTXTrialType(:,2) > 0 & respMTX(:,3) < 1);
nFA = cumsum(MTXTrialType(:,2) < 1 & respMTX(:,3) > 0);
nCR = cumsum(MTXTrialType(:,2) < 1 & respMTX(:,3) < 1);
cumH = bsxfun(@rdivide,nH,nGo)*100;
cumFA = bsxfun(@rdivide,nFA,nFA+nCR)*100;
cumPerfo = bsxfun(@rdivide,(nH + nCR),(nH + nM + nFA + nCR))*100;
nTot = length(MTXTrialType);
cumTot = 1:length(MTXTrialType);
cEarl = bsxfun(@rdivide,cumsum(respMTX(:,6) > 0),cumTot')*100;

% PAST 50 TRIALS
nPast = 50;

idAVG = bsxfun(@plus,repmat((-nPast+1:0),nTot,1),(1:nTot)');
idx2rem = min(nPast-1,size(idAVG,1));
idAVG(1:idx2rem,:) = []; % Removes first trials since not enough for averaging
H = MTXTrialType(:,2) > 0 & respMTX(:,3) > 0 & RT < respWindow4Hit;
Go = MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3));
M = (MTXTrialType(:,2) > 0 & respMTX(:,3) < 1);
FA = (MTXTrialType(:,2) < 1 & respMTX(:,3) > 0);
CR = (MTXTrialType(:,2) < 1 & respMTX(:,3) < 1);
Earl = respMTX(:,6) > 0;
H = H(idAVG);
Go = Go(idAVG);
M = M(idAVG);
FA = FA(idAVG);
CR = CR(idAVG);
Earl = Earl(idAVG);
Hpast = bsxfun(@rdivide,mean(H,2),mean(Go,2))*100;
FApast = bsxfun(@rdivide,mean(FA,2),mean(FA,2)+mean(CR,2))*100;
PerfPast = bsxfun(@rdivide,(mean(H,2) + mean(CR,2)),(mean(H,2) + mean(M,2) + mean(FA,2) + mean(CR,2)))*100;
EarlPast = sum(Earl,2)./nPast*100;

x = 1:nTot;
x(isnan(respMTX(:,1))) = nan;
xPast = nPast:nTot;
xPast(isnan(respMTX(nPast:nTot,1))) = nan;
if nargin < 4
    figure;
    pos = get(gcf,'position');
    set(gcf,'position',[pos(1)-pos(3)/2 pos(2) pos(3)*2 pos(4)]);
    
    subplot(1,2,1);
    hold all;
    lineHandle.l1 = line(x,cumH,'linewidth',1,'color','g');
    lineHandle.l2 = line(x,cumFA,'linewidth',1,'color','r');
    lineHandle.l3 = line(x,cumPerfo,'linewidth',2,'color','k');
    lineHandle.l4 = line(x,cEarl,'linewidth',1,'color','b');
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
    lineHandle.l5 = line(xPast,Hpast,'linewidth',1,'color','g');
    lineHandle.l6 = line(xPast,FApast,'linewidth',1,'color','r');
    lineHandle.l7 = line(xPast,PerfPast,'linewidth',2,'color','k');
    lineHandle.l8 = line(xPast,EarlPast,'linewidth',1,'color','b');
    setUpPlotCompact;
    grid on
    xlabel('Trial #');
    ylabel('%');
    ylim([0 101]);
    title(['Average of past ' num2str(nPast) ' trials']);

else
    set(lineHandle.l1,'Xdata',x,'Ydata',cumH);
    set(lineHandle.l2,'Xdata',x,'Ydata',cumFA);
    set(lineHandle.l3,'Xdata',x,'Ydata',cumPerfo);
    set(lineHandle.l4,'Xdata',x,'Ydata',cEarl);
    set(lineHandle.l5,'Xdata',xPast,'Ydata',Hpast);
    set(lineHandle.l6,'Xdata',xPast,'Ydata',FApast);
    set(lineHandle.l7,'Xdata',xPast,'Ydata',PerfPast);
    set(lineHandle.l8,'Xdata',xPast,'Ydata',EarlPast);

    drawnow
end

