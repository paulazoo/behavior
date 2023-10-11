%
clear all; close all; clc;
setUpDirHFB;
cd(HFRootFolder);

% NOTES ON VERSION 3: Uses new way to read arduino (need to upload
% behaviorINV2 to arduino 'input'). Incorporate optogenetics code 3
% (inactivate at reinforcement). New way to initialize graph. New behavior

% performance graph at the end. (Saved in 'Figures' folder for each animal)

% PARAMS ==================================================================
% ANIMAL ID
% clc;
% if nargin < 1
anID = input('Please enter animal ID:\n','s');
userID = input('Please enter your text ID (Ex.: VBP or GD or KJ):\n','s');
% end

 
% Define params

params = defineParamsVisual(anID);
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

% Params visual stimuli
visProperties = params.visProperties;

% Stim selection --- t
stimSelect = params.stimSelection; % Range from 1o 4. 1 means only max. 2 means two max, ... and 4 all tone intensities

% Switches
trainingIO = params.training; % True for training for FA. Next trial is No-Go

% Auto-stop / Messaged
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
end

% DEVELOPMENT ONLY
outputConnected = true;

% SETUP ===================================================================
durValveL = water_reward2duration(amountReward,2);

% Open communication with Arduino ---
[ardIn,ardOut] = lever_cardSetUpInOutV3;
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;
ARDUINO.idx = 1;

% Initialize variables ---
estSamplingRate = 1/(11/ARDUINO.in.BaudRate*8);
estDur = 70; %minutes
nSamples = round(estSamplingRate*60*estDur);
ARDUINO.data = nan(nSamples,7);

responseMTXheader = {'timeTrialStart';'timeVisStim';'leverPressed';'timePressed';'MVT0';'earlyPress'};
respMTX = nan(nTrials,6);
nH = 0; % Value used to count the total number of hit before autostop.

% Randomize trials ---
MTXTrialType = toneDiscrRandomizeTrial(nTrials,stimSelect,fractNoGo,foreperiod.settings, paramsLaser);

% Keyboard ---
if strcmp(computer,'MACI64')
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
end
[~,~,keyCode] = KbCheck;
%% 
ESC = keyCode(escapeKey) == 0;

% Visual stim ---
[visTextures,scr,scrProperties] = visInit(visProperties);

% Sound cues init ---
snd = soundInitIII;

% Reference movement ---
fprintf('Finding MVT0\n');
MVTBL = referenceMVTV3(ARDUINO,100);
pause(2);

% Training
noGoSwitch = false;
% goSwitch = false;

% Timing message
tNextMessage = tMessages;

% Initialize graph
lh = initializePrintPerfo(nTrials);

% Flush com port and user data
lever_resetArduinoIn(ARDUINO.in);

% RUN TRIALS ==============================================================
% =========================================================================
% FUTURE: here will be the trigger
ARDUINO.t0 = tic;
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
    %     if goSwitch
    %         MTXTrialType(N,2) = 1;
    %         MTXTrialType(N,3) = 5;
    %     end
    
    % Load params specific for each trial
    trialType = MTXTrialType(N,2);
    visID = 5- (MTXTrialType(N,3) - floor((MTXTrialType(N,3)-1)/4)*4); % Some fix so it matches visual contrast idx. Not ideal but it works
    durFore = MTXTrialType(N,4);
    laserIO = MTXTrialType(N,5);
    
    % DISPLAY TRIAL NUMBER & TRIAL TYPE
    fprintf('\n\nTrials %i of %i: ',N,nTrials);
    if trialType > 0
        fprintf('GO')
    elseif trialType < 1
        %% 
        fprintf('NO-GO')
    end
    fprintf('\n');
    
    % ITI ==================================
    fprintf('ITI: %3.1f sec\n',dur_ITI);
    FIRSTFLAG = true;
    isMVT = true;
    while isMVT && ESC
        if ARDUINO.idx == 1
            MVT0 = mean(MVTBL);
        else
            MVT0 = ARDUINO.data(ARDUINO.idx-1,2);
        end
        paramsDetectMVT = [dur_ITI MVT0 noMvt_thresh];
        [ARDUINO,isMVT] = detectMVTV3(ARDUINO,paramsDetectMVT,escapeKey);
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
    soundPlay(13,snd);
    id0 = ARDUINO.data(:,1) > ARDUINO.data(ARDUINO.idx-1,1) - dur_ITI;
    MVT0 = nanmedian(ARDUINO.data(id0,2));% calculate BL based on ITI
    respMTX(N,5) = MVT0;
    
    % LASER ON - ARCH EXPERIMENTS =====================================
    if laserIO > 0 && laserMode == 1
        fprintf(ARDUINO.out,'A'); % Send a pulse to digidata
        fprintf('LASER!')
    end
    
    % FOREPERIOD ==================================
    fprintf('\nForeperiod=%1.3fsec\n',durFore);
    respMTX(N,1) = toc(ARDUINO.t0); % TRIAL START
    paramsDetectMVT = [durFore MVT0 mvt_thresh];
    [ARDUINO,isMVT,ESC] = detectMVTV3(ARDUINO,paramsDetectMVT,escapeKey);
    if isMVT
        fprintf('Lever pressed. Return to ITI\n');
        respMTX(N,6) = true;
        respMTX(N,4) = ARDUINO.data(ARDUINO.idx-1,1);
        % LASER OFF HERE NOT IMPLEMENTED YET <<<<<<<<<<<<<<<<<<<<<<<<<
    elseif ~ESC
        fprintf('ESC pressed. Exit behavior!\n');
        % LASER OFF HERE NOT IMPLEMENTED YET <<<<<<<<<<<<<<<<<<<<<<<<<
    else
        fprintf('Stim  %3.2f%%  @ (%3.1f sec)\n', visProperties.cntrst(visID)*100, durFore);
        respMTX(N,6) = false;
        respMTX(N,2) = toc(ARDUINO.t0);
        % LASER ON - ChR2 EXPERIMENTS =====================================
        if laserIO > 0 && laserMode == 2
            fprintf(ARDUINO.out,'A'); % Send a pulse to digidata
            fprintf('LASER!')
        end
    end
    
    if respMTX(N,6) < 1 % If no mvt during foreperiod. The trial continues then
        
        % VIS STIM and lever monitoring ====================
        tStart = tic;
        deltaMVT = 0;
        thresh = mvt_thresh;
        FlipFlag = true;
        FirstFlag = true;
        nFlip = 0;
        pixPerCycle = ceil(1/visProperties.sf);
        while toc(tStart) <= visProperties.dur && any(deltaMVT < thresh) && ESC
            if FlipFlag
                % Create texture of gratings offset by temporal frequency *
                % pixPerCycle
                xoffset = mod(toc(tStart)*visProperties.tf(trialType+1)*pixPerCycle,pixPerCycle);
                srcRect=[xoffset 0 xoffset + scrProperties.size(1)*2 scrProperties.size(2)*2];
                Screen('DrawTexture', scr, visTextures{visID}, srcRect, [],  visProperties.angle(trialType+1));
                
                if FirstFlag % First flip of the serie. Done in sync with VBL. Scripts wait for the flip to be done in order to obtain a precise flip0 measurement.
                    flip0 = Screen('Flip',scr);
                    FirstFlag = false;
                else % Other flips are done with VBL but the script doesn't wait for it.
                    Screen('Flip', scr, 0,0,1);
                end
                nFlip = nFlip+1;
                FlipFlag = false;
            end
            
            %% Insert code here to monitor behavior
            d = lever_readArduinoV3(ARDUINO.in,ARDUINO.t0);
            nLines = size(d,1);
            ARDUINO.data((1:nLines)-1+ARDUINO.idx,:) = d;
            ARDUINO.idx = ARDUINO.idx+nLines;
            
            lev = d(:,2);
            deltaMVT = abs(lev-MVT0);
            [~,~,keyCode] = KbCheck;
            ESC = keyCode(escapeKey) == 0;
            
            % This part of the code monitor if a flip is needed
            if GetSecs-flip0 > scrProperties.ifi*(nFlip-1)+scrProperties.ifi*0.95
                FlipFlag = true;
            end
            
        end        
        % Blank
        Screen('DrawTexture',scr,visTextures{5});
        Screen('Flip', scr, 0, 0, 1);
        
        % MVT detected?
        isMVT = true;
        if any(deltaMVT < thresh)
            isMVT = false;
        end
        
        % RESPONSE =========================================
        % Case which dur_decision is longer than vis stim
        if ~isMVT && dur_decision > visProperties.dur
            paramsDetectMVT = [dur_decision-visProperties.dur MVT0 mvt_thresh];
            [ARDUINO,isMVT,ESC] = detectMVTV3(ARDUINO,paramsDetectMVT,escapeKey);
        end
        
        % Register response
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
        [ARDUINO,ESC] = recMVTV3(ARDUINO,durPreReinforce,escapeKey); 
        
        %%LASER ON - ARCH LASER DURING REINFORCEMENT
        if laserIO > 0 && laserMode == 3
            fprintf(ARDUINO.out,'A'); % Send a pulse to digidata
            fprintf('LASER!')
        end
        
        % REINFORCEMENT ==============
        if trialType > 0
            durReinforce = durValveL;
            %             durPost = dur_consumption;
            if isMVT
                fprintf('HIT\n')
                % HIT: Water reward
                if outputConnected; fprintf(ARDUINO.out,'E'); end % LEFT VALVE
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
        [ARDUINO,ESC] = recMVTV3(ARDUINO,durReinforce,escapeKey);
        if outputConnected; fprintf(ARDUINO.out,'O'); end
        if outputConnected; fprintf(ARDUINO.out,'M'); end
        
        
        % Post trial (consumption)  ========================================================================================
        [ARDUINO,ESC] = recMVTV3(ARDUINO,dur_consumption,escapeKey);
        %fprintf(ARDUINO.out,'I'); % LED ON
        
        % PRINT PERFORMANCE ========================================================================================
        %         tic
        if ~exist('lh','var')
            lh = printPerfo(respMTX,MTXTrialType,N);
        else
            lh = printPerfo(respMTX,MTXTrialType,N,lh);
        end
        %         toc
        
        % FOR training mode. Repeat no-go trial if previous FA.
        if trainingIO > 0
            if MTXTrialType(N,2) < 1 && respMTX(N,3) > 0
                noGoSwitch = true;
            else
                noGoSwitch = false;
            end
        end
        %         % FOR training mode. Repeat GO trial if previous MISS.
        %         if trainingIO > 0
        %             if MTXTrialType(N,2) == 1 && respMTX(N,3) == 0;
        %                 goSwitch = true;
        %             else
        %                 goSwitch = false;
        %             end
        %         end
        
    end
    
    if ~ESC
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;
    end
    
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

% Sreen close (done after saving in case)
Screen('CloseAll');
Priority(0);

%% SAVE  =======================================================

ARDUINO.data = ARDUINO.data(~isnan(ARDUINO.data(:,1)),:);
response.dataArduino = ARDUINO.data;
response.dataArduinoHeader = {'TimeMATLAB','MVT','LICK1','LICK2'};
response.respMTX = respMTX(1:N-1,:);
response.respMTXheader = responseMTXheader;

params.MTXTrialType = MTXTrialType(1:N-1,:);
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
if exist(['Data' filesep 'VisDiscrimination'],'dir') == 0
    mkdir('Data','VisDiscrimination');
end

if exist(['Data' filesep 'VisDiscrimination' filesep 'AN' anID],'dir') == 0
    mkdir(['Data' filesep 'VisDiscrimination'],['AN' anID]);
end

% Make sure you do not overwrite previous data by creating a different save
% name (append b,c,d,...)
saveName = sprintf('VisDisc_AN%s_%s',anID,date);
alphabets = 'bcdefghijklmnopqrstuvwxyz';
idAlph = 1;
while exist(['Data' filesep 'VisDiscrimination' filesep 'AN' anID filesep saveName '.mat'],'file') && idAlph <= length(alphabets)
    if idAlph == 1
        saveName(end+1) = alphabets(idAlph);
    else
        saveName(end) = alphabets(idAlph);
    end
    idAlph = idAlph+1;
end

% save
save(['Data' filesep 'VisDiscrimination' filesep 'AN' anID filesep saveName],'data');
fprintf('Data was saved properly\n');

%% CLEAN UP =========================================

if outputConnected; lever_cleanArduino(ARDUINO.out); end
clear ARDUINO



%% DISPLAY SESSION AVERAGES  ========================

plotSessionAverages(data)
%% SAVE FIGURES
if exist(['Data' filesep 'VisDiscrimination' filesep 'AN' anID filesep 'Figures'],'dir') == 0
    mkdir(['Data' filesep 'VisDiscrimination' filesep 'AN' anID],'Figures');
end

figure(1)
savefig(['Data' filesep 'VisDiscrimination' filesep 'AN' anID filesep 'Figures' filesep saveName '_Performances'])
% figure(2)
% savefig(['Data\VisDiscrimination\AN' anID '\Figures\' saveName '_FullSessionTraces'])
figure(3)
savefig(['Data' filesep 'VisDiscrimination' filesep 'AN' anID filesep 'Figures' filesep saveName '_Rasters'])
figure(4)
savefig(['Data' filesep 'VisDiscrimination' filesep 'AN' anID filesep 'Figures' filesep saveName '_BehMetrics'])