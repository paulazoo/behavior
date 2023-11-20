function dataOptoBeh = extractBehaviorOptoV2(ANID)
% clear all; close all; clc;
% V2: Outputs also trials that has 4 tones but laser is off
fileNameWith = 'ToneDisc';
toneOrder = [4 3 2 1 8 7 6 5];

showfig = false;

% Select specific filenames
cd(HFRootFolder_GF);
cd('Data');
cd('ToneDiscrimination');
P = [pwd filesep ANID filesep];
FN = getfnamelist(P);
X = strfind(FN,fileNameWith);
idxSel = false(size(X));
for i = 1:length(X)
    if ~isempty(X{i})
        idxSel(i) = true;
    end
end
FN = FN(idxSel);

if isempty(FN)
    error('Cannot find %s in the animal list',ANID)
end

nSess = length(FN);
for f = 1:nSess
    % Load data
    load([P FN{f}])
    % Load settings for each session
    % Find date
    idx = findstr(FN{f},'_');
    idx = idx(2)+1;
    d = FN{f}(idx:idx+10);
    dateID(f,1) = datenum(d);
    nTone(f,1) = data.params.toneSelection;
    
    if isfield(data.params,'laser')
        if length(data.params.laser) > 2
            o = data.params.laser(3);
        else
            o = 1;
        end
        
        laserIO(f,1) = data.params.laser(1) > 0;
        if isfield(data.params,'laserCtrlIO');
            laserCtl(f,1) = data.params.laserCtrlIO;
        else
            laserCtl(f,1) = false;
        end
    else
        laserIO(f,1) = false;
        laserCtl(f,1) = false;
    end
end

selDate = unique(dateID(nTone == 4));
% selDate = unique(dateID(laserIO));
selDateCtl = unique(dateID(laserIO & laserCtl));
n4Tones = length(selDate);

for i = 1:n4Tones
    d = selDate(i);
    idxFile = find(dateID == d);
    nTrials = zeros(2,1);
    nE = zeros(2,1);
    nPressTone = zeros(2,length(toneOrder));
    nTrialTone = zeros(2,length(toneOrder));
    %     rtCalcTone = zeros(2,length(toneOrder));
    rt = cell(2,8);
    
    for j = 1:length(idxFile)
        % Load response and trial type matrix
        load([P FN{idxFile(j)}])
        MTXTrialType = data.params.MTXTrialType;
        respMTX = data.response.respMTX;
        N = size(respMTX,1);
        MTXTrialType = MTXTrialType(1:N,:);
        RT = respMTX(:,4) - respMTX(:,2);
        
        % Determine type of optosession
        if isfield(data.params,'laser')
            laserON(i,1) = data.params.laser(1) > 0;
            if laserON(i,1)
                
                if length(data.params.laser) > 2
                    optoType(i,1) = data.params.laser(3);
                else
                    optoType(i,1) = 1;
                end
                
                if isfield(data.params,'laserLocation')
                    laserLocation(i,1) = data.params.laserLocation;
                else
                    laserLocation(i,1) = 1;
                end
            else
                laserLocation(i,1) = nan;
                optoType(i,1) = nan;
            end
        else
            laserON(i,1) = false;
            laserLocation(i,1) = nan;
            optoType(i,1) = nan;
        end
        
        for las = 1:2
            L = MTXTrialType(:,5) == las-1;
            
            % calculate nTrials and n early trials
            nTrials(las) = nTrials(las) + sum(L);
            early = respMTX(:,6) > 0;
            nE(las) =  nE(las) + sum(early & L);
            
            % Calculate n trials per tone and for each tone how many pressed
            for k = 1:length(toneOrder)
                idTone = MTXTrialType(:,3) == toneOrder(k);
                nPressTone(las,k) = nPressTone(las,k) + sum(respMTX(:,3) > 0 & idTone & ~early & L);
                nTrialTone(las,k) = nTrialTone(las,k) + sum(idTone & ~early & L);
                
                %                 if ~isempty(RT(respMTX(:,3) > 0 & idTone & ~early & L)))
                rt{las,k} = [rt{las,k}; RT(respMTX(:,3) > 0 & idTone & ~early & L)];
                %                 end
            end
            
        end
    end
    
    % figure;
    if showfig
        Y = nPressTone./nTrialTone;
        c = setColor;
        figure;
        hold all
        plot(1:4,Y(1,1:4),'-','color',c.red,'linewidth',1)
        plot(1:4,Y(1,5:8),'-','color',c.blue2,'linewidth',1)
        plot(1:4,Y(2,1:4),':','color',c.red,'linewidth',1)
        plot(1:4,Y(2,5:8),':','color',c.blue2,'linewidth',1)
    end
    
    % CALCULATE VALUES FOR EACH SESSION (COMBINED)
    CTL(i,1) = any(selDateCtl == selDate(i));
    NTRIALS(i,:) = nTrials;
    NEARLY(i,:) = nE;
    PRESS(i,:,:) = nPressTone;
    NTRIALSPERTONE(i,:,:) = nTrialTone;
    RESPONSE(i,:,:) = nPressTone./nTrialTone*100;
    for las = 1:2
        for k = 1:8
            REACTIONTIME(i,las,k) = nanmean(rt{las,k});
        end
    end
    
    % Dprime
    for las = 1:2
        for k = 1:4
            DP(i,las,k) = d_prime(RESPONSE(i,las,k+4)/100,RESPONSE(i,las,k)/100);
        end
    end
end

% Output
dataOptoBeh.laserON = laserON;
dataOptoBeh.ctlIO = CTL;
dataOptoBeh.optoType = optoType;
dataOptoBeh.laserLocation = laserLocation;
dataOptoBeh.nTotTrials = NTRIALS;
dataOptoBeh.nEarly = NEARLY;
dataOptoBeh.nPressedPerTone = PRESS;
dataOptoBeh.nTrialsPerTone = NTRIALSPERTONE;
dataOptoBeh.response = RESPONSE;
dataOptoBeh.rt = REACTIONTIME;


