% 
% % Params =================================
clear all; close all; clc;
setUpDirHFB_GF

% % ANIMAL ID
% clc;
% if nargin < 1
    anID = input('Please enter animal ID:\n','s');
    
% end

% anID = '01';
% Define params
params = defineParams(anID);
if ~isstruct(params) && isnan(params)
    return
end

% N s ---
nTrials = params.nTrials;
amountReward = params.amountReward;
nConsecLick = params.nConsecLick;
nTrialPerBlock = params.nTrialPerBlock;
fractRew = params.fractRew;
fractFreeTrial = params.fractFreeTrial;

% Durations ---
dur_trialInitiation = params.durations.trialInitiation;
dur_preReward = params.durations.preReward;
dur_ITI = params.durations.ITI;
dur_consumption = params.durations.rewardConsumption;
dur_postTrial = params.durations.postTrial;
dur_decision = params.durations.decision;

% Detection ---
mvt_thresh = params.mvt.thresh; % in Volts to initiate a trial
noMvt_thresh = params.mvt.noMvtThresh;

% Switches
moveSpoutIO = params.moveSpoutIO;
alt = params.alternateIO;

%% SETUP ==================================

durValveR = water_reward2duration(amountReward,1); 
durValveL = water_reward2duration(amountReward,2); 

% Open communication with Arduino ---
[ardIn,ardOut] = lever_cardSetUpInOut;

% Initialize variables ---
estSamplingRate = 100;
nSamples = estSamplingRate*60*30;
tArd = nan(nSamples,1);
dataArd = nan(nSamples,4);
response.timeTrialStart = nan(nTrials,1);
response.leverPressed = logical(zeros(nTrials,1));
response.timeLeverPressed = nan(nTrials,1);
response.MVT0  = nan(nTrials,1);
response.decision = nan(nTrials,1);
response.timeDecision = nan(nTrials,1);
response.rewarded = nan(nTrials,1);
response.blockID = nan(nTrials,1);
response.blockType = nan(nTrials,1);
response.rewID = nan(nTrials,1);

% % Randomize trials
% MTXTrialType = choiceSwitchRandomizeTrial(nTrials,nTrialPerBlock,fractRew,fractFreeTrial);
% response.blockID = MTXTrialType(:,2);
% response.blockType = MTXTrialType(:,3);
% response.rewID = MTXTrialType(:,4);

% Keyboard --
if strcmp(computer,'MACI64'); 
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc'); 
end
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Sound ---
snd = soundInit;

% Retract spout --
if moveSpoutIO
    fprintf(ardOut,'L');
    WaitSecs(0.2);
    fprintf(ardOut,'M');
end
%%

% Reference movement ===============
fprintf('Finding MVT0\n');
nRefMVT = 100;
BLFlag = true;
ii = 1;
while BLFlag
MVTBL = nan(nRefMVT,1);
flushinput(ardIn);
for i = 1:nRefMVT;
    d = lever_readArduino(ardIn,0);
    MVTBL(i) = d(2);
end

        if max(std(MVTBL))<0.05
%             MVT0 = nanmedian(MVTBL);
            BLFlag = false;
            fprintf('Measured BL:  %1.3f\n',nanmedian(MVTBL))
        else
            ii = ii + 1;
            fprintf('Try again #%d\n',ii)
        end
end
pause(2);

% RUN TRIALS ========================
% FUTURE: here will be the trigger
t0 = GetSecs;
k = 1; % index increase everytime arduino is sampled
N = 1;
NEWBLOCKFLAG = true;
% flushinput(ard);
% [t(k),y] = lever_readArduino(ard,t0);
% leverMVT(k) = y(1);
while N <= nTrials && ESC
    
    
    % TRIAL TYPE SELECTION ================================================
    % If new block pick block and Reward
    if NEWBLOCKFLAG
        if N == 1
            % If first trial pick randomly the blockType
            response.blockID(N) = 1;
            response.blockType(N) =randi(2,1);
            nRewarded2Switch = min(nTrialPerBlock); % FIRST BLOCK ALWAYS THE SHORTEST. Helps with bias?
        else
            response.blockID(N) = response.blockID(N-1)+1;
            nRewarded2Switch = randi([nTrialPerBlock(1) nTrialPerBlock(end)],1,1);
            if response.blockType(N-1) == 1
                response.blockType(N) = 2;
            else
                response.blockType(N) = 1;
            end
        end
        NEWBLOCKFLAG = false;
        nRewInBlock = 0;
    else % If not new blockType = prev blockType and blockID = prev blockID
        response.blockID(N) = response.blockID(N-1);
        response.blockType(N) = response.blockType(N-1);
    end
    
    % Pick rewID
    response.rewID(N) = response.blockType(N);
    if rand > fractRew
        response.rewID(N) = 0;
    end
    if rand < fractFreeTrial
        response.rewID(N) = 3;
    end
    
    % DISPLAY TRIAL NUMBER & TRIAL TYPE
    fprintf('\n\nTrials %i of %i:\n',N,nTrials);
    fprintf('Block: ');
    if response.blockType(N) == 1
        fprintf('RIGHT')
    elseif response.blockType(N) == 2
        fprintf('LEFT')
    end
    if response.rewID(N) == 3
        fprintf(' ...FREE REWARD!');
    end
    fprintf('\n');

    % ITI ==================================
    fprintf('ITI: %3.1f sec\n',dur_ITI);
    tStart = GetSecs;
    deltaT = 0;
    flushinput(ardIn);
    deltaMVT = 0;
    FIRSTFLAG = true;
    if k == 1; lastMVT = nanmedian(MVTBL); end
    while deltaT < dur_ITI && ESC
        dataArd(k,:) = lever_readArduino(ardIn,t0);
        k = k+1;
        deltaT = GetSecs - tStart;
        deltaMVT = abs(dataArd(k-1,2)-lastMVT);
        lastMVT = dataArd(k-1,2);
        if deltaMVT > noMvt_thresh;
            if FIRSTFLAG
                fprintf('Extended delay, lever moved.');
                FIRSTFLAG = false;
            else
                fprintf('.');
            end
            tStart = GetSecs;
        end
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;
    end
    id0 = dataArd(:,1) > dataArd(k-1,1) - dur_ITI;
    response.MVT0(N) = nanmedian(dataArd(id0,2));% calculate BL based on ITI
    
    % Detect lever pressing ================
    fprintf('Trial available! ');
    response.timeTrialStart(N) = GetSecs - t0;
    soundPlay(3,snd);
    tStart = GetSecs;
    deltaT = 0;
    currMVT = 0;
    response.leverPressed(N) = false;
    flushinput(ardIn);
    while deltaT < dur_trialInitiation && currMVT < mvt_thresh && ESC
        dataArd(k,:) = lever_readArduino(ardIn,t0);
        currMVT = dataArd(k,2)-response.MVT0(N);
        deltaT = GetSecs - tStart;
        k = k+1;
        
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;
    end
    if currMVT > mvt_thresh;
        fprintf('Lever pressed\n');
        response.leverPressed(N) = true;
        response.timeLeverPressed(N) = dataArd(k-1,1);
    elseif ~ESC
        fprintf('ESC pressed. Exit behavior!\n');
    else
        fprintf('Trial initiation timeout (%3.1f sec)\n', dur_trialInitiation);
%         Reset reward and block ID
        response.blockID(N+1:end) = response.blockID(N:end-1);
        response.blockType(N+1:end) = response.blockType(N:end-1);
        response.rewID(N+1:end) = response.rewID(N:end-1);
    end
    soundStop(snd)
    
    % Decision and Reward =======
    if response.leverPressed(N)
        % Pre-reward delay move spout FWD - Licks also count during this
        % time has sometime spout move faster
        tStart = GetSecs;
        deltaT = 0;
        soundPlay(2,snd);
        decisionFLAG = true;
        consecLick = zeros(nConsecLick,2);
        kk = 1;
        while deltaT < dur_preReward && decisionFLAG
            if moveSpoutIO; fprintf(ardOut,'R'); end
            dataArd(k,:) = lever_readArduino(ardIn,t0);
            deltaT = GetSecs - tStart;
            R = dataArd(k,3) - dataArd(k-1,3) > 0;
            L = dataArd(k,4) - dataArd(k-1,4) > 0;
            k = k+1;
            if R
                consecLick(kk,1) = 1;
                kk = kk+1;
            elseif L
                consecLick(kk,2) = 1;
                kk = kk+1;
            end
            if kk > nConsecLick
                decisionFLAG = false;
            end
        end
        if moveSpoutIO; fprintf(ardOut,'S'); end
        
        % Decision (Lick L or R for nConsecLick)
        tStart = GetSecs;
        deltaT = 0;
        while deltaT < dur_decision && decisionFLAG
            dataArd(k,:) = lever_readArduino(ardIn,t0);
            deltaT = GetSecs - tStart;            
            R = dataArd(k,3) - dataArd(k-1,3) > 0;
            L = dataArd(k,4) - dataArd(k-1,4) > 0;
            k = k+1;
            if R
                consecLick(kk,1) = 1;
                kk = kk+1;
            elseif L
                consecLick(kk,2) = 1;
                kk = kk+1;
            end
            if kk > nConsecLick
                decisionFLAG = false;
            end
        end
        
        % Evaluate decision (R = 1 L = 2 or Both = -2 or Missed = -1)
        consecLick = sum(consecLick,1) > 0;
        response.timeDecision(N) = dataArd(k-1,1);
        if consecLick(1) > 0 && consecLick(2) == 0
            fprintf('RIGHT\n')
            response.decision(N) = 1;
        elseif consecLick(1) == 0 && consecLick(2) > 0
            fprintf('LEFT\n')
            response.decision(N) = 2;
        elseif consecLick(1) > 0 && consecLick(2) > 0
            fprintf('BOTH\n')
            response.decision(N) = -2;
        else
            fprintf('MISSED\n')
            response.decision(N) = -1;
        end
        
        response.rewarded(N) = false;
        if response.rewID(N) == response.decision(N)
            response.rewarded(N) = true;
        elseif alt && response.decision(N) ~= -1
            response.rewarded(N) = true;
        elseif response.rewID(N) == 3 && any(response.decision(N) == [1 2])
            response.rewarded(N) = true;
        end
        
        if response.rewarded(N)
            % Reward
            tStart = GetSecs;
            deltaT = 0;
            if response.rewID(N) == 1 % RIGHT
                fprintf(ardOut,'W');
                dur_reward = durValveR;
            elseif response.rewID(N) == 2 % LEFT
                fprintf(ardOut,'E');
                dur_reward = durValveL;
            elseif response.rewID(N) == 3 % Both side
                if response.decision(N) == 1
                    fprintf(ardOut,'W');
                    dur_reward = durValveR;
                elseif response.decision(N) == 2
                    fprintf(ardOut,'E');
                    dur_reward = durValveL;
                end
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
            while deltaT < dur_consumption
                dataArd(k,:) = lever_readArduino(ardIn,t0);
                deltaT = GetSecs - tStart;
                k = k+1;
            end
        end
    end
    
    % Post trial time (retract spout)0
    tStart = GetSecs;
    deltaT = 0;
    while deltaT < dur_postTrial && ESC
        if moveSpoutIO; fprintf(ardOut,'L'); end
        dataArd(k,:) = lever_readArduino(ardIn,t0);
        deltaT = GetSecs - tStart;
        k = k+1;
    end
    if moveSpoutIO; fprintf(ardOut,'M'); end
    
    % Evaluate n Rew in Block =============
    if response.rewID(N) == response.decision(N)
        nRewInBlock = nRewInBlock+1;
    end
    if nRewInBlock == nRewarded2Switch
        NEWBLOCKFLAG = true;
    end

    % PRINT PERFORMANCE ========================================================================================
    nDecisionR = sum(response.decision(1:N) == 1);
    nRwhenR = sum(response.blockType(1:N) == 1 & response.decision(1:N) == 1 & ~isnan(response.decision(1:N)));
    nR = sum(response.blockType(1:N) == 1 & ~isnan(response.decision(1:N)));
    nDecisionL = sum(response.decision(1:N) == 2);
    nLwhenL = sum(response.blockType(1:N) == 2 & response.decision(1:N) == 2 & ~isnan(response.decision(1:N)));
    nL = sum(response.blockType(1:N) == 2 & ~isnan(response.decision(1:N)));
    nMiss = sum(response.decision(1:N) == -1);
    nBoth = sum(response.decision(1:N) == -2);
    nNoLever = sum(isnan(response.decision(1:N)));
    
    
    fprintf('SUMMARY TRIAL #%i:\n',N);
    fprintf('L=%i\tR=%i\tM=%i\tB=%i\tN/L=%i\n',nDecisionL, nDecisionR,nMiss,nBoth,nNoLever)
    fprintf('CORR LEFT = %3.1f%%\tRIGHT = %3.1f%%\tOVERALL = %3.1f%%\n',nLwhenL/nL*100,nRwhenR/nR*100,(nLwhenL+nRwhenR)/(nL+nR)*100)
    fprintf('BIAS: PERCENTAGE LEFT = %3.1f%%\n',nDecisionL/(nDecisionL + nDecisionR)*100)    
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    N = N+1;
end

%% SAVE

dataArd = dataArd(~isnan(dataArd(:,1)),:);
response.dataArduino = dataArd;
response.dataArduinoHeader = {'TimeMATLAB','MVT','LICK1','LICK2'};

response.timeTrialStart = response.timeTrialStart(1:N-1);
response.leverPressed = response.leverPressed(1:N-1);
response.timeLeverPressed = response.timeLeverPressed(1:N-1);
response.MVT0 = response.MVT0(1:N-1);
response.MVTBL = MVTBL;
response.decision = response.decision(1:N-1);
response.timeDecision = response.timeDecision(1:N-1);
response.blockID = response.blockID(1:N-1);
response.blockType = response.blockType(1:N-1);
response.rewarded = response.rewarded(1:N-1);
response.rewID = response.rewID(1:N-1);

data.params = params;
data.response = response;

% Check or Create folder for anID
if exist('Data','dir') == 0
    mkdir(pwd,'Data');
end

if exist(['Data\AN' anID],'dir') == 0
    mkdir('Data',['AN' anID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
saveName = sprintf('Data_AN%s_%s',anID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
k = 1;
while exist(['Data\AN' anID '\' saveName '.mat'],'file') && k <= length(alphabets)
    if k == 1
        saveName(end+1) = alphabets(k);
    else
        saveName(end) = alphabets(k);
    end
    k = k+1;
end

% save
save(['Data\AN' anID '\' saveName],'data');

%% DISPLAY PERFO ==============================================
displayChoice(response)
displayMVTandLICK(response)
%% CLEAN UP =======================================================
fprintf(ardOut,'O');
lever_cleanArduino(ardIn);
lever_cleanArduino(ardOut);
