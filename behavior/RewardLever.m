clear all; close all; clc;
root_dir = 'D:\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior';

cd(root_dir);
addpath([pwd filesep 'helpers' filesep]);
addpath([pwd filesep 'helpers' filesep 'waterCalibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card']);
addpath([pwd filesep 'helpers' filesep 'general']);
addpath([pwd filesep 'helpers' filesep 'sound']);
addpath([pwd filesep 'helpers' filesep 'leverMVT']);

%% PARAMS =================================================================
% ANIMAL SPECIFIC PARAMS
[filename, pathname] = uigetfile({'params_RewardLever_*.m'}, 'Please select animal specific params');

% Define params
run(fullfile(pathname, filename));
animalID = params.animalID;

%% SETUP ===================================================================
% Open communication with Arduino ---
[ardIn,ardOut] = setupArduino();
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;

% Keyboard ---
escapeKey = KbName('esc');
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Sound ---
soundStorage = soundInit(root_dir);
vol = [35:-10:5 35:-10:5]; % BASED ON CALIBRATION
rewardSoundID = 9;

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
ARDUINO.idx = 1;
nHits = 0;
fprintf('Running RewardLever...')

while ESC
    % RESPONSE =======================================================
    % go forward to meet second threshold ------------
    detectionParams = [60 MVT0 noMvtThresh mvtThresh maxLeverPressDuration];
    [ARDUINO,leverPress,ESC] = detectLeverPress(ARDUINO,detectionParams,escapeKey);
    % ------------
    if leverPress
        soundPlay(cueSoundID,soundStorage);
        fprintf('PRESSED\n')

        % PREREINFORCEMENT ===============================================
        [ARDUINO, ESC] = recordContinuous(ARDUINO, durPreReinforcement, escapeKey);

        % REINFORCEMENT ==================================================
        soundPlay(rewardSoundID,soundStorage);
        fprintf(ardOut,'W'); % WATER REWARD
        [ARDUINO, ESC] = recordContinuous(ARDUINO, durWaterValve, escapeKey); % keep reinforcement going
        fprintf(ardOut,'X'); % STOP WATER
        nHits = nHits + 1;
        disp(nHits)
    end
  
    % Stop if nHits > maxTotalHits
    if ~isnan(maxTotalHits) && nHits > maxTotalHits        
        askStop = input('Do you want to stop [y/n]: ', 's');
        if askStop == 'y'
        fprintf('Session stopped. Max number of hits (%d) reached\n',maxTotalHits);
        ESC = false;
        end
    end

    if nHits > nHitsToStartIncreasingThreshold
        mvtThresh = mvtThresh + thresholdIncreaseStep;
    end

    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;

end

%% SAVE  =======================================================
data.params = params;
data.arduino = ARDUINO.data;

% Check or Create folder for animalID
cd(root_dir);
if exist([root_dir 'RewardLeverData'],'dir') == 0
    mkdir(pwd,'RewardLeverData');
end
if exist([root_dir 'RewardLeverData\' animalID],'dir') == 0
    mkdir('RewardLeverData',[animalID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
day = datetime('now','TimeZone','local','Format','yyyyMMdd');
saveName = sprintf('RewardLever_%s_%s',animalID,day);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idArd = 1;
while exist(['RewardLeverData\' animalID '\' saveName '.mat'],'file') && idArd <= length(alphabets)
    if idArd == 1
        saveName(end+1) = alphabets(idArd);
    else
        saveName(end) = alphabets(idArd);
    end
    idArd = idArd+1;
end

% save
save(['RewardLeverData\' animalID '\' saveName],'data');
fprintf('Data was saved properly\n');

% Plot all the data
figure(1)
hold on
title('behaviorIN Lever')
plot(ARDUINO.data(:, 1), ARDUINO.data(:, 2)) % lever data
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
