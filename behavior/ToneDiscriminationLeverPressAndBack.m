clear all; close all; clc;
root_dir = 'D:\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior';
save_dir = 'D:\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\Data_Renamed';

cd(root_dir);
addpath([pwd filesep 'helpers' filesep]);
addpath([pwd filesep 'helpers' filesep 'waterCalibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card']);
addpath([pwd filesep 'helpers' filesep 'general']);
addpath([pwd filesep 'helpers' filesep 'sound']);
addpath([pwd filesep 'helpers' filesep 'leverMVT']);

%% PARAMS ==================================================================
% ANIMAL SPECIFIC PARAMS
[filename, pathname] = uigetfile({'params/params_ToneDiscLeverPressAndBack_*.m'}, 'Please select animal specific params');

% Define params
run(fullfile(pathname, filename));
animalID = params.animalID;

% N s ---
nTrials = params.nTrials;
amountReward = params.amountReward;
fractNoGo = params.fractNoGo;
fractRewCR = params.fractRewCorrRej; %fraction of correct rejection trials that are rewarded; in most case it is zero. but reviewer asked for it so might as well try that.
if fractRewCR > 1
    fractRewCR = 1;
end

% Ask user if reward surprise is okay
if fractRewCR > 0.001
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
durITISettings = params.durations.ITISettings;
% check that ITI is at least 1 second
if durITISettings(1,1) < 1.0
    error('ITI must be at least 1.0s');
 end
durConsumption = params.durations.rewardConsumption;
durDecision = params.durations.decision;
maxLeverPressDuration = params.durations.maxLeverPressDuration;
durAirPuff = params.durations.airPuff;
durPreReinforcement = params.durations.preReinforcement; 

% Detection ---
% note that maxLeverPressDuration is set in params.durations.maxLeverPressDuration
mvtThresh = params.mvt.mvtThresh; % in Volts to initiate a trial, aka second threshold
noMvtThresh = params.mvt.noMvtThresh; % first threshold that mouse must keep bar behind
ARDUINO.idx = 1;

% Tone selection --- 
toneSelect = params.toneSelection; % Range from 1o 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
rewardSoundID = params.rewardSoundID;
cueSoundID = params.cueSoundID;

% Switches
punishSwitch = params.punish;

% Termination Criteria
maxMiss = params.maxMiss; % NOT IMPLEMENTED YET Maximum miss trials in a row. Use nan for no limits
maxTotalHits = params.maxTotalHits; % Maximum total of hits. Use nan for no limits.

% Laser
fractionLaser = params.laser.fractionLaser;
nTrialBaseline = params.laser.nTrialBaseline; % ntrial baseline (at the beginning of a session)
laserMode = params.laser.laserMode; % laser mode; either 'Arch/Jaws', 'ChR2, 'Arch/Jaws-Reinf', or 'ArchSuprise'
laserLocation = params.laser.laserLocation; % LC=1 PFC=2 MC=3
laserControlSwitch = params.laser.controlExperiments; 

% Laser Check
if fractionLaser > 0 % if any of the trials have laser
    str = sprintf('Warning: %s is selected as the optogenetic mode, OKAY? Y/N [Y]:\n', laserMode);
    reply = input(str,'s');
    if ~strcmp(reply,'Y')
        fprintf('Exiting!\n');
        return
    end
end

if ~laserControlSwitch
    reply = input('This is not a control experiment, OKAY? Y/N [Y]:\n');
    if ~strcmp(reply,'Y')
        fprintf('Exiting!\n');
        return
    end
end

% Verification that dur pre-reinforcement is larger than 0 if laser mode 3
% is selected.
if strcmp(laserMode,'Arch/Jaws-Reinf') && durPreReinforcement < 0.01
    error('You cannot use this laser mode if durPreReinforcement is set to 0 sec');
end

%% SETUP ===================================================================
% Open communication with Arduino ---
[ardIn,ardOut] = setupArduino();
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;

responseMTXheader = {'timeTrialStart';'timeTone';'leverPressed';'timePressed';'MVT0';'ITIPress';'rew'};
respMTX = nan(nTrials,7);
nM = 0;
nHits = 0;
% Randomize trials ---
MTXTrialType = toneDiscrRandomizeTrial(nTrials, fractNoGo, durITISettings, params.laser);

% If opto mode == 3 or 4; 0 laser trial. it will be determined while running
% trials instead
if ~strcmp(laserMode,'None')
    MTXTrialType(:,5) = 0;
end

% Keyboard ---
escapeKey = KbName('esc');
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Sound ---
soundStorage = soundInit(root_dir);
vol = [35:-10:5 35:-10:5]; % BASED ON CALIBRATION

% MVT0 baseline ---
fprintf('Finding MVT0\n');
MVT0 = mean(referenceMVT(ARDUINO,100));
disp('Thresholds to pass:')
disp(MVT0 + noMvtThresh);
disp(MVT0 + mvtThresh);

% Water ---
durWaterValve = waterReward2duration(amountReward,2,root_dir);

% Asynchronous LeverData ---
AsyncLeverDataStarted = input('did you start the asynchronous LeverData recording? [y/n]\n', 's');

%% RUN TRIALS ==============================================================
% =========================================================================
ARDUINO.t0 = tic;
N = 1;

while N <= nTrials && ESC
    % Load params specific for each trial 
    trialType = MTXTrialType(N,2);
    cueSoundID = MTXTrialType(N,3);
    laserIO = MTXTrialType(N,5);
        
    % DISPLAY TRIAL NUMBER & TRIAL TYPE
    fprintf('\n\nTrials %i of %i: ',N,nTrials);
    if trialType == 1
        fprintf('GO\n')
    elseif trialType == 0
        fprintf('NO-GO\n')
    end

    respMTX(N,2) = NaN; % tone time
    respMTX(N,3) = false; % successful lever press
    respMTX(N,4) = NaN; % lever press time
    respMTX(N,5) = MVT0;
    respMTX(N,6) = false; % pressed during ITI
    respMTX(N,7) = false; % rewarded trial
    
    respMTX(N,1) = toc(ARDUINO.t0); % SESSION START

    % ITI =================================================================
    durITI = MTXTrialType(N, 4);
    fprintf('ITI: %3.1f sec\n',durITI);
    fprintf(ardOut,'I'); % ITI, turn tStart to LOW

    [ARDUINO, ESC] = recordContinuous(ARDUINO, durITI - 1.0, escapeKey);
    % For the last second of the ITI, don't go to trial unless no movement past noMvtThresh
    detectionParams = [1.0 MVT0 noMvtThresh];
    [ARDUINO, ITIMovement, ESC] = detectITIMovement(ARDUINO, detectionParams, escapeKey);
    % if ITIMovement detected, restart last second of ITI until no movement is detected
    % while ITIMovement == true
    %     respMTX(N,6) = true; % pressed during ITI
    %     disp('movement detected, extending ITI...\n')
    %     [ARDUINO, ITIMovement, ESC] = detectITIMovement(ARDUINO, detectionParams, escapeKey);
    % end
    
    % TONE ==============================================================
    fprintf(ardOut,'J'); % ITI finished, turn tStart to HIGH
    respMTX(N,2) = toc(ARDUINO.t0); % tone time
    soundPlay(cueSoundID,soundStorage);
    
    % RESPONSE =======================================================
    % go forward to meet second threshold ------------
    detectionParams = [durDecision MVT0 noMvtThresh mvtThresh maxLeverPressDuration];
    [ARDUINO,leverPress,ESC] = detectLeverPressAndBack(ARDUINO,detectionParams,escapeKey);
    if leverPress
        fprintf('Lever press detected\n');
        respMTX(N,3) = true; % lever pressed successfully
        respMTX(N,4) = toc(ARDUINO.t0); % lever press time
    elseif ~ESC
        fprintf('ESC pressed. Exit behavior!\n');
    else
        fprintf('No response\n');
        respMTX(N,3) = false; % lever not pressed successfully
    end
    % ------------

    % PREREINFORCEMENT ===============================================
    [ARDUINO, ESC] = recordContinuous(ARDUINO, durPreReinforcement, escapeKey);
    
    % REINFORCEMENT ==================================================
    if trialType == 1 && leverPress
        fprintf('HIT, REWARD\n')
        respMTX(N,7) = true; % rewarded trial
        soundPlay(rewardSoundID,soundStorage);
        waterStartTime = toc(ARDUINO.t0);
        deltaWaterTime = toc(ARDUINO.t0) - waterStartTime;
        fprintf(ardOut,'W'); % WATER REWARD
        while deltaWaterTime < durWaterValve
            deltaWaterTime = toc(ARDUINO.t0) - waterStartTime;
        end
        fprintf(ardOut,'X'); % STOP WATER
        nHits = nHits + 1 ; % Total number of hits 

    elseif trialType == 1 && ~leverPress
        fprintf('MISS, DO NOTHING\n');
        respMTX(N,7) = false; % not a rewarded trial

    elseif trialType == 0 && leverPress && punishSwitch
        fprintf('FALSE ALARM, PUNISHMENT\n');
        respMTX(N,7) = false; % not a rewarded trial
        fprintf(ardOut,'A'); % AIR PUNISHMENT
        pause(durAirPuff);
        fprintf(ardOut,'B'); % STOP AIR

    elseif trialType == 0 && leverPress && ~punishSwitch
        fprintf('FALSE ALARM, DO NOTHING\n');
        respMTX(N,7) = false; % not a rewarded trial

    elseif trialType == 0 && ~leverPress && unifrnd(0, 1) > fractRewCR
        fprintf('CORRECT REJECTION, DO NOTHING\n');
        respMTX(N,7) = false; % not a rewarded trial

    elseif trialType == 0 && ~leverPress % so unifrnd(0, 1) was < fractRewCR
        fprintf('CORRECT REJECTION, REWARD SURPRISE!!!\n');
        respMTX(N,7) = true; % rewarded trial
        fprintf(ardOut,'W'); % WATER REWARD
        [ARDUINO, ESC] = recordContinuous(ARDUINO, durWaterValve, escapeKey); % keep reinforcement going
        fprintf(ardOut,'X'); % STOP WATER
    
    else
        error("No logic for reinforcement found.");
    end
        
    % CONSUMPTION  ===================================================
    fprintf(ardOut,'K'); % decision ended, turn LED back on, but don't start next trial quite yet
    [ARDUINO, ESC] = recordContinuous(ARDUINO, durConsumption, escapeKey); % record during consumption

    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;

    % Print performance so far =====================================================
    performanceString = printPerformance(respMTX,MTXTrialType,N);
    disp(performanceString);
        
    % Stop if nHits > maxTotalHits
    if ~isnan(maxTotalHits) && nHits > maxTotalHits        
        askStop = input('Do you want to stop [y/n]: ', 's');
        if askStop == 'y'
        fprintf('Session stopped. Max number of hits (%d) reached\n',maxTotalHits);
        ESC = false;
        end
    end
    
    % Increment N
    N = N+1;
end

%% SAVE  =======================================================
response.respMTX = respMTX(1:N-1,:);
response.respMTXheader = responseMTXheader;

params.MTXTrialType = MTXTrialType;
params.MTXTrialTypeHeader = {'TRIAL#'; 'TRIALTYPE(0 no-go / 1 go)'; 'TONEID'; 'durITI'};
[~,systName] = system('hostname');
params.systName = systName(1:end-1);

data.params = params;
data.response = response;
data.arduino = ARDUINO.data;

% Check or Create folder for animalID
cd(save_dir);
if exist([save_dir 'ToneDiscriminationData'],'dir') == 0
    mkdir(pwd,'ToneDiscriminationData');
end
if exist([save_dir 'ToneDiscriminationData\' animalID],'dir') == 0
    mkdir('ToneDiscriminationData',[animalID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
day = datetime('now','TimeZone','local','Format','yyyyMMdd');
saveName = sprintf('ToneDisc_%s_%s',animalID,day);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idArd = 1;
while exist([save_dir '\ToneDiscriminationData\' animalID '\' saveName '.mat'],'file') && idArd <= length(alphabets)
    if idArd == 1
        saveName(end+1) = alphabets(idArd);
    else
        saveName(end) = alphabets(idArd);
    end
    idArd = idArd+1;
end

% save
save([save_dir '\ToneDiscriminationData\' animalID '\' saveName],'data');
fprintf('Data was saved properly\n');

% Plot all the data
figure(1)
hold on
title('behaviorIN Lever')
plot(ARDUINO.data(:, 1), ARDUINO.data(:, 2)) % lever data
yline(MVT0+noMvtThresh)
yline(MVT0+mvtThresh)
hold off
figure(2)
hold on
title('behaviorIN Licks')
plot(ARDUINO.data(:, 1), ARDUINO.data(:, 3)) % lick data
hold off

%% CLEAN UP =========================================
cleanArduino(ardIn, 'IN');
clear ardIn
cleanArduino(ardOut, 'OUT');
clear ardOut

cd(root_dir)