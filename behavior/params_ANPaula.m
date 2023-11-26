% GENERIC PARAMETERS ==================================
params.animalID = 'ANPaula';
params.computerName = getenv('computername');

% GENERIC PARAMETERS (Starting point for behavior)
% N s
params.nTrials = 1000;
params.amountReward = 6; % In uL. Run calibration
params.fractNoGo = 0; %fraction of NoGo trials
params.fractRewCorrRej = 0; %fraction of correct rejection trials that are rewarded

% Durations ---
% params.durations.preReward = 0.5;
params.durations.ITI.settings = [8.0 12.0];
params.durations.rewardConsumption = 2.5; % time after reward delivery
params.durations.decision = 10; %time after tone to make decision
params.durations.maxMvtDuration = 2.0; % time to pass both noMvtThresh and mvtThresh in order to count as lever press
% params.durations.decisionFA = 0.8;
params.durations.puff = 0.3;
params.durations.preReinforcement = 0.25;

% Detection MVT ---
params.mvt.mvtThresh = 0.25; % in Volts to initiate a trial
params.mvt.noMvtThresh = 0.12;

% Tone selection ---
params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities

% Switches
params.punish = false; % punish false alarm with puff
params.training = true;

% AutoStop
params.maxMiss = nan; % NOT IMPLEMENTED YET Maximum miss trials in a row. Use nan for no limits
params.maxTotHits = 3; % Maximum total of hits. Use nan for no limits.

% Laser
params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
params.laserExp = {'Arch/Jaws','ChR2', 'Arch/Jaws-Reinf', 'ArchSuprise'};
% % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0

params.fractNoGo = 0; %fraction of no-Go trials

        