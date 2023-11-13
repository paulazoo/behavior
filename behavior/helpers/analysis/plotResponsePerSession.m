function plotResponsePerSession(an)

an = ANJoey
% Extract data table for that animal
Tbl = extractBehaviorPerSession(anJoey);

% Find date
FN = Tbl.FileName;
d = nan(length(FN),1);
for i = 1:length(FN)
    id = strfind(FN{i},'_');
    id = id(2);
    d(i) = datenum(FN{i}(id+1:id+11));
end

% Adjust date from first training day
d = d - d(1);

% Extract behavior from table
p_press = Tbl.ResponseTone;
ngfract = Tbl.NoGoFract;
hrcorr = Tbl.HitRateCorr;
e = Tbl.EarlyPress;
dp = Tbl.dPrime;
dp = dp(:,4:-1:1);
N = Tbl.NumberOfTrials;

% Extract hit and false alarm rate
h = p_press(:,8:-1:5);
fa = p_press(:,4:-1:1);

% Adjust hit rate to hit rate corrected for days with only go trials
h(ngfract < 0.3,1) = hrcorr(ngfract < 0.3);

% Create color tints for hit rate
c = setColor;
k = 1;
for t = 0:0.25:0.75
    cA(k,:) = tint(c.blue3,t);
    k = k+1;
end

% ----------------------------------
% Open figure
figure
setFigure('tall')
setFigure('narrow')

% Plot hit rate versus days
subplot(5,1,1)
hold all;
for i = 1:4
plot(d,h(:,i),'o-','color',cA(i,:))
end

% Add title
title(an)

% Adjust plot
ylim([0 100])
xlim([0 d(end)])
% xlabel('Days')
ylabel('Hit rate')
grid on
setUpPlotCompact

% Create color tints for false alarm rate
c = setColor;
k = 1;
for t = 0:0.25:0.75
    cA(k,:) = tint(c.red2,t);
    k = k+1;
end

% Plot false alarm rate versus days
subplot(5,1,2)
hold all
for i = 1:4
plot(d,fa(:,i),'o-','color',cA(i,:))
end


% Adjust plot
ylim([0 100])
xlim([0 d(end)])
% xlabel('Days')
ylabel('False alarm rate')
grid on
setUpPlotCompact

% Create color tints for dPrime
c = setColor;
k = 1;
for t = 0:0.25:0.75
    cA(k,:) = tint([0 0 0],t);
    k = k+1;
end

% Plot false alarm rate versus days
subplot(5,1,3)
hold all
for i = 1:4
plot(d,dp(:,i),'o-','color',cA(i,:))
end

% Adjust plot
ylim([-1 5])
xlim([0 d(end)])
% xlabel('Days')
ylabel('D-Prime')
grid on
setUpPlotCompact

% Plot Early presses
subplot(5,1,4)
plot(d,e,'-o','color',c.orange);

% Adjust plot
ylim([0 100])
xlim([0 d(end)])
% xlabel('Days')
ylabel('% Early press')
grid on
setUpPlotCompact

% Plot N Trials
subplot(5,1,5)
plot(d,N,'-o','color',c.gray);

% Adjust plot
% ylim([0 500])
xlim([0 d(end)])
xlabel('Days')
ylabel('N Trials')
grid on
setUpPlotCompact

% Plot table with data
T = extractBehavior4Drive(an,false);
figure; 
uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
