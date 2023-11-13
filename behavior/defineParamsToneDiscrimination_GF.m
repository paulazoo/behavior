function params = defineParamsToneDiscrimination_GF(anID)

% GENERIC PARAMETERS ==================================
% !!! DO NOT CHANGE HERE !!!
params.animalID = anID;
params.computerName = getenv('computername');


% GENERIC PARAMETERS (Starting point for behavior)
% N s
params.nTrials = 1000;
params.amountReward = 5; % In uL. Run calibration
params.fractNoGo = 0; %fraction of NoGo trials
params.fractRewCorrRej = 0; %fraction of correct rejection trials that are rewarded

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
params.mvt.thresh = 0.15; % in Volts; to be considered press
params.mvt.noMvtThresh = 0.1; % Maximum movement allowed during baseline period

% Tone selection ---
params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities

% Switches
params.punish = false; % punish false alarm with puff
params.training = true;

% AutoStop
params.maxMiss = nan; % NOT IMPLEMENTED YET Maximum miss trials in a row. Use nan for no limits
params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.

% Laser
params.laser = [0 10 1]; %1-fractLaser trials; 2-ntrial baseline (at the beginning of a session); 3- Type 1 = Arch/Jaws; 2=ChR2; 3=Arch during reinforcement; 4= Arch during reward surprise
params.laserExp = {'Arch/Jaws','ChR2', 'Arch/Jaws-Reinf', 'ArchSuprise'};
% % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0


% CASE BY CASE PARAMETERS ==================================
switch anID
    case '01' % FOR TESTING THE only go tone
        % N s
        params.fractNoGo = 0; %fraction of Go trials
        params.fractRewCorrRej = 0;
        
        % Durations ---
        params.durations.ITI = 2.5;
        params.durations.decision = 30; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.18; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.punish = true; % punish false alarm with puff
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 20; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 0 1]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0

    case '02' % FOR TESTING only no-go tone
        % N s
        params.fractNoGo = 1; %fraction of Go trials
        params.fractRewCorrRej = 0;
        
        % Durations ---
        params.durations.ITI = 2.5;
        params.durations.decision = 30; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.punish = true; % punish false alarm with puff
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 20; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 0 1]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
 
    case '03' % FOR TESTING both tones
        % N s
        params.fractNoGo = 0.5; %fraction of Go trials
        params.fractRewCorrRej = 0;
        
        % Durations ---
        params.durations.ITI = 2.5;
        params.durations.decision = 0.8; %time after tone to make decision
        params.durations.preReinforcement = 0;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.punish = true; % punish false alarm with puff
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 20; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 0 1]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        
    case 'VBP' % FOR TESTING THE RIG
        % N s
        params.fractNoGo = 0.5; %fraction of Go trials
        
        % Durations ---
        params.durations.decision = 0.8; %time after tone to make decision
        params.durations.preReinforcement = 0;
        params.durations.ITI = 0.5;
        params.durations.rewardConsumption = 1;
        
        % Detection MVT ---
        params.mvt.thresh = 0.15; 
        params.mvt.noMvtThresh = 0.1;
        
        % Tone selection ---
        params.toneSelection = 10; % Range from 1 to 10. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.punish = false; % punish false alarm with puff
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [1/3 0 3]; %fractLaser trils; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case 'Paula'
        % N s
        params.fractNoGo = 0; %fraction of no-Go trials
        
%         params.fractRewCorrRej = 0.25; %.25 for surprise reward CR
        
        % Durations ---
%        params.durations.ITI = 2.5;
        params.durations.decision = 30; %time after tone to make decision
        params.amountReward = 5; % In uL. Run calibration
        params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.35; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.12;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR
        
        case 'A1'
        % N s
        params.fractNoGo = 0; %fraction of no-Go trials
        
%         params.fractRewCorrRej = 0.25; %.25 for surprise reward CR
        
        % Durations ---
%        params.durations.ITI = 2.5;
        params.durations.decision = 30; %time after tone to make decision
        params.amountReward = 6; % In uL. Run calibration
        params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.18; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.12;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR
        
           case 'A2'
        % N s
        params.fractNoGo = 0; %fraction of no-Go trials
        
%         params.fractRewCorrRej = 0.25; %.25 for surprise reward CR
        
        % Durations ---
%         params.durations.ITI = 2.5;
        params.durations.decision = 30; %time after tone to make decision
        params.amountReward = 6; % In uL. Run calibration
        params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.18; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.12;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR

           case 'B1'
        % N s
        params.fractNoGo = 0; %fraction of no-Go trials
        
%         params.fractRewCorrRej = 0.25; %.25 for surprise reward CR
        
        % Durations ---
%         params.durations.ITI = 2.5;
        params.durations.decision = 30; %time after tone to make decision
        params.amountReward = 6; % In uL. Run calibration
        params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.18; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.12;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR

           case 'B2'
        % N s
        params.fractNoGo = 0; %fraction of no-Go trials
        
%         params.fractRewCorrRej = 0.25; %.25 for surprise reward CR
        
        % Durations ---
%         params.durations.ITI = 2.5;
        params.durations.decision = 30; %time after tone to make decision
        params.amountReward = 6; % In uL. Run calibration
        params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.18; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.12;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR
        
        
        case 'Ross'
        % N s
        params.fractNoGo = 0.5; %fraction of no-Go trials
        
%         params.fractRewCorrRej = 0.25; %.25 for surprise reward CR
        
        % Durations ---
%         params.durations.ITI = 2.5;
        params.durations.decision = 0.8; %time after tone to make decision
        params.amountReward = 5; % In uL. Run calibration
        params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.16; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.12;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR
        
        case 'Joey'
        % N s
        params.fractNoGo = 0.5; %fraction of no-Go trials
        
%         params.fractRewCorrRej = 0.25; %.25 for surprise reward CR
        
        % Durations ---
%         params.durations.ITI = 2.5;
        params.durations.decision = 0.8; %time after tone to make decision
        params.amountReward = 5; % In uL. Run calibration
        params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.16; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.12;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 4]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR
        
       
        
         case 'DbhArchRec11'
        % N s
        params.fractNoGo = 0; %fraction of Go trials
        params.amountReward = 5; % In uL. Run calibration
        %params.fractRewCorrRej = 0; %.25 for surprise reward CR
        
        % Durations ---
        params.durations.decision = 30; %time after tone to make decision
        %params.durations.preReinforcement = 0.25;
        
        % Detection MVT ---
        params.mvt.thresh = 0.14; % in Volts to initiate a trial
        params.mvt.noMvtThresh = 0.10;
        
        % Tone selection ---
        params.toneSelection = 1; % Range from 1 to 4. 1 means only max. 2 means two max, ... and 4 all tone intensities
        
        % Switches
        params.training = true;
        
        % AutoStop
        params.maxTotHits = 100; % Maximum total of hits. Use nan for no limits.
        
        % Laser
        params.laser = [0 10 1]; %fractLaser trials; ntrial baseline (at the beginning of a session)
        % % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
        %1-fractLaser trials; 2-ntrial baseline (at the beginning of a
        %session); 3- Type 1 = Arch; 2=ChR2;3=Arch reinforcement; 4= CR
        
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
