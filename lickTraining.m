function data = lickTraining(anID)
% EARLY TRAINING
% Simple behavior: detect lick and give reward.
% anID is optional;

% Params =================================

% ANIMAL ID
clc;
if nargin < 1
    anID = input('Please enter animal ID:\n','s');
end
setUpDirHFB_GF

% Define params
params = defineParams(anID);
if ~isstruct(params) && isnan(params)
    return
end

% N s ---
nTrials = params.nTrials;
amountReward = params.amountReward;

% Durations ---
dur_trialInitiation = 10;
dur_preReward = 0;
dur_ITI = 0.5;
dur_consumption = 0.5;


% SETUP ==================================
durValveR = water_reward2duration(amountReward,1); 
durValveL = water_reward2duration(amountReward,2); 

% Open communication with Arduino ---
[ardIn,ardOut] = lever_cardSetUpInOut_GF;

% Initialize variables ---
nSamples = 100*60*120; % Estimated sampling rate arduino x 60 sec/min x Estimated duration (2h)
tArd = nan(nSamples,1);
dataArd = nan(nSamples,4);
response.lickRightDetected = logical(zeros(nTrials,1));
response.lickLeftDetected = logical(zeros(nTrials,1));
response.timeLickDetected = nan(nTrials,1);
response.manualRightRew = logical(zeros(nTrials,1));
response.manualLeftRew = logical(zeros(nTrials,1));
response.timeManualRew = nan(nTrials,1);

% Keyboard --
if strcmp(computer,'MACI64')
    escapeKey = KbName('ESCAPE');
    manualLeftRewardKey = KbName('l');
    manualRightRewardKey = KbName('r');
else
    escapeKey = KbName('esc');
    manualLeftRewardKey = KbName('l');
    manualRightRewardKey = KbName('r');
end
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;
LREW = keyCode(manualLeftRewardKey) == 0;
RREW = keyCode(manualRightRewardKey) == 0;

% Sound ---
snd = soundInit;


%%

% RUN TRIALS ========================
% FUTURE: here will be the trigger
t0 = GetSecs;
k = 1; % index increase everytime arduino is sampled
N = 1;
% flushinput(ard);
% [t(k),y] = lever_readArduino(ard,t0);
% leverMVT(k) = y(1);
while N <= nTrials && ESC
    fprintf('\n\nTrials %i of %i:\n',N,nTrials);
    fprintf('---------------\n');
    
    % ITI ==================================
    fprintf('ITI: %3.1f sec\n',dur_ITI);
    tStart = GetSecs;
    deltaT = 0;
    flushinput(ardIn);
    while deltaT < dur_ITI && ESC
        dataArd(k,:) = lever_readArduino(ardIn,t0);
        k = k+1;
        deltaT = GetSecs - tStart;
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;
    end
    
    % Detect lick ================
    fprintf('Trial available!\n');
    %     soundPlay(3,snd);
    tStart = GetSecs;
    deltaT = 0;
    lickYesNo = false;
    response.lickLeftDetected(N) = false;
    response.lickRightDetected(N) = false;
    flushinput(ardIn);
    while deltaT < dur_trialInitiation && ~lickYesNo && LREW && RREW && ESC
        dataArd(k,:) = lever_readArduino(ardIn,t0);
        lickYesNo = dataArd(k,3) - dataArd(k-1,3) > 0 || dataArd(k,4) - dataArd(k-1,4) > 0;
        deltaT = GetSecs - tStart;
        k = k+1;
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;
        LREW = keyCode(manualLeftRewardKey) == 0;
        RREW = keyCode(manualRightRewardKey) == 0;
    end
    
    % Check outcome during trial initiation ====
    if lickYesNo
        fprintf('Hit');
        response.timeLickDetected(N) = dataArd(k-1,1);
        if dataArd(k-1,3) - dataArd(k-2,3) > 0
            fprintf(' Right\n');
            response.lickRightDetected(N) = true;
        elseif dataArd(k-1,4) - dataArd(k-2,4) > 0
            fprintf(' Left\n');
            response.lickLeftDetected(N) = true;
        end
    elseif ~RREW
        fprintf('Manual reward right\n');
        response.manualRightRew(N) = true;
        response.timeManualRew(N) = dataArd(k-1,1);
        RREW = true;
    elseif ~LREW
        fprintf('Manual reward left\n');
        response.manualLeftRew(N) = true;
        response.timeManualRew(N) = dataArd(k-1,1);
        LREW = true;
    elseif ~ESC
        fprintf('Escape key hit. End of program\n');
        soundStop(snd)
        break;
    else
        fprintf('Miss... (%3.1f sec)\n', dur_trialInitiation);
    end
    soundStop(snd)
    
    % Reward =======
    if response.lickLeftDetected(N) || response.lickRightDetected(N) || response.manualRightRew(N) || response.manualLeftRew(N)
        % Reward
        soundPlay(2,snd)
        tStart = GetSecs;
        deltaT = 0;
        if response.lickRightDetected(N) || response.manualRightRew(N)
            fprintf(ardOut,'W');
            dur_reward = durValveR;
        elseif response.lickLeftDetected(N) || response.manualLeftRew(N)
            fprintf(ardOut,'E');
            dur_reward = durValveL;
        end
        while deltaT < dur_reward
            dataArd(k,:) = lever_readArduino(ardIn,t0);
            deltaT = GetSecs - tStart;
            k = k+1;
        end
        fprintf(ardOut,'O');
        % Consumption
        tStart = GetSecs;
        deltaT = 0;
        while deltaT < dur_consumption && ESC
            dataArd(k,:) = lever_readArduino(ardIn,t0);
            deltaT = GetSecs - tStart;
            k = k+1;
            [~,~,keyCode] = KbCheck;
            ESC = keyCode(escapeKey) == 0;
        end
    end
    
    % Print performance line =================================
    nPercHitL = sum(response.lickLeftDetected);
    nPercHitR = sum(response.lickRightDetected);
    fprintf('N LEFT HITS: %i (%3.1f%%)\n',nPercHitL,nPercHitL/N*100);
    fprintf('N RIGHT HITS: %i (%3.1f%%)\n',nPercHitR,nPercHitR/N*100);
    
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    N = N+1;
end
fprintf(ardOut,'O');
%% SAVE

dataArd = dataArd(~isnan(dataArd(:,1)),:);
response.dataArduino = dataArd;
response.dataArduinoHeader = {'TimeMATLAB','MVT','LICK1','LICK2'};
response.timeLickDetected = response.timeLickDetected(1:N-1);
response.timeManualRew = response.timeManualRew(1:N-1);
response.lickLeftDetected = response.lickLeftDetected(1:N-1);
response.lickRightDetected = response.lickRightDetected(1:N-1);
response.manualRightRew = response.manualRightRew(1:N-1);
response.manualLeftRew = response.manualLeftRew(1:N-1);

data.params = params;
data.response = response;

% Check or Create folder for anID
cd(HFRootFolder_GF)
if exist('Data','dir') == 0
    mkdir(pwd,'Data');
end
if exist('Data\ToneDiscrimination','dir') == 0
    mkdir('Data','ToneDiscrimination');
end

if exist(['Data\ToneDiscrimination\AN' anID],'dir') == 0
    mkdir('Data\ToneDiscrimination',['AN' anID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
saveName = sprintf('LickTrainingData_AN%s_%s',anID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
k = 1;
while  exist(['Data\ToneDiscrimination\AN' anID '\' saveName '.mat'],'file') && k <= length(alphabets)
    if k == 1
        saveName(end+1) = alphabets(k);
    else
        saveName(end) = alphabets(k);
    end
    k = k+1;
end

% save
save(['Data\ToneDiscrimination\AN' anID '\' saveName],'data');

%% CLEAN UP
lever_cleanArduino(ardIn);
lever_cleanArduino(ardOut);

%% DISPLAY DATA ARDUINO

t = dataArd(:,1);
mvt = dataArd(:,2);

figure;
l = [diff(dataArd(:,3)); 0] > 0;
subplot(3,1,1);
hold all;
plot(t,l,'k');
plot(response.timeLickDetected,1,'xr');
plot(response.timeManualRew,1,'og');
legend('Lick','Timing reward','Timing manual','Location','best');
setUpPlotCompact
ylabel('Lick I/O');
title('Right spout')

l = [diff(dataArd(:,4)); 0] > 0;
subplot(3,1,2);
hold all;
plot(t,l,'k');
plot(response.timeLickDetected,1,'xr');
plot(response.timeManualRew,1,'og');
setUpPlotCompact
ylabel('Lick I/O');
title('Left spout')

subplot(3,1,3);
plot(t,mvt,'b');
setUpPlotCompact;
xlabel('Time (s)');
ylabel('MVT (V)');


