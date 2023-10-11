clear all; close all; clc;
setUpDirHFB_GF;
cd(HFRootFolder_GF);
 

% NOTES ON VERSION 3: Uses new way to read arduino (need to upload
% behaviorINV2 to arduino 'input'). Incorporate optogenetics code 3
% (inactivate at reinforcement). New way to initialize graph. New behavior
% performance graph at the end. (Saved in 'Figures' folder for each animal)

%% PARAMS ==================================================================
% ANIMAL ID
% cl
% if nargin < 1
anID = input('Please eJOnter animal ID:\n','s');
userID = input('Please enter your text ID (Ex.: VBP or GD or DHY):\n','s');
if isempty(userID)
    reply = 'gd';
end
% end


% Define params
params = defineParamsToneDiscrimination_GF(anID);
if ~isstruct(params) && isnan(params)
    returnARDUINO
end

% N s ---
nTrials = params.nTrials;
amountReward = params.amountReward;
fractNoGo = params.fractNoGo;
fractRewCR = params.fractRewCorrRej; %fraction of correct rejection trials that are rewarded; in most case it is zero. but reviewer asked for it so might as well try that.
if fractRewCR > 1
    fractRewCR = 1;
end
% Ask user if reward surprise is okay
if fractRewCR >0.001
    str = sprintf('Warning: Reward surprise mode is selected, is that OKAY? Y/N [Y]:\n');
    reply = input(str,'s');
    if isempty(reply)
        reply = 'Y';
    end
    if strcmp(reply,'N') || strcmp(reply,'n')
        fprintf('Exit!\n');
        return
    end
end

% Durations ---
foreperiod = params.durations.foreperiod;
% dur_preReward = params.durations.preReward;
durITI = params.durations.ITI;
durConsumption = params.durations.rewardConsumption;
durDecision = params.durations.decision;
durPuff = params.durations.puff;
durPreReinforce = params.durations.preReinforcement; 

% Detection ---
mvt_thresh = params.mvt.thresh; % in Volts to initiate a trial
noMvt_thresh = params.mvt.noMvtThresh;

% Tone selection --- 
toneSelect = params.toneSelection; % Range from 1o 4. 1 means only max. 2 means two max, ... and 4 all tone intensities

% Switches
% punishIO = params.punish;
trainingIO = params.training; % True for training for FA. Next trial is No-GO

% Auto-stop / Messaged
maxMiss = params.maxMiss; % NOT IMPLEMENTED YET Maximum miss trials in a row. Use nan for no limits
maxTotHits = params.maxTotHits; % Maximum total of hits. Use nan for no limits.
tMessages = 900; % In seconds, time interval to display messages

% Laser
paramsLaser = params.laser; %fractLaser trials; ntrial baseline (at the beginning of a session)
params.laserCtrlIO = true;
laserMode = paramsLaser(3);
laserFract = paramsLaser(1);


%Check up laser
if paramsLaser(1) > 0 %Ask if laser are ctrl experiments
    str = sprintf('Warning: %s is selected as the optogenetic mode, OKAY? Y/N [Y]:\n',params.laserExp{laserMode});
    reply = input(str,'s');
    if isempty(reply)
        reply = 'Y';
    end
    if strcmp(reply,'N') || strcmp(reply,'n')
        fprintf('Exit!\n');
        return
    end

    reply = input('Are these control laser experiments? Y/N [N]:','s');
    if isempty(reply)
        reply = 'N';
    end
    if strcmp(reply,'N') || strcmp(reply,'n')
        params.laserCtrlIO = false;
    end
    
    reply = input('Location? LC=1 PFC=2 MC=3 [1]:');
    if isempty(reply)
        reply = 1;
    end
    if any(reply == [1,2,3])
        params.laserLocation = reply;
    else
        params.laserLocation = nan;
    end
end

% Verification that dur pre-reinforcement is larger than 0 if laser mode 3
% is selected.
if laserMode == 3 && durPreReinforce < 0.01
    error('You cannot use this laser mode if durPreReinforce is set to 0 sec')
end
%% SETUP ===================================================================
durValveL = water_reward2duration(amountReward,2);

% Open communication with Arduino ---
[ardIn,ardOut] = lever_cardSetUpInOutV2_GF;
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;
ARDUINO.idx = 1;

% Initialize variables ---
estSamplingRate = 250;
estDur = 70; %minutes
nSamples = estSamplingRate*60*estDur;
ARDUINO.data = nan(nSamples,7);

responseMTXheader = {'timeTrialStart';'timeTone';'leverPressed';'timePressed';'MVT0';'earlyPress';'rew'};
respMTX = nan(nTrials,7);
nM = 0;
nH = 0;
% Randomize trials ---
MTXTrialType = toneDiscrRandomizeTrial(nTrials,toneSelect,fractNoGo,foreperiod.settings, paramsLaser);

% If opto mode == 3 or 4; 0 laser trial. it will be determined while running
% trials instead
if any(laserMode == [3 4])
    MTXTrialType(:,5) = 0;
end

% Keyboard ---
if strcmp (computer,'MACI64')
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
end
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Sound ---
snd = soundInitII;
vol = [35:-10:5 35:-10:5]; % BASED ON CALIBRATION

% Reference movement ---
fprintf('Finding MVT0\n');
MVTBL = referenceMVTV2(ARDUINO,100);
pause(2);

% Training
noGoSwitch = false;
goSwitch = false;
% Timing message
tNextMessage = tMessages;

% Initialize graph
lh = initializePrintPerfo(nTrials);


%% RUN TRIALS ==============================================================
% =========================================================================
% FUTURE: here will be the trigger
ARDUINO.t0 = tic;
% idArd = 1; % index increase everytime arduino is sampled
N = 1;
% flushinput(ard);
% [t(k),y] = lever_readArduino(ard,t0);
% leverMVT(k) = y(1);

while N <= nTrials && ESC
    % For training mode
    if noGoSwitch
        MTXTrialType(N,2) = 0;
        MTXTrialType(N,3) = 1;
    end
%     if goSwitch
%         MTXTrialType(N,2) = 1;
%         MTXTrialType(N,3) = 5;
%     end
    
    % Load params specific for each trial 
    trialType = MTXTrialType(N,2);
    soundID = MTXTrialType(N,3);
    durFore = MTXTrialType(N,4);
    
    laserIO = MTXTrialType(N,5);
        
    % DISPLAY TRIAL NUMBER & TRIAL TYPE
    fprintf('\n\nTrials %i of %i: ',N,nTrials);
    if trialType > 0
        fprintf('GO')
    elseif trialType < 1
        fprintf('NO-GO')
    end
    fprintf('\n');
        
    % ITI ==================================
    fprintf('ITI: %3.1f sec\n',durITI);
    fprintf(ardOut,'I'); % LED ON
    FIRSTFLAG = true;
    isMVT = true;
    while isMVT && ESC
        if ARDUINO.idx == 1
            MVT0 = mean(MVTBL);
        else
            MVT0 = ARDUINO.data(ARDUINO.idx-1,2);
        end
        paramsDetectMVT = [durITI MVT0 noMvt_thresh];
        [ARDUINO,isMVT] = detectMVTV2(ARDUINO,paramsDetectMVT,escapeKey);
        if isMVT
            if FIRSTFLAG
                fprintf('Extended delay, lever moved.');
                FIRSTFLAG = false;
            else
                fprintf('.');
            end
        end
        
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;
    end
    fprintf(ardOut,'J'); % LED OFF 
    id0 = ARDUINO.data(:,1) > ARDUINO.data(ARDUINO.idx-1,1) - durITI;
    MVT0 = median(ARDUINO.data(id0,2),'omitnan');% calculate BL based on ITI
    respMTX(N,5) = MVT0;
    
    % LASER ON - ARCH EXPERIMENTS =====================================
    if laserIO > 0 && laserMode == 1
        fprintf(ardOut,'A'); % Send a pulse to digidata
        fprintf('LASER!')
    end
    
    % FOREPERIOD ==================================
    fprintf('\nForeperiod(%1.2f sec)\n',durFore);
    respMTX(N,1) = toc(ARDUINO.t0); % TRIAL START
    paramsDetectMVT = [durFore MVT0 mvt_thresh];
    [ARDUINO,isMVT,ESC] = detectMVTV2(ARDUINO,paramsDetectMVT,escapeKey);
    if isMVT
        fprintf('Lever pressed. Return to ITI\n');
        respMTX(N,6) = true;
        respMTX(N,4) = ARDUINO.data(ARDUINO.idx-1,1);
        % LASER OFF HERE NOT IMPLEMENTED YET <<<<<<<<<<<<<<<<<<<<<<<<<
    elseif ~ESC
        fprintf('ESC pressed. Exit behavior!\n');
        % LASER OFF HERE NOT IMPLEMENTED YET <<<<<<<<<<<<<<<<<<<<<<<<<
    else
        fprintf('Tone  %i dB  @ (%3.1f sec)\n', vol(soundID), durFore);
        respMTX(N,6) = false;
        respMTX(N,2) = toc(ARDUINO.t0);
        % LASER ON - ChR2 EXPERIMENTS =====================================
        if laserIO > 0 && laserMode == 2
            fprintf(ardOut,'A'); % Send a pulse to digidata
            fprintf('LASER!')
        end        
        soundPlay(soundID,snd);
    end
    
    if respMTX(N,6) < 1
        % RESPONSE ================
        paramsDetectMVT = [durDecision MVT0 mvt_thresh];
        [ARDUINO,isMVT,ESC] = detectMVTV2(ARDUINO,paramsDetectMVT,escapeKey);
        if isMVT
            fprintf('Lever pressed\n');
            respMTX(N,3) = true;
            respMTX(N,4) = ARDUINO.data(ARDUINO.idx-1,1);
        elseif ~ESC
            fprintf('ESC pressed. Exit behavior!\n');
        else
            fprintf('No response\n');
            respMTX(N,3) = false;
        end
        
        % PRE-REINFORCEMENT ====================
        %%LASER ON - ARCH LASER DURING REINFORCEMENT
        if isMVT && laserMode == 3 && N > paramsLaser(2)
            % Determine if it is a laser trial
            if rand <= laserFract
                MTXTrialType(N,5) = 1;
                fprintf(ardOut,'A'); % Send a pulse to digidata
                fprintf('LASER (Pre-Reinf.)!\n')
            end
        end
        
        % RECORD MVT DURING PRE-REINFORCEMENT
        ARDUINO = recMVTV2(ARDUINO,durPreReinforce);
        
        % REINFORCEMENT ==============
        if trialType > 0
            durReinforce = durValveL;
%             durPost = dur_consumption;
            if isMVT
                fprintf('HIT\n')
                % HIT: Water reward
                fprintf(ARDUINO.out,'E'); % LEFT VALVE
                respMTX(N,7) = true;
                nH = nH + 1 ; % Total number of hits
            elseif ~isMVT
                fprintf('MISS\n');
                respMTX(N,7) = false;
            end
        elseif trialType < 1
            durReinforce = durPuff;
            if isMVT
                fprintf('FALSE ALARM\n');
                respMTX(N,7) = false;
                % FALSE ALARM: Air Puff
                fprintf(ARDUINO.out,'L'); % AIR LEFT
%                 durPost = 2*dur_consumption;
            elseif ~isMVT
                fprintf('CORR. REJECTION\n');
                respMTX(N,7) = false;
                if fractRewCR > 0
                    durReinforce = durValveL;
                    if rand > 1-fractRewCR
                       if laserMode == 4 && N > paramsLaser(2)
                           % Determine if it is a laser trial
                           if rand <= laserFract
                               MTXTrialType(N,5) = 1;
                               fprintf(ardOut,'A'); % Send a pulse to digidata
                               fprintf('LASER (SURPRISE)!\n')
                           end
                       end
                        fprintf('REWARD SURPRISE!!!\n');
                        fprintf(ARDUINO.out,'E'); % LEFT VALVE
                        respMTX(N,7) = true;
                    end
                end
%                 durPost = dur_consumption;
            end
        end
        ARDUINO = recMVTV2(ARDUINO,durReinforce);
        fprintf(ardOut,'O');
        fprintf(ardOut,'M');
        
        
        % Post trial (consumption)  ========================================================================================
        ARDUINO = recMVTV2(ARDUINO,durConsumption);
        fprintf(ardOut,'I'); % LED ON
        
        % PRINT PERFORMANCE ========================================================================================
%         tic
        if ~exist('lh')
            lh = printPerfo(respMTX,MTXTrialType,N);
        else
            lh = printPerfo(respMTX,MTXTrialType,N,lh);
        end
%         toc
        
        % FOR training mode. Repeat no-go trial if previous FA.
        if trainingIO > 0
            if MTXTrialType(N,2) < 1 && respMTX(N,3) > 0;
                noGoSwitch = true;
            else
                noGoSwitch = false;
            end
        end
        % FOR training mode. Repeat GO trial if previous MISS.
        if trainingIO > 0
            if MTXTrialType(N,2) == 1 && respMTX(N,3) == 0;
                goSwitch = true;
            else
                goSwitch = false;
            end
        end
        
    end
    
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
    
    % AUTO STOPS & TEXT ALERTS =======================================================================
    % Stop if nM > maxMiss 
    %if nM > maxMiss
    if toc(ARDUINO.t0) > tNextMessage
        str = strPerfo(respMTX,MTXTrialType,N);
        subjectStr = sprintf('%s: elapsed time %3.1f min',anID,(toc(ARDUINO.t0))/60);
        %sendBehaviorMessage(str,subjectStr,userID);
        tNextMessage = tNextMessage + tMessages;
    end
        
    
    % Stop if nH > maxTotHits
    if ~isnan(maxTotHits) && nH > maxTotHits        
        fprintf('Session stopped. Max number of hits (%d) reached\n',maxTotHits);
        
        % send text
        str = strPerfo(respMTX,MTXTrialType,N);
        subjectStr = sprintf('%s: auto-stopped',anID);
        %sendBehaviorMessage(str,subjectStr,userID);
        ESC = false;
    end
    
    % Increment N %%%%%%%%%
    N = N+1;  
end

%% SAVE  =======================================================

ARDUINO.data = ARDUINO.data(~isnan(ARDUINO.data(:,1)),:);
response.dataArduino = ARDUINO.data;
response.dataArduinoHeader = {'TimeMATLAB','MVT','LICK1','LICK2'};
response.respMTX = respMTX(1:N-1,:);
response.respMTXheader = responseMTXheader;

params.MTXTrialType = MTXTrialType;
params.MTXTrialTypeHeader = {'TRIAL#'; 'TRIALTYPE(0 no-go / 1 go)'; 'TONEID'; 'durFOREPERIOD'};
[~,systName] = system('hostname');
params.systName = systName(1:end-1);

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
saveName = sprintf('ToneDisc_AN%s_%s',anID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idArd = 1;
while exist(['Data\ToneDiscrimination\AN' anID '\' saveName '.mat'],'file') && idArd <= length(alphabets)
    if idArd == 1
        saveName(end+1) = alphabets(idArd);
    else
        saveName(end) = alphabets(idArd);
    end
    idArd = idArd+1;
end

% save
save(['Data\ToneDiscrimination\AN' anID '\' saveName],'data');
fprintf('Data was saved properly\n');

%% CLEAN UP =========================================

lever_cleanArduino(ARDUINO.in);
lever_cleanArduino(ARDUINO.out);


%% DISPLAY SESSION AVERAGES  ========================
plotSessionAverages(data)
%% SAVE FIGURES
if exist(['Data\ToneDiscrimination\AN' anID '\Figures'],'dir') == 0
    mkdir(['Data\ToneDiscrimination\AN' anID],'Figures');
end

figure(1)
savefig(['Data\ToneDiscrimination\AN' anID '\Figures\' saveName '_Performances'])
% figure(2)
% savefig(['Data\ToneDiscrimination\AN' anID '\Figures\' saveName '_FullSessionTraces'])
figure(3)
savefig(['Data\ToneDiscrimination\AN' anID '\Figures\' saveName '_Rasters'])
figure(4)
savefig(['Data\ToneDiscrimination\AN' anID '\Figures\' saveName '_BehMetrics'])