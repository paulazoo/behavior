%
clear all; close all; clc;
setUpDirHFB_GF;
cd(HFRootFolder_GF);

% BASED ON TONE DISCRIMINATION V3; hower uses a new sound stimuli 'sound
% cloud' based on rate of no go frequencies.

%% PARAMS ==================================================================
% ANIMAL ID
% clc;
% if nargin < 1
anID = input('Please enter animal ID:\n','s');
userID = input('Please enter your text ID (Ex.: VBP or GD or DHY):\n','s');
if isempty(userID)
    reply = 'vbp';
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

% DEVELOPMENT ONLY
outputConnected = true;

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

% Sound ---------
[snd,soundParams] = soundInitCloud;
rateList = [0.0 0.05 0.1 0.2];
noiseLevel = [0 0.2 0.4 0.8];
% Create stim list sorted by noise level value 
allRate = [];
for i=1:length(noiseLevel)
    x = [noiseLevel(i)*ones(size(rateList(2:end)))' rateList(2:end)']
%     x = [rateList(i:end)' noiseLevel(i)*ones(size(rateList(i:end)))'];
%     x(x(:,1) == x(:,2),:) = []; % remove pedestal point as they will be hard  to interpret in a go no/no-go
    allRate = [allRate; flipud(x)];
%     sortedRate{i} = [flipud(x); fliplr(x)];
end
% Create equal number of no go rate so that it works with the randomization function
x = repmat(noiseLevel,length(rateList)-1,1);
x = [flipud(x(:)) zeros(size(x(:)))];
allRate = [x; allRate]; % allRate(1:end/2,:) = NoGo stim % allRate(end/2+1:end,:) = Go stim; each one sorted from easiest to hardestsoundCloudSeq = nan(round(soundParams.durStim*soundParams.freqSub),nTrials);

% Initialize response MTX
responseMTXheader = {'timeTrialStart';'timeTone';'leverPressed';'timePressed';'MVT0';'earlyPress'};
respMTX = nan(nTrials,6);

% Randomize trials ---
MTXTrialType = randomizeTrialGoNoGo(nTrials,[toneSelect size(allRate,1)/2],fractNoGo,foreperiod.settings, paramsLaser);

% Keyboard ---
if strcmp(computer,'MACI64')
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
end
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

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
% nM = 0;
nH = 0; % Used to stop after certain amount of hits

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
%     if trialType > 0
%         fprintf('GO')
%     elseif trialType < 1
%         fprintf('NO-GO')
%     end
    fprintf('\n');
        
    % Prepare sound buffer =================
    [s,soundCloudSeq(:,N)] = soundCloudStim(soundParams.frequencies,allRate(soundID,:),soundParams);
    snd.buffers = PsychPortAudio('CreateBuffer', snd.pahandle, s);
    
    % ITI ==================================
    fprintf('ITI: %3.1f sec\n',durITI);
    if outputConnected; fprintf(ardOut,'I'); end % LED ON
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
    if outputConnected; fprintf(ardOut,'J'); end; % LED OFF 
    id0 = ARDUINO.data(:,1) > ARDUINO.data(ARDUINO.idx-1,1) - durITI;
    MVT0 = nanmedian(ARDUINO.data(id0,2));% calculate BL based on ITI
    respMTX(N,5) = MVT0;
    
    % LASER ON - ARCH EXPERIMENTS =====================================
    if laserIO > 0 && laserMode == 1
        if outputConnected; fprintf(ardOut,'A'); end % Send a pulse to digidata
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
        fprintf('Rate = %1.2f %1.2f @ (%3.1f sec)\n', allRate(soundID,1), allRate(soundID,2), durFore);
        respMTX(N,6) = false;
        respMTX(N,2) = toc(ARDUINO.t0);
        % LASER ON - ChR2 EXPERIMENTS =====================================
        if laserIO > 0 && laserMode == 2
            if outputConnected; fprintf(ardOut,'A'); end; % Send a pulse to digidata
            fprintf('LASER!')
        end        
        soundPlay(1,snd);
    end
    
    if respMTX(N,6) < 1
        % RESPONSE ================
        paramsDetectMVT = [durDecision MVT0 mvt_thresh];
        [ARDUINO,isMVT,ESC] = detectMVTV2(ARDUINO,paramsDetectMVT,escapeKey);
        if isMVT
            fprintf('Lever pressed\n');
            respMTX(N,3) = true;
            respMTX(N,4) = ARDUINO.data(ARDUINO.idx-1,1);
            PsychPortAudio('Stop',snd.pahandle);
        elseif ~ESC
            fprintf('ESC pressed. Exit behavior!\n');
        else
            fprintf('No response\n');
            respMTX(N,3) = false;
        end
        
        % PRE-REINFORCEMENT ====================
        %%LASER ON - ARCH LASER DURING REINFORCEMENT
        if isMVT && laserIO > 0 && laserMode == 3
            if outputConnected; fprintf(ardOut,'A'); end % Send a pulse to digidata
            fprintf('LASER!')
        end
        
        ARDUINO = recMVTV2(ARDUINO,durPreReinforce);
        
        % REINFORCEMENT ==============
        if trialType > 0
            durReinforce = durValveL;
%             durPost = dur_consumption;
            if isMVT
                fprintf('HIT\n')
                % HIT: Water reward
                if outputConnected; fprintf(ARDUINO.out,'E'); end % LEFT VALVE % LEFT VALVE
                nH = nH + 1 ; % Total number of hits
            elseif ~isMVT
                fprintf('MISS\n');
            end
        elseif trialType < 1
            durReinforce = durPuff;
            if isMVT
                fprintf('FALSE ALARM\n');
                % FALSE ALARM: Air Puff
                if outputConnected; fprintf(ARDUINO.out,'L'); end % AIR LEFT
%                 durPost = 2*dur_consumption;
            elseif ~isMVT
                fprintf('CORR. REJECTION\n');
%                 durPost = dur_consumption;
            end
        end
        ARDUINO = recMVTV2(ARDUINO,durReinforce);
        if outputConnected
            fprintf(ardOut,'O'); 
            fprintf(ardOut,'M');
        end
        
        
        % Post trial (consumption)  ========================================================================================
        ARDUINO = recMVTV2(ARDUINO,durConsumption);
        if outputConnected; fprintf(ardOut,'I'); end% LED ON
        
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
%     if nM > maxMiss
    if toc(ARDUINO.t0) > tNextMessage
        str = strPerfo(respMTX,MTXTrialType,N);
        subjectStr = sprintf('%s: elapsed time %3.1f min',anID,(toc(ARDUINO.t0))/60);
        sendBehaviorMessage(str,subjectStr,userID);
        tNextMessage = tNextMessage + tMessages;
    end
        
    
    % Stop if nH > maxTotHits
    if ~isnan(maxTotHits) && nH > maxTotHits        
        fprintf('Session stopped. Max number of hits (%d) reached\n',maxTotHits);
        
        % send text
        str = strPerfo(respMTX,MTXTrialType,N);
        subjectStr = sprintf('%s: auto-stopped',anID);
        sendBehaviorMessage(str,subjectStr,userID);
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
params.soundParams = soundParams;
params.rateList = allRate;
params.soundCloudSeq = soundCloudSeq;
[~,systName] = system('hostname');
params.systName = systName(1:end-1);

data.params = params;
data.response = response;

% Check or Create folder for anID
cd(HFRootFolder)
if exist('Data','dir') == 0
    mkdir(pwd,'Data');
end
if exist(['Data' filesep 'SoundCloudDiscr'],'dir') == 0
    mkdir('Data','SoundCloudDiscr');
end

if exist(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID],'dir') == 0
    mkdir(['Data' filesep 'SoundCloudDiscr'],['AN' anID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
saveName = sprintf('ToneDisc_AN%s_%s',anID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idArd = 1;
while exist(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID filesep saveName '.mat'],'file') && idArd <= length(alphabets)
    if idArd == 1
        saveName(end+1) = alphabets(idArd);
    else
        saveName(end) = alphabets(idArd);
    end
    idArd = idArd+1;
end

% save
save(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID filesep saveName],'data');
fprintf('Data was saved properly\n');

%% CLEAN UP =========================================

lever_cleanArduino(ARDUINO.in);
if outputConnected; lever_cleanArduino(ARDUINO.out); end


%% DISPLAY SESSION AVERAGES  ========================

plotSessionAverages(data)
%% SAVE FIGURES
if exist(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID filesep 'Figures'],'dir') == 0
    mkdir(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID],'Figures');
end

figure(1)
savefig(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID filesep 'Figures' filesep saveName '_Performances'])
% figure(2)
% savefig(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID filesep 'Figures' filesep saveName '_FullSessionTraces'])
figure(3)
savefig(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID filesep 'Figures' filesep saveName '_Rasters'])
figure(4)
savefig(['Data' filesep 'SoundCloudDiscr' filesep 'AN' anID filesep 'Figures' filesep saveName '_BehMetrics'])