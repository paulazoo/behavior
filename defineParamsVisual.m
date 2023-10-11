function params = defineParamsVisual(anID)

% GENERIC PARAMETERS ==================================
% !!! DO NOT CHANGE HERE !!!
params.animalID = anID;
params.computerName = getenv('computername');


% GENERIC PARAMETERS (Starting point for behavior)
% N s
params.nTrials = 1000; % Always put a very high number otherwise it might stop prematurely
params.amountReward = 5; % In uL. Run calibration
params.fractNoGo = 0; %fraction of NoGo trials

% Durations ---
params.durations.foreperiod.type = 'gaussian'; % 'gaussian' 'flat'
params.durations.foreperiod.settings = [0.65 0.15]; % Mu Std
% params.durations.preReward = 0.5;
params.durations.ITI = 1.5;
params.durations.rewardConsumption = 2.5; % time after reward delivery
params.durations.decision = .8; %time after tone to make decision
% params.durations.decisionFA = 0.8;
params.durations.puff = 0.3;
params.durations.preReinforcement = 0;

% Detection MVT ---
params.mvt.thresh = 0.15; % in Volts to initiate a trial
params.mvt.noMvtThresh = 0.1;

% Stim selection ---
params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts

% Parameters visual stimulus
params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
params.visProperties.tf = [2 2]; % Position (1) is the temporal freq for go; Position (2) is the temporal freq for no-go
params.visProperties.angle = [0 90]; % Position (1) is the angle for go; position (2) is angle for no-go
params.visProperties.sineWaveOn = true;
params.visProperties.cntrst = 10.^(linspace(-1,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
params.visProperties.background = 0.5; % From 0 to 1; 0 = black 1 = white.

% Switches
params.punish = false; % punish false alarm with puff
params.training = true;

% AutoStop
params.maxMiss = nan; % NOT IMPLEMENTED YET Maximum miss trials in a row. Use nan for no limits
params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.

% Laser
params.laser = [0 10 1]; %1-fractLaser trials; 2-ntrial baseline (at the beginning of a session); 3- Type 1 = Arch; 2=ChR2;
params.laserExp = {'Arch','ChR2', 'ArchReinf'};
% % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0


% CASE BY CASE PARAMETERS ==================================
switch anID
    case '01' % FOR TESTING THE RIG
        % N s
        params.fractNoGo = 0.5; %fraction of Go trials
        
        % Durations ---
        params.durations.decision = 1; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [0 90]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.punish = false; % punish false alarm with puff
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 20; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 0 3]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'SST01' 
        % N s
        params.fractNoGo = 0; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 2; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [0 90]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
    case 'SST02' 
        % N s
        params.fractNoGo = 0; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 30; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [0 90]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
    case 'SST03' 
        % N s
        params.fractNoGo = .5; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 1; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [2 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [0 90]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0.5; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = false;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
    case 'SST04' 
        % N s
        params.fractNoGo = .5; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 1; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [2 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [0 90]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0.5; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = false;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
    case 'AI148D01' 
        % N s
        params.fractNoGo = 0; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 30; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [0 90]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
    case 'AI148D03' 
        % N s
        params.fractNoGo = 0; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 2; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [90 0]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0.5; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
    case 'AI148D04' 
        % N s
        params.fractNoGo = 0; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 2; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [90 0]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0.5; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
    case 'AI148D05' 
        % N s
        params.fractNoGo = 0; %fraction of no Go trials
        
        % Durations ---
        params.durations.decision = 2; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [90 0]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0.5; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
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
        
        case 'Sofie01' % FOR TESTING THE RIG
        % N s
        params.fractNoGo = 0; %fraction of Go trials
        
        % Durations ---
        params.durations.decision = 30; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.stimSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities or visual contrasts
        
        % Parameters visual stimulus
        params.visProperties.sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
        params.visProperties.tf = [0 2]; % Position (1) is the temporal freq for no-go; Position (2) is the temporal freq for go
        params.visProperties.angle = [0 90]; % Position (1) is the angle for no-go; position (2) is angle for go
        params.visProperties.sineWaveOn = true;
        params.visProperties.cntrst = [0.01,0.04,0.16,1];%10.^(linspace(-2.2,0,4)); % Values from 0 to 1. Needs to be a list of 4 elements. Last value in the list should be the highest contrast.
        params.visProperties.dur = params.durations.decision; % Visual stimulus is on during the full response window. If you don't want that change it to something <params.durations.decision.
        params.visProperties.background = 0; % From 0 to 1; 0 = black 1 = white.
        
        % Switches
        params.punish = false; % punish false alarm with puff
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 0 3]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
end


