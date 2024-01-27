% GENERIC PARAMETERS ==================================
params.animalID = 'ANPaula';
params.computerName = getenv('computername');

params.nTrials = 1000;
params.amountReward = 6; % In uL. Run calibration
params.fractNoGo = 0; %fraction of NoGo trials
params.fractRewCorrRej = 0; %fraction of correct rejection trials that are rewarded

% Durations ==================================
params.durations.ITISettings = [8.0 12.0];
params.durations.rewardConsumption = 2.5; % time after reward delivery
params.durations.airPuff = 0.3; % time for air puff valve
params.durations.decision = 30; %time after tone to make decision
params.durations.preReinforcement = 0.5; % time after successful lever press and before reinforcement
params.durations.maxLeverPressDuration = 2.0; % time to pass both noMvtThresh and mvtThresh in order to count as lever press

% Lever Press Detection ==================================
params.mvt.noMvtThresh = 0.12; % first threshold in Volts
params.mvt.mvtThresh = 0.5; % second threshold in Volts

% Tone selection ==================================
params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities

% Switches ==================================
params.punish = false; % punish false alarm with puff

% AutoStop ==================================
params.maxMiss = nan; % NOT IMPLEMENTED YET Maximum miss trials in a row. Use nan for no limits
params.maxTotalHits = 50; % Maximum total of hits. Use nan for no limits.

% Laser ==================================
params.laser.fractionLaser = 0; % fraction of laser trials. possible values: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
params.laser.nTrialBaseline = 10; % ntrial baseline (at the beginning of a session)
params.laser.laserMode = 'None'; % laser mode; either 'Arch/Jaws', 'ChR2, 'Arch/Jaws-Reinf', or 'ArchSuprise'. Or 'None'.
params.laser.laserLocation = nan; % LC=1 PFC=2 MC=3
params.laser.controlExperiments = true; 
        