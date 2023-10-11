%
clear all; close all; clc;
setUpDirHFB;
cd(HFRootFolder);

% PARAMS ==================================================================
% ANIMAL ID
% if nargin < 1
anID = input('TONE CONDITIONING\nPlease enter animal ID:\n','s');
durTone = 0.5;
% end

% Define params
params = defineParamsConditioning(anID);
if ~isstruct(params) && isnan(params)
    return0
end

% N s ---
nTrials = params.nTrials;
amountReward = params.amountReward;

% Durations ---
durITI = params.durations.ITI; % [Mu Max]
durConsumption = params.durations.rewardConsumption; % Time after US
durPuff = params.durations.puff;
durPreReinforce = params.durations.preReinforcement; % Time between CS and US
durSess = params.durations.total; % Duration (is sec) of the session

% Tone selection ---
toneSelect = params.toneSelection; % %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral

% SETUP ===================================================================
durValveL = water_reward2duration(amountReward,2);

% Open communication with Arduino ---
[ardIn,ardOut] = lever_cardSetUpInOut;
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;
ARDUINO.idx = 1;

% Initialize variables ---
estSamplingRate = 100;
nSamples = estSamplingRate*60*30;

responseMTXheader = {'timeTrialStart';'timeTone';'timeReinforcement'};
respMTX = nan(nTrials,3);
nM = 0;
nH = 0;
% Randomize trials ---
MTXTrialType = conditioningRandomizeTrial(nTrials,toneSelect,durITI);

% Keyboard ---
if strcmp(computer,'MACI64')
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
end
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Sound ---
snd = soundInitIII;

% Reference movement ---
pause(2);

% For display
lickPreRate = nan(nTrials,3);
lickPostRate = nan(nTrials,3);
lickPreAvg = nan(nTrials,3);
lickPostAvg = nan(nTrials,3);
nPreAvg = 30;

% Create figure for performance display during behavior
c = setColor;
fig = figure;
setFigure('large')
subplot(1,2,1)
hold all;
hPre = plot(1:nTrials,lickPreRate,'x');
hPreAvg = plot(1:nTrials,lickPreAvg,'-');
set(hPre(1),'color',c.greenBlue)
set(hPre(2),'color',c.gray)
set(hPre(3),'color',c.red)
set(hPreAvg(1),'color',c.greenBlue)
set(hPreAvg(2),'color',c.gray)
set(hPreAvg(3),'color',c.red)
xlabel('Trial #');
ylabel('Lick rate (Hz)');
ylim([0 10]);
legend('Reward','Neutral','Punishment');
legend('boxoff')
grid on
title('Anticipatory');
setUpPlotCompact;

subplot(1,2,2)
hold all;
hPost = plot(1:nTrials,lickPostRate,'x');
hPostAvg = plot(1:nTrials,lickPostAvg,'-');
set(hPost(1),'color',c.greenBlue)
set(hPost(2),'color',c.gray)
set(hPost(3),'color',c.red)
set(hPostAvg(1),'color',c.greenBlue)
set(hPostAvg(2),'color',c.gray)
set(hPostAvg(3),'color',c.red)
xlabel('Trial #');
ylabel('Lick rate (Hz)');
ylim([0 15]);
grid on
title('Consummatory');
setUpPlotCompact;


% % Training
%%
% RUN TRIALS ==============================================================
% =========================================================================
ARDUINO.t0 = GetSecs;
idArd = 1; % index increase everytime arduino is sampled
N = 1;

while N <= nTrials && GetSecs - ARDUINO.t0 < durSess && ESC
    % Load params specific for each trial
    trialType = MTXTrialType(N,2);
    durITI = MTXTrialType(N,3);
    if trialType == 1
        soundID = 5;
    elseif trialType == 2
        soundID = 9;
    elseif trialType == 3
        soundID = 1;
    end
    
    % DISPLAY TRIAL NUMBER & TRIAL TYPE
    fprintf('\n\nTrials %i of %i (elapsed time %3.1f min): \n',N,nTrials,(GetSecs - ARDUINO.t0)/60);
    if trialType == 1
        fprintf('REW')
    elseif trialType == 2
        fprintf('NEUTRAL')
    elseif trialType == 3
        fprintf('PUNISH')
    end
    fprintf('\n');
    
    % ITI ==================================
    fprintf('ITI: %3.1f sec\n',durITI);
    fprintf(ardOut,'I'); % LED ON (BUT USE FOR OUTPUT EVENT)
    respMTX(N,1) = GetSecs - ARDUINO.t0; % TRIAL START
    ARDUINO = recMVT(ARDUINO,durITI);
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    fprintf(ardOut,'J'); % LED OFF (BUT USE FOR OUTPUT EVENT)
    
    
    % CONDITIONED STIM (CS) ====================
    respMTX(N,2) = GetSecs - ARDUINO.t0;
    fprintf('TONE\n');
    soundPlay(soundID,snd);
    
    % PRE-REINFORCEMENT ====================
    ARDUINO = recMVT(ARDUINO,durPreReinforce);
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    
    % UNCONDITIONED STIM (US)  ====================
    respMTX(N,3) = GetSecs - ARDUINO.t0;
    if trialType == 1
        durReinforce = durValveL;
        fprintf('REWARD\n')
        fprintf(ARDUINO.out,'E'); % LEFT VALVE
    elseif trialType == 3
        durReinforce = durPuff;
        fprintf('PUNISHMENT\n');
        fprintf(ARDUINO.out,'L'); % AIR LEFT
    elseif trialType == 2
        durReinforce = durPuff;
        fprintf('NEUTRAL\n');
    end
    ARDUINO = recMVT(ARDUINO,durReinforce);
    fprintf(ardOut,'O');
    fprintf(ardOut,'M');
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    
    % Post trial (consumption)  ========================================================================================
    ARDUINO = recMVT(ARDUINO,durConsumption);
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    
    % PRINT PERFORMANCE ========================================================================================
    % Lick rate during pre-reinforcement (sorted by reward/neutral/punish)
    t = ARDUINO.data(:,1);
    tCSend = respMTX(N,2);
    tUS = respMTX(N,3);
    idxPre = t >= tCSend & t <= tUS;
    lick = abs([0; diff(ARDUINO.data(:,3)) > 0]);
    lickPre = lick(idxPre);
    lickPreRate(N,trialType) = sum(lickPre)/(tUS - tCSend);
    idx = N-nPreAvg:N;
    idx = idx(idx > 0);
    lickPreAvg(N,:) = nanmean(lickPreRate(idx,:),1);
    
    % Lick rate during reinforcement/consumption
    tPost = tUS + durConsumption;
    idxPost = t >= tUS & t <= tPost;
    lickPost = lick(idxPost);
    lickPostRate(N,trialType) = sum(lickPost)/durConsumption;
    lickPostAvg(N,:) = nanmean(lickPostRate(idx,:),1);
    
    %     tic
    figure(fig)
    set(hPre(1),'YData',lickPreRate(:,1));
    set(hPre(2),'YData',lickPreRate(:,2));
    set(hPre(3),'YData',lickPreRate(:,3));
    set(hPreAvg(1),'YData',lickPreAvg(:,1));
    set(hPreAvg(2),'YData',lickPreAvg(:,2));
    set(hPreAvg(3),'YData',lickPreAvg(:,3));
    set(hPost(1),'YData',lickPostRate(:,1));
    set(hPost(2),'YData',lickPostRate(:,2));
    set(hPost(3),'YData',lickPostRate(:,3));
    set(hPostAvg(1),'YData',lickPostAvg(:,1));
    set(hPostAvg(2),'YData',lickPostAvg(:,2));
    set(hPostAvg(3),'YData',lickPostAvg(:,3));
    drawnow
    %     toc
    
    % ==============================================================================================================
    % Increment N %%%%%%%%%
    N = N+1;
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    
end

% Messages
if GetSecs - ARDUINO.t0 > durSess
    fprintf('Duration is greater than %4.1f sec (See ''params.durations.total''). Session ended.\n',durSess);
end
if ~ESC
    fprintf('Escape key pressed. Session ended\n');
end

%% SAVE  =======================================================

ARDUINO.data = ARDUINO.data(~isnan(ARDUINO.data(:,1)),:);
response.dataArduino = ARDUINO.data;
response.dataArduinoHeader = {'TimeMATLAB','MVT','LICK1','LICK2'};
response.respMTX = respMTX(1:N-1,:);
response.respMTXheader = responseMTXheader;

params.MTXTrialType = MTXTrialType;
params.MTXTrialTypeHeader = {'TRIAL#'; 'TRIALTYPE(1 rew / 2 neutral / 3 punish)'; 'durITI'};
[~,systName] = system('hostname');
params.systName = systName(1:end-1);

data.params = params;
data.response = response;

% Check or Create folder for anID
cd(HFRootFolder)
if exist('Data','dir') == 0
    mkdir(pwd,'Data');
end
if exist('Data\Conditioning','dir') == 0
    mkdir('Data','Conditioning');
end

if exist(['Data\Conditioning\AN' anID],'dir') == 0
    mkdir('Data\Conditioning',['AN' anID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
saveName = sprintf('Cond_AN%s_%s',anID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idArd = 1;
while exist(['Data\Conditioning\AN' anID '\' saveName '.mat'],'file') && idArd <= length(alphabets)
    if idArd == 1
        saveName(end+1) = alphabets(idArd);
    else
        saveName(end) = alphabets(idArd);
    end
    idArd = idArd+1;
end

% save
save(['Data\Conditioning\AN' anID '\' saveName],'data');

%% CLEAN UP =========================================

lever_cleanArduino(ARDUINO.in);
lever_cleanArduino(ARDUINO.out);


%% DISPLAY LICK RATE & LEVER PER TRIAL TYPE  ========================
arduinoDelay = 0.1;
win = [-durPreReinforce-2 durConsumption];
t = ARDUINO.data(:,1);
arduinoRate = mean(diff(t));
L = abs([0; diff(ARDUINO.data(:,3)) > 0]);
lev = abs([0; diff(ARDUINO.data(:,2))]);
tUS = respMTX(:,3)+arduinoDelay;
tUS = tUS(~isnan(tUS));
idxUS = nan(length(tUS),1);
for i = 1:length(tUS)
    idxUS(i) = find(t > tUS(i),1);
end
R = makeRaster(L,idxUS,round(win/arduinoRate));
R = R > 0;
levR = makeRaster(lev,idxUS,round(win/arduinoRate));

tR = linspace(win(1),win(2),size(R,2));

fig1 = figure;
c = setColor;
setFigure('tall')
tStr = {'Reward','Neutral','Punish'};
for i = 1:3
    if sum(MTXTrialType(1:N-1,2) == i) > 0
        figure(fig1)
        subplot(3,3,i)
        plotSpikeRaster(R(MTXTrialType(1:N-1,2) == i,:),'TimePerBin',arduinoRate,'rasterWindowOffset',win(1)*arduinoRate);
        title(tStr{i})
        ylabel('Trial #')
        setUpPlotCompact;
        
        subplot(3,3,i+3)
        [~, m, err] = estimateSpikeRateRaster(R(MTXTrialType(1:N-1,2) == i,:),log10(arduinoRate),5*arduinoRate);
        hold all;
        boundedline(tR,m,err,'k')
        ylim([0 15])
        h(1) = plot(-durPreReinforce*[1 1],ylim,'-','color',c.greenBlue);
        if i == 1
            h(2) = plot([0 0],ylim,'color',c.blue);
            legend(h,'CS - Tone','US - Water'); legend boxoff;
        elseif i == 2
            legend(h(1),'CS - Tone'); legend boxoff;
        elseif i == 3
            h(2) = plot([0 0],ylim,'color',c.red);
            legend(h,'CS - Tone','US - Puff'); legend boxoff;
        end
        xlim(win)
        ylabel('Lick rate (Hz)')
        setUpPlotCompact;
        
        subplot(3,3,i+6)
        [mLev,errLev] = mean_sem(levR(MTXTrialType(1:N-1,2) == i,:),1);
        hold all;
        boundedline(tR,mLev,errLev,'k')
        ylim([0 0.1])
        h(1) = plot(-durPreReinforce*[1 1],ylim,'-','color',c.greenBlue);
        if i == 1
            h(2) = plot([0 0],ylim,'color',c.blue);
            legend(h,'CS - Tone','US - Water'); legend boxoff;
        elseif i == 2
            legend(h(1),'CS - Tone'); legend boxoff;
        elseif i == 3
            h(2) = plot([0 0],ylim,'color',c.red);
            legend(h,'CS - Tone','US - Puff'); legend boxoff;
        end
        xlim(win)
        xlabel('Time - US aligned (s)')
        ylabel('Lever speed (a.u.)')
    end
end

fig2 = figure;
for i = 1:3
    [~, m, err] = estimateSpikeRateRaster(R(MTXTrialType(1:N-1,2) == i,:),log10(arduinoRate),5*arduinoRate);
    if ~isnan(m)
        
        figure(fig2)
        if i == 1
            col = c.blue;
        elseif i == 2
            col = c.gray;
        elseif i == 3
            col = c.red;
        end
        hold all
        h2(i) = boundedline(tR,m,err,'cmap',col);
        xlim(win)
        ylim([0 15])
        xlabel('Time - US aligned (s)')
        ylabel('Lick rate (Hz)')
        setUpPlot
    end
end
legend(h2,tStr,'location','best');