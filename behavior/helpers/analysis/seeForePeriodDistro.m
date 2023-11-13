close all; clc; clear all;

% Dur foreperiod
nTrials = 2000000;
foreperiod = [0.65 0.15];
durFore = -ones(nTrials,1);
while any(durFore < 0) % Negative values get re-shuffled
    i = durFore < 0;
    N = sum(i);
    durFore(i) = randn(1,N)*foreperiod(2)+foreperiod(1);
end
% durFore = round(durFore,2);

figure;
pos = get(gcf,'position')
set(gcf,'position',[pos(1) pos(2) pos(3)*0.75 pos(4)/2])
h = histogram(durFore,0:0.01:2,'normalization','probability','displaystyle','stairs','edgecolor',[0  0 0],'linewidth',1);
setUpPlot
xlabel('Foreperiod (s)')
ylabel('Probability')