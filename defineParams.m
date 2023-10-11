function params = defineParams(anID)

% GENERIC PARAMETERS ==================================
% !!! DO NOT CHANGE HERE !!!
params.animalID = anID;
params.computerName = getenv('computername');

% N s
params.nTrials = 100;
params.amountReward = 5; % In uL. Run calibration
params.nConsecLick = 3; % N of consecutive licks to define decision. Animal has to lick continuously the same spout for 'nConsecLick' to make a decision.
params.nTrialPerBlock = 10; %can be a range or single value
params.fractRew = 1; %fraction to be rewarded per block
params.fractFreeTrial = 1; %fraction to give reward on both choice per block. Overwrite fraction reward

% Durations ---
params.durations.trialInitiation = 5; % in sec
params.durations.preReward = 0.5;
params.durations.ITI = 1;
params.durations.rewardConsumption = 1; % time after reward delivery
params.durations.postTrial = 0.5;
params.durations.decision = 1;

% Detection MVT ---
params.mvt.thresh = 0.05; % in Volts to initiate a trial
params.mvt.noMvtThresh = 0.01;

% Switches
params.moveSpoutIO = false; % when you don't want the spout to move
params.alternateIO = true; % to learn to explore both spout. Not dependent on decision. Reward comes out anyway

% CASE BY CASE PARAMETERS ==================================
switch anID
    case '01'
        % N s
        params.nTrials = 1000;
        params.amountReward = 5; % In uL. Run calibration
        params.nConsecLick = 1;
        params.nTrialPerBlock = [7 20];
        params.fractRew = 0.9;
        params.fractFreeTrial = 0;

        % Durations ---
        params.durations.trialInitiation = 5; % in sec
        params.durations.preReward = 0.4;
        params.durations.ITI = 1;
        params.durations.rewardConsumption = 1; % time after reward delivery
        params.durations.postTrial = 0.5;
        params.durations.decision = 4;

        % Detection ---
        params.mvt.thresh = 0.1; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.02;
        
        % Switches ---
        params.moveSpoutIO = true;
        params.alternateIO = true; % to learn to explore both spout. Not dependent on decision. Reward comes out anyway

        case 'WT1'
        % N s
        params.nTrials = 300;
        params.amountReward = 4; % In uL. Run calibration
        params.nConsecLick = 1;
        params.nTrialPerBlock = [7 20];
        params.fractRew = 1;
        params.fractFreeTrial = 0;

        % Durations ---
        params.durations.trialInitiation = 10; % in sec
        params.durations.preReward = 0.4;
        params.durations.ITI = 1;
        params.durations.rewardConsumption = 2; % time after reward delivery
        params.durations.postTrial = 0.5;
        params.durations.decision = 4;

        % Detection ---
        params.mvt.thresh = 0.1; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.02;
        
        % Switches ---
        params.moveSpoutIO = true;
        params.alternateIO = false; % to learn to explore both spout. Not dependent on decision. Reward comes out anyway
        
        case 'WT2'
        % N s
        params.nTrials = 300;
        params.amountReward = 4; % In uL. Run calibration
        params.nConsecLick = 1;
        params.nTrialPerBlock = [7 20];
        params.fractRew = 0.85;
        params.fractFreeTrial = 0;

        % Durations ---
        params.durations.trialInitiation = 10; % in sec
        params.durations.preReward = 0.4;
        params.durations.ITI = 1;
        params.durations.rewardConsumption = 2; % time after reward delivery
        params.durations.postTrial = 0.5;
        params.durations.decision = 4;

        % Detection ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.02;
        
        % Switches ---
        params.moveSpoutIO = true;
        params.alternateIO = false; % to learn to explore both spout. Not dependent on decision. Reward comes out anyway

    otherwise
        reply = input(['The animal ID: ' anID ' is not listed in ''defineParams''\nDo you want to use generic parameters? Y/N [Y]:'],'s');
        if isempty(reply)
            reply = 'Y';
        end
        if strcmp(reply,'N') || strcmp(reply,'n')
            fprintf('Please enter parameters for animal ID: ''%s'' in defineParams function\n',anID);
            params = nan;
            return
        end
end
