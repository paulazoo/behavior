function dataSpeed = extractSpeedPerSession(ANID)

fileNameWith = 'ToneDisc';
toneOrder = [1 2 3 4 8 7 6 5];

%% Select specific filenames in the 'ANID' folder
HFR = HFRootFolder_GF;
P = [HFR filesep 'Data' filesep 'ToneDiscrimination' filesep ANID filesep]
FN = getfnamelist(P);
X = strfind(FN,fileNameWith);
idxSel = false(size(X));
for i = 1:length(X)
    if ~isempty(X{i})
        idxSel(i) = true;
    end
end
FN = FN(idxSel);


%% Calculate metrics for each FN
nSess = length(FN);
for f = 1:nSess
    fprintf('%s: processing session %i of %i\n',ANID,f,nSess)
    %% Load data
    load([P FN{f}])
    % Load settings for each session
    % Find date
    idx = findstr(FN{f},'_');
    idx = idx(2)+1;
    d = FN{f}(idx:idx+10);
    dateID(f,1) = datenum(d);
    
    %% Load other params for session info (durPreReinf; nTone; laserIO_
    nTone(f,1) = data.params.toneSelection;
    if isfield(data.params.durations,'preReinforcement')
        durPreReinf(f,:) = data.params.durations.preReinforcement;
    else
        durPreReinf(f,:) = 0;
    end
    if isfield(data.params,'laser')
        if isfield(data.params,'laserCtrlIO')
            laser(f,:) = data.params.laser(1) > 0 && data.params.laserCtrlIO < 1;
        else
            laser(f,:) = data.params.laser(1) > 0;
        end
    else
        laser(f,:) = 0;
    end
    
    if laser(f) > 0
        if length(data.params.laser) > 2
            laser(f) = data.params.laser(3);
        else
            laser(f) = 1;
        end
    end
    
    laserLoc(f) = 1;
    if isfield(data.params,'laserLocation')
        laserLoc(f) = data.params.laserLocation;
    end
    %% Load performance for each session
    MTXTrialType = data.params.MTXTrialType;
    respMTX = data.response.respMTX;
    N = size(respMTX,1);
    MTXTrialType = MTXTrialType(1:N,:);
    if size(MTXTrialType,2) > 4
        Las = MTXTrialType(:,5) > 0;
    else
        Las = false(N,1);
    end
    RT = respMTX(:,4) - respMTX(:,2);
    early = respMTX(:,6) > 0 & ~Las;
    nTrials(f) = N - sum(Las);
    
    
    %% Calculate nPress and nTrial per tone; reaction time
    for i = 1:length(toneOrder)
        idTone = MTXTrialType(:,3) == toneOrder(i);
        nPressTone(f,i) = sum(respMTX(:,3) > 0 & idTone & ~early & ~Las);
        nTrialTone(f,i) = sum(idTone & ~early & ~Las);
        nPressToneLas(f,i) = sum(respMTX(:,3) > 0 & idTone & ~early & Las);
        nTrialToneLas(f,i) = sum(idTone & ~early & Las);
        RTTone(f,i) = mean(RT(respMTX(:,3) > 0 & idTone & ~early & ~Las));
    end
    
    %% Calculate speed around winPress ==================
    winPress = [-0.05 0.02];
    %     if data.params.toneSelection > 1
    %% setUp
    tArd = data.response.dataArduino(:,1);
    sr = 1/mean(diff(tArd));
    lever = data.response.dataArduino(:,2)*20.025; % Convert to degrees
    speed = [ 0; abs(diff(lever))];
    speed = speed * sr; % Conver to degrees / sec    
    
    %% Find index 'idx' of speed traces for press -----------------
    tAlign = respMTX(:,4); % Align
    idxAlign = nan(size(tAlign));
    for i = 1:length(tAlign)
        if ~isempty(find(tArd > (tAlign(i)) ,1))
            idxAlign(i) = find(tArd > (tAlign(i)),1)-1;
        end
    end
    
    %% Make raster of speed ---------------------
    A = makeRaster(speed,idxAlign(~isnan(idxAlign)),round(winPress*sr));
    tR = linspace(winPress(1),winPress(2),size(A,2));
    R = nan(length(idxAlign),size(A,2));
    if sum(~isnan(idxAlign)) > 1
        R(~isnan(idxAlign),:) = A;
    end
    
    % Calculate speed for each tone int -------------------------
    mSpeed = nan(size(R,2),length(toneOrder));
    mSpeedLas = nan(size(R,2),length(toneOrder));
    for i = 1:length(toneOrder)
        idTone = MTXTrialType(:,3) == toneOrder(i);
        selR = R(respMTX(:,3) > 0 & idTone & ~early & ~Las,:);
        mSpeed(:,i) = nanmean(selR,1);
        selR = R(respMTX(:,3) > 0 & idTone & ~early & Las,:);
        mSpeedLas(:,i) = nanmean(selR,1);

    end
    mSpeedTone(f,:) = nanmean(mSpeed);
    mSpeedToneLas(f,:) = nanmean(mSpeedLas);

    %     end
end



%%
% MERGE SESSIONS SAME DATE
d = unique(dateID);
k = 1;
for i = d'
    idx = find(dateID == i);
    
    N = sum(nTrials(idx)); % Exclude laser trials
    
    FileName(k,1) = FN(idx(1));
    ToneSelected(k,1) = max(nTone(idx));
    DurPreReinforcement(k,1) = mean(durPreReinf(idx));
    Laser(k,1) = mean(laser(idx));
    LaserLOCATION(k,1) = mean(laserLoc(idx));
    NumberOfTrials(k,1) = N;
    
    ResponseTone(k,:) = sum(nPressTone(idx,:),1)./sum(nTrialTone(idx,:),1);
    ReactionTone(k,:) = wmean(RTTone(idx,:),nTrialTone(idx,:),1);
    SpeedTone(k,:) = wmean(mSpeedTone(idx,:),nTrialTone(idx,:),1);
    %     ReactionTone(k,:) = sum(RTTone(idx,:),1)./sum(nTrialTone(idx,:),1);
    
    ResponseToneLaser(k,:) = sum(nPressToneLas(idx,:),1)./sum(nTrialToneLas(idx,:),1);
    SpeedToneLaser(k,:) = wmean(mSpeedToneLas(idx,:),nTrialToneLas(idx,:),1);
    k = k+1;
end
%%
dataSpeed.FN = FileName;
dataSpeed.nTone = ToneSelected;
dataSpeed.durPreReinf = DurPreReinforcement;
dataSpeed.laser = Laser;
dataSpeed.laserLoc = LaserLOCATION;
dataSpeed.nTrials = NumberOfTrials;
dataSpeed.response = ResponseTone;
dataSpeed.RT = ReactionTone;
dataSpeed.speed = SpeedTone;
dataSpeed.responseLas = ResponseToneLaser;
dataSpeed.speedLas = SpeedToneLaser;

