function params = defineParamsConditioning(anID)

% GENERIC PARAMETERS ==================================
% !!! DO NOT CHANGE HERE !!!
params.animalID = anID;
params.computerName = getenv('computername');


% GENERIC PARAMETERS (Starting point for behavior)
% N s
params.nTrials = 1000;
params.amountReward = 3; % In uL. Run calibration
params.toneSelection = 2; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
% params.fractPunish = 0.5;

% Durations ---
params.durations.ITI = [2 10]; % [Mu Max]
params.durations.rewardConsumption = 2.5; % time after reward delivery
params.durations.puff = 0.3;
params.durations.preReinforcement = 1.5;
params.durations.total = 3600; % Duration (is sec) of the session


% CASE BY CASE PARAMETERS ==================================
switch anID
    case '01' % FOR TESTING THE RIG
        % N s
        params.nTrials = 1000;
        params.amountReward = 3; % In uL. Run calibration
        params.toneSelection = 3; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
        
        % Durations ---
        params.durations.ITI = [15 45]; % [Mu Max]
        params.durations.rewardConsumption = 3.5; % time after reward delivery
        params.durations.puff = 0.3;
        params.durations.preReinforcement = 1.5;
        params.durations.total = 30; % Duration (is sec) of the session
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'Dbh15'
        % N s
        params.nTrials = 1000;
        params.amountReward = 4; % In uL. Run calibration
        params.toneSelection = 3; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
        
        % Durations ---
        params.durations.ITI = [15 45]; % [Mu Max]
        params.durations.rewardConsumption = 3.5; % time after reward delivery
        params.durations.puff = 0.3;
        params.durations.preReinforcement = 1.5;
    case 'Dbh16'
        % N s
        params.nTrials = 1000;
        params.amountReward = 4; % In uL. Run calibration
        params.toneSelection = 3; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
        
        % Durations ---
        params.durations.ITI = [15 45]; % [Mu Max]
        params.durations.rewardConsumption = 3.5; % time after reward delivery
        params.durations.puff = 0.3;
        params.durations.preReinforcement = 1.5;
        params.durations.total = 1800;
    case 'Dbh17'
        % N s
        params.nTrials = 1000;
        params.amountReward = 4; % In uL. Run calibration
        params.toneSelection = 3; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
        
        % Durations ---
        params.durations.ITI = [15 45]; % [Mu Max]
        params.durations.rewardConsumption = 3.5; % time after reward delivery
        params.durations.puff = 0.3;
        params.durations.preReinforcement = 1.5;
        params.durations.total = 1800;
    case 'Dbh18'
        % N s
        params.nTrials = 1000;
        params.amountReward = 4; % In uL. Run calibration
        params.toneSelection = 3; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
        
        % Durations ---
        params.durations.ITI = [15 45]; % [Mu Max]
        params.durations.rewardConsumption = 3.5; % time after reward delivery
        params.durations.puff = 0.3;
        params.durations.preReinforcement = 1.5;
    case 'Dbh19'
        % N s
        params.nTrials = 1000;
        params.amountReward = 4; % In uL. Run calibration
        params.toneSelection = 3; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
        
        % Durations ---
        params.durations.ITI = [15 45]; % [Mu Max]
        params.durations.rewardConsumption = 3.5; % time after reward delivery
        params.durations.puff = 0.3;
        params.durations.preReinforcement = 1.5;
    case 'Dbh20'
        % N s
        params.nTrials = 1000;
        params.amountReward = 4; % In uL. Run calibration
        params.toneSelection = 3; %1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/punishment/neutral
        
        % Durations ---
        params.durations.ITI = [15 45]; % [Mu Max]
        params.durations.rewardConsumption = 3.5; % time after reward delivery
        params.durations.puff = 0.3;
        params.durations.preReinforcement = 1.5;
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
