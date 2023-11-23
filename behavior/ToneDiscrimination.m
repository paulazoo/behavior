clear all; close all; clc;
root_dir = 'D:\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior\';

cd(root_dir);
addpath([pwd filesep 'helpers' filesep]);
addpath([pwd filesep 'helpers' filesep 'analysis']);
addpath([pwd filesep 'helpers' filesep 'water_calibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card']);
addpath([pwd filesep 'helpers' filesep 'general']);
addpath([pwd filesep 'helpers' filesep 'sound']);
addpath([pwd filesep 'helpers' filesep 'graphs']);
addpath([pwd filesep 'helpers' filesep 'leverMVT']);

%% PARAMS ==================================================================
% ANIMAL SPECIFIC PARAMS
[filename, pathname] = uigetfile({'*.m'}, 'Please select animal specific params');

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
% dur_preReward = params.durations.preReward;
durITISettings = params.durations.ITI.settings;
durConsumption = params.durations.rewardConsumption;
durDecision = params.durations.decision;
maxMvtDuration = params.durations.maxMvtDuration;
durAirPuff = params.durations.puff;
durPreReinforce = params.durations.preReinforcement; 

% Detection ---
mvtThresh = params.mvt.mvtThresh; % in Volts to initiate a trial, aka second threshold
noMvtThresh = params.mvt.noMvtThresh; % first threshold that mouse must keep bar behind
ARDUINO.idx = 1;

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
% Open communication with Arduino ---
[ardIn,ardOut] = setupArduino();
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;

responseMTXheader = {'timeTrialStart';'timeTone';'leverPressed';'timePressed';'MVT0';'earlyPress';'rew'};
respMTX = nan(nTrials,7);
nM = 0;
nH = 0;
% Randomize trials ---
MTXTrialType = toneDiscrRandomizeTrial(nTrials,toneSelect,fractNoGo, durITISettings, paramsLaser);

% If opto mode == 3 or 4; 0 laser trial. it will be determined while running
% trials instead
if any(laserMode == [3 4])
    MTXTrialType(:,5) = 0;
end

% Keyboard ---
escapeKey = KbName('esc');
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Sound ---
soundPlayer = soundInit();
vol = [35:-10:5 35:-10:5]; % BASED ON CALIBRATION

% MVT0 baseline ---
fprintf('Finding MVT0\n');
MVT0 = mean(referenceMVT(ARDUINO,100));
disp('Thresholds to pass:')
disp(MVT0 + noMvtThresh);
disp(MVT0 + mvtThresh);

% Water ---
durWaterValve = water_reward2duration(amountReward,2);
cd(root_dir);

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
    durFore = MTXTrialType(N,4);
    
    laserIO = MTXTrialType(N,5);
        
    % DISPLAY TRIAL NUMBER & TRIAL TYPE
    fprintf('\n\nTrials %i of %i: ',N,nTrials);
    if trialType == 1
        fprintf('GO\n')
    elseif trialType == 0
        fprintf('NO-GO\n')
    end

    % ITI =================================================================
    durITI = MTXTrialType(N, 4);
    respMTX(N,6) = 0;
    fprintf('ITI: %3.1f sec\n',durITI);
    fprintf(ardOut,'I'); % ITI, turn tStart to LOW
    respMTX(N,5) = MVT0;
    pause(durITI);

    % TODO: possibly detect early press by std over 100 samples OR already past first threshold and if so, skip this trial
    % by setting respMTX(N,6) == 1
    
    % TRIAL ==============================================================
    fprintf(ardOut,'J'); % ITI finished, turn tStart to HIGH
    respMTX(N,1) = toc(ARDUINO.t0); % TRIAL START, leverIN is aligned to this
    soundPlay(cueSoundID,soundPlayer);
    
    if respMTX(N,6) < 1 % if not early press
        % RESPONSE =======================================================
        % go forward to meet second threshold ------------
        paramsDetectMVT = [durDecision MVT0 noMvtThresh mvtThresh maxMvtDuration];
        [ARDUINO,leverPress,ESC] = detectLeverPress(ARDUINO,paramsDetectMVT,escapeKey);
        if leverPress
            fprintf('Lever press detected\n');
            respMTX(N,3) = true;
            respMTX(N,4) = toc(ARDUINO.t0);
        elseif ~ESC
            fprintf('ESC pressed. Exit behavior!\n');
        else
            fprintf('No response\n');
            respMTX(N,3) = false;
        end
        % ------------
        
        % REINFORCEMENT ==================================================
        if trialType == 1
            durReinforce = durWaterValve;
            if leverPress
                fprintf('HIT\n')
                % HIT: Water reward
                soundPlay(2,soundPlayer); % Reward sound
                fprintf(ardOut,'W'); % WATER REWARD
                respMTX(N,7) = true;
                nH = nH + 1 ; % Total number of hits
            elseif ~leverPress
                fprintf('MISS\n');
                respMTX(N,7) = false;
            end
        elseif trialType == 0
            durReinforce = durAirPuff;
            if leverPress
                fprintf('FALSE ALARM\n');
                respMTX(N,7) = false;
                % FALSE ALARM: Air Puff
                fprintf(ardOut,'A'); % AIR PUNISHMENT
            elseif ~leverPress
                fprintf('CORR. REJECTION\n');
                respMTX(N,7) = false;
                if fractRewCR > 0
                    durReinforce = durWaterValve;
                    if rand > 1-fractRewCR
                       if laserMode == 4 && N > paramsLaser(2)
                           % Determine if it is a laser trial
                           if rand <= laserFract
                               MTXTrialType(N,5) = 1;
                               fprintf(ardOut,'L'); % Send a pulse to digidata
                               fprintf('LASER (SURPRISE)!\n')
                           end
                       end
                        fprintf('REWARD SURPRISE!!!\n');
                        fprintf(ardOut,'W'); % WATER REWARD
                        respMTX(N,7) = true;
                    end
                end
            end
        end
        pause(durReinforce); % keep reinforcement going
        fprintf(ardOut,'X'); % STOP WATER
        fprintf(ardOut,'B'); % STOP AIR
    end
        
    % Post trial (consumption)  ===================================================
    fprintf(ardOut,'I'); % ITI again, turn tStart to LOW
    
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;

    % Print performance so far =====================================================
    performanceString = printPerformance(respMTX,MTXTrialType,N);
    disp(performanceString);
        
    % Stop if nH > maxTotHits
    if ~isnan(maxTotHits) && nH > maxTotHits        
        askStop = input('Do you want to stop [y/n]: ', 's');
        if askStop == 'y'
        fprintf('Session stopped. Max number of hits (%d) reached\n',maxTotHits);
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
params.MTXTrialTypeHeader = {'TRIAL#'; 'TRIALTYPE(0 no-go / 1 go)'; 'TONEID'; 'durFOREPERIOD'};
[~,systName] = system('hostname');
params.systName = systName(1:end-1);

data.params = params;
data.response = response;

% Check or Create folder for animalName
cd(root_dir);
if exist([root_dir 'Data'],'dir') == 0
    mkdir(pwd,'Data');
end
if exist([root_dir 'Data\ToneDiscrimination'],'dir') == 0
    mkdir('Data','ToneDiscrimination');
end

if exist([root_dir 'Data\ToneDiscrimination\' animalID],'dir') == 0
    mkdir('Data\ToneDiscrimination',[animalID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
saveName = sprintf('ToneDisc_AN%s_%s',animalID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idArd = 1;
while exist(['Data\ToneDiscrimination\' animalID '\' saveName '.mat'],'file') && idArd <= length(alphabets)
    if idArd == 1
        saveName(end+1) = alphabets(idArd);
    else
        saveName(end) = alphabets(idArd);
    end
    idArd = idArd+1;
end

% save
save(['Data\ToneDiscrimination\' animalID '\' saveName],'data');
fprintf('Data was saved properly\n');

%% CLEAN UP =========================================
cleanArduino(ARDUINO.in);
cleanArduino(ARDUINO.out);
