function displayChoice(response)

%% DISPLAY PERFO ==============================================

nAVG = 4; % Number of trial to average

nTrials = length(response.decision);
a = repmat(1:nAVG,nTrials-nAVG,1)- 2;
idTr = (1:nTrials-nAVG) + nAVG/2;
b = round(bsxfun(@plus,a,idTr'));
fractLeftRT = nansum(response.decision(b) == 2,2)/nAVG;
idCorrect = response.rewarded > 0;
idCorrUnrew = diff([response.blockType response.decision],[],2) == 0 & response.rewarded == 0;
idIncorr =  diff([response.blockType response.decision],[],2) ~= 0;

figure;
hold all;
h = area(1:nTrials,(response.blockType-1),'edgecolor','none','facecolor',[0.85 0.85 0.85],'basevalue',0);
h.BaseLine.LineStyle = 'none';
plot(idTr,fractLeftRT,'k','linewidth',1)



Y = idCorrect;
amp = -0.05;
a = zeros(sum(Y),3);
a(:,3) = nan;
a(:,1) = a(:,1) - 0.5;
a(:,2) = a(:,2) + 0.5;
x = 1:length(Y);
x = x(Y);
a = bsxfun(@plus,a,x')';
a = a(:);
b = ones(size(a))*amp;
b(isnan(a)) = nan;
plot(a,b,'g','linewidth',8)

Y = idCorrUnrew;
amp = -0.05;
a = zeros(sum(Y),3);
a(:,3) = nan;
a(:,1) = a(:,1) - 0.5;
a(:,2) = a(:,2) + 0.5;
x = 1:length(Y);
x = x(Y);
a = bsxfun(@plus,a,x')';
a = a(:);
b = ones(size(a))*amp;
b(isnan(a)) = nan;
plot(a,b,'y','linewidth',8)

Y = idIncorr;
amp = -0.05;
a = zeros(sum(Y),3);
a(:,3) = nan;
a(:,1) = a(:,1) - 0.5;
a(:,2) = a(:,2) + 0.5;
x = 1:length(Y);
x = x(Y);
a = bsxfun(@plus,a,x')';
a = a(:);
b = ones(size(a))*amp;
b(isnan(a)) = nan;
plot(a,b,'r','linewidth',8)

xlabel('Trial #')
ylabel('Fraction left choice')
set(gca,'ytick',[0 1])
ylim([-0.1 1.1])
xlim([0 nTrials])
setUpPlot





