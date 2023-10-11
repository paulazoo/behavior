%
clear all; close all; clc;
setUpDirHFB;
cd(HFRootFolder);

% PARAMS ==================================================================
% ANIMAL ID
% clc;
% if nargin < 1
anID = input('Please enter animal ID:\n','s');
userID = input('Pleaser enter your text ID (Ex.: VBP or GD or DHY):\n','s');
% end


% Define params
params = defineParamsToneDiscrimination(anID);
    if ~isstruct(params) && isnan(params)
    return
end

% N s ---
nTrials = params.nTrials;
amountReward = params.amountReward;
fractNoGo = params.fractNoGo;

% Durations ---
foreperiod = params.durations.foreperiod;
% dur_preReward = params.durations.preReward;
dur_ITI = params.durations.ITI;
dur_consumption = params.durations.rewardConsumption;
dur_decision = params.durations.decision;
durPuff = params.durations.puff;
durPreReinforce = params.durations.preReinforcement; 

% Detection ---
mvt_thresh = params.mvt.thresh; % in Volts to initiate a trial
noMvt_thresh = params.mvt.noMvtThresh;

% Tone selection --- t
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

    reply = input(['Are these control laser experiments? Y/N [N]:'],'s');
    if isempty(reply)
        reply = 'N';
    end
    if strcmp(reply,'N') || strcmp(reply,'n')
        params.laserCtrlIO = false;
    end
end



% SETUP ===================================================================
durValveL = water_reward2duration(amountReward,2);

% Open communication with Arduino ---
[ardIn,ardOut] = lever_cardSetUpInOutV2;
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;
ARDUINO.idx = 1;

% Initialize variables ---
estSamplingRate = 250;
estDur = 70; %minutes
nSamples = estSamplingRate*60*estDur;
ARDUINO.data = nan(nSamples,7);

responseMTXheader = {'timeTrialStart';'timeTone';'leverPressed';'timePressed';'MVT0';'earlyPress'};
respMTX = nan(nTrials,6);
nM = 0;
nH = 0;
% Randomize trials ---
MTXTrialType = toneDiscrRandomizeTrial(nTrials,toneSelect,fractNoGo,foreperiod.settings, paramsLaser);

% Keyboard ---
if strcmp(computer,'MACI64');
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
end
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Sound ---
snd = soundInitII;
vol = [75:-10:45 75:-10:45]; % BASED ON CALIBRATION

% Reference movement ---
fprintf('Finding MVT0\n');
MVTBL = referenceMVTV2(ARDUINO,100);
pause(2);

% Training
noGoSwitch = false;

% Timing message
tNextMessage = tMessages;

% Initialize graph
lh = printPerfo(respMTX,MTXTrialType,1);


% RUN TRIALS ==============================================================
% =========================================================================
% FUTURE: here will be the trigger
ARDUINO.t0 = tic;
idArd = 1; % index increase everytime arduino is sampled
N = 1;
% flushinput(ard);
% [t(k),y] = lever_readArduino(ard,t0);
% leverMVT(k) = y(1);

while N <= nTrials && ESC
    % For training mode
    if noGoSwitch
        MTXTrialType(N,2) = 0;
        MTXTrialType(N,3) = 1;
    end
    
    % Load params specific for each trial 
    trialType = MTXTrialType(N,2);
    soundID = MTXTrialType(N,3);
    durFore = MTXTrialType(N,4);
    laserIO = MTXTrialType(N,5);
        
    % DISPLAY TRIAL NUMBER & TRIAL TYPE
    fprintf('\n\nTrials %i of %i: ',N,nTrials);
    if trialType > 0
        fprintf('GO')
    elseif trialType < 1
        fprintf('NO-GO')
    end
    fprintf('\n');
        
    % ITI ==================================
    fprintf('ITI: %3.1f sec\n',dur_ITI);
    fprintf(ardOut,'I'); % LED ON
    FIRSTFLAG = true;
    isMVT = true;
    while isMVT && ESC
        if ARDUINO.idx == 1
            MVT0 = mean(MVTBL);
        else
            MVT0 = ARDUINO.data(ARDUINO.idx-1,2);
        end
        paramsDetectMVT = [dur_ITI MVT0 noMvt_thresh];
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
    fprintf(ardOut,'J'); % LED OFF 
    id0 = ARDUINO.data(:,1) > ARDUINO.data(ARDUINO.idx-1,1) - dur_ITI;
    MVT0 = nanmedian(ARDUINO.data(id0,2));% calculate BL based on ITI
    respMTX(N,5) = MVT0;
    
    % LASER ON - ARCH EXPERIMENTS =====================================
    if laserIO > 0 && laserMode == 1
        fprintf(ardOut,'A'); % Send a pulse to digidata
        fprintf('LASER!')
    end
    
    % FOREPERIOD ==================================
    fprintf('\nForeperiod\n',durFore);
    respMTX(N,1) = toc(ARDUINO.t0); % TRIAL START
    isMVT = false;
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
        fprintf('Tone  %i dB  @ (%3.1f sec)\n', vol(soundID), durFore);
        respMTX(N,6) = false;
        respMTX(N,2) = toc(ARDUINO.t0);
        % LASER ON - ChR2 EXPERIMENTS =====================================
        if laserIO > 0 && laserMode == 2
            fprintf(ardOut,'A'); % Send a pulse to digidata
            fprintf('LASER!')
        end        
        soundPlay(soundID,snd);
    end
    
    if respMTX(N,6) < 1
        % RESPONSE ================
        paramsDetectMVT = [dur_decision MVT0 mvt_thresh];
        isMVT = false;
        [ARDUINO,isMVT,ESC] = detectMVTV2(ARDUINO,paramsDetectMVT,escapeKey);
        if isMVT
            fprintf('Lever pressed\n');
            respMTX(N,3) = true;
            respMTX(N,4) = ARDUINO.data(ARDUINO.idx-1,1);
        elseif ~ESC
            fprintf('ESC pressed. Exit behavior!\n');
        else
            fprintf('No response\n');
            respMTX(N,3) = false;
        end
        
        % PRE-REINFORCEMENT ====================
        ARDUINO = recMVTV2(ARDUINO,durPreReinforce);
        
        % REINFORCEMENT ==============
        if trialType > 0
            durReinforce = durValveL;
%             durPost = dur_consumption;
            if isMVT
                fprintf('HIT\n')
                % HIT: Water reward
                fprintf(ARDUINO.out,'E'); % LEFT VALVE
                nH = nH + 1 ; % Total number of hits
            elseif ~isMVT
                fprintf('MISS\n');
            end
        elseif trialType < 1
            durReinforce = durPuff;
            if isMVT
                fprintf('FALSE ALARM\n');
                % FALSE ALARM: Air Puff
                fprintf(ARDUINO.out,'L'); % AIR LEFT
%                 durPost = 2*dur_consumption;
            elseif ~isMVT
                fprintf('CORR. REJECTION\n');
%                 durPost = dur_consumption;
            end
        end
        ARDUINO = recMVTV2(ARDUINO,durReinforce);
        fprintf(ardOut,'O');
        fprintf(ardOut,'M');
        
        
        % Post trial (consumption)  ========================================================================================
        ARDUINO = recMVTV2(ARDUINO,dur_consumption);
        fprintf(ardOut,'I'); % LED ON
        
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
[~,systName] = system('hostname');
params.systName = systName(1:end-1);

data.params = params;
data.response = response;

% Check or Create folder for anID
cd(HFRootFolder)
if exist('Data','dir') == 0
    mkdir(pwd,'Data');
end
if exist('Data\ToneDiscrimination','dir') == 0
    mkdir('Data','ToneDiscrimination');
end

if exist(['Data\ToneDiscrimination\AN' anID],'dir') == 0
    mkdir('Data\ToneDiscrimination',['AN' anID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
saveName = sprintf('ToneDisc_AN%s_%s',anID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idArd = 1;
while exist(['Data\ToneDiscrimination\AN' anID '\' saveName '.mat'],'file') && idArd <= length(alphabets)
    if idArd == 1
        saveName(end+1) = alphabets(idArd);
    else
        saveName(end) = alphabets(idArd);
    end
    idArd = idArd+1;
end

% save
save(['Data\ToneDiscrimination\AN' anID '\' saveName],'data');
fprintf('Data was saved properly\n');

%% CLEAN UP =========================================

lever_cleanArduino(ARDUINO.in);
lever_cleanArduino(ARDUINO.out);


%% DISPLAY LEVER and LICK SPOUT timing of trial  ========================


figure;
pos = get(gcf,'position');
% LEVER
ax(1) = subplot(2,1,1);
t = ARDUINO.data(:,1);
X = ARDUINO.data(:,2);
tTrial = respMTX(:,[1 2 4]);
tTrial = tTrial(~isnan(tTrial(:,1)),:);
hold all;
plot(t,X,'-k','linewidth',0.5);
YL = ylim;
Y = diff(YL)*0.95+YL(1);
plot(tTrial(:,1),Y,'xr')
plot(tTrial(:,2),Y,'db')
plot(tTrial(:,3),Y,'vm')
setUpPlotCompact;
xlabel('Time (s)');
ylabel('Lever (V)');

% Lick
ax(2) = subplot(2,1,2);
t = ARDUINO.data(:,1);
X = abs([0; diff(ARDUINO.data(:,3)) > 0]);
tTrial = respMTX(:,[1 2 4]);
tTrial = tTrial(~isnan(tTrial(:,1)),:);
hold all;
plot(t,X,'-k','linewidth',0.5);
YL = ylim;
Y = YL(2);
plot(tTrial(:,1),Y,'xr')
plot(tTrial(:,2),Y,'db')
plot(tTrial(:,3),Y,'mv')
setUpPlotCompact;
xlabel('Time (s)');
ylabel('Lick (I/O)');

linkaxes(ax,'x')