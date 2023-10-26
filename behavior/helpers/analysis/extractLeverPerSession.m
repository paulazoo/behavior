function [allIdxTrialType,allRasterLever,tR,allRasterLick] = extractLeverPerSession(~)
%     allIdxTrialType: columns 1 o 7 = date; H; M; FA; CR; Tone intensity; RT
%     allRasterLever: raster of lever for each trial animal has performed;
%     tR: time raster;
%     allRasterLick: raster of lever for each trial animal has performed;

% Params
% ANID = 'ANDBH6';
ANID = 'ANRoss';
% toneInt = 45:10:75;
% c = setColor;
fileNameWith = 'ToneDisc';
win = [-5 5];
si = 0.01; % average sample interval of arduino

%%%% Select specific filenames
cd(HFRootFolder_GF);
cd('Data');
cd('ToneDiscrimination');
FN = getfnamelist([pwd filesep ANID])
X = strfind(FN,fileNameWith);
idxSel = false(size(X));
for i = 1:length(X)
    if ~isempty(X{i})
        idxSel(i) = true;
    end
end
FN = FN(idxSel);


%%%%%%% Find index order; find sessions with 4 tone selected
nSess = length(FN);
idSess = zeros(nSess,4); % 1st column = idDate; 2nd column = idNoGo; 3rd column = id4tone; 4th col = nTrials; 5th = LaserIO; 6th = LaserCTL; 7th = mvtThresh
for i = 1:nSess
    
    % Load data
    load([pwd filesep ANID filesep FN{i}])
    
    % Find date
    idx = strfind(FN{i},'_');
    idx = idx(2)+1;
    d = FN{i}(idx:idx+10);
    idSess(i,1) = datenum(d);
    
    % Find sess w/ NoGo
    if isfield(data.params,'fractGo') % Old mistake in naming this parameter
        idSess(i,2) = data.params.fractGo > 0;
    else
        idSess(i,2) = data.params.fractNoGo > 0;
    end
    
    % Find sess tone > 4, 5% Find sess tone > 1 for training, change number
    % based on run parameters
    % idSess(i,3) = data.params.toneSelection == 4; % if using all 4 tone
    % intensities
    idSess(i,3) = data.params.toneSelection == 1;
    
    % nTrials
    idSess(i,4) = size(data.response.respMTX,1);
    
%     % Find sess w/ Laser
%     if isfield(data.params,'laser')
%         idSess(i,5) = data.params.laser(1) > 0;
%         if isfield(data.params,'laserCtrlIO');
%             idSess(i,6) = data.params.laserCtrlIO;
%         else
%             idSess(i,6) = false;
%         end
%     else
%         idSess(i,5) = false;
%         idSess(i,6) = false;
%     end
    
end

%%%% Determine ntotal trials. Initialize matrix
nTot = sum(idSess(:,4));
allIdxTrialType = nan(nTot,8); % date; H; M; FA; CR; Tone intensity; RT; Laser (no = 0; laser = 1; ctl = 2); mvtThresh
allRasterLever = nan(nTot,diff(round(win/si))+1);
allRasterLick = nan(nTot,diff(round(win/si))+1);
tR = linspace(win(1),win(2),size(allRasterLever,2));

k = 1;

for i = 1:nSess
    % Load data
    load([pwd filesep ANID filesep FN{i}])
    
    %%%% Determine date in allIdxTrialType
    x = k:k+idSess(i,4)-1;
    allIdxTrialType(x,1) = idSess(i,1);
    
    %%%%% Load idx for each type of trial
    MTXTrialType = data.params.MTXTrialType;
    respMTX = data.response.respMTX;
    N = size(respMTX,1);
    MTXTrialType = MTXTrialType(1:N,:);
    tStart = respMTX(:,1);
    tTone = respMTX(:,2);
    idx = false(N,4);
    idx(:,1) = MTXTrialType(:,2) > 0 & respMTX(:,3) > 0; % Hit
    idx(:,2) = MTXTrialType(:,2) > 0 & respMTX(:,3) < 1; % Miss
    idx(:,3) = MTXTrialType(:,2) < 1 & respMTX(:,3) > 0; % FA
    idx(:,4) = MTXTrialType(:,2) < 1 & respMTX(:,3) < 1; % CR
    allIdxTrialType(x,2:5) = idx;
    % Tone intensity
    tInt = MTXTrialType(:,3);
    tInt = mod(tInt,4);
    tInt(tInt == 0) = 4;
    tInt = 5 - tInt;
    allIdxTrialType(x,6) = tInt; % 1 = low; 4 = high
    % Reaction time
    RT = respMTX(:,4) - respMTX(:,2);
    allIdxTrialType(x,7) = RT;
    % Laser
    ctlIO = false;
    if isfield(data.params,'laser')
        if isfield(data.params,'laserCtrlIO');
            ctlIO = data.params.laserCtrlIO;
        else
            ctlIO = false;
        end
    end
    if size(MTXTrialType,2) == 5
        Las = MTXTrialType(:,5) * (ctlIO + 1);
    else
        Las = zeros(N,1);
    end
    allIdxTrialType(x,8) = Las;
    % MVT thresh
    allIdxTrialType(x,9) = data.params.mvt.thresh;
    
    %%%%%% Extract lever
    tLever = data.response.dataArduino(:,1);
    Lever = data.response.dataArduino(:,2);
    [Lever,tLever] = resample(Lever,tLever,1/si);
    Lever = lowPassFilterButter(Lever,1,4,2);
    
    %%%%%% Extract lick data
    Lick = ([0; diff(data.response.dataArduino(:,3))] > 0) + ([0; diff(data.response.dataArduino(:,4))] > 0)*2;
    n1 = sum(Lick == 1);
    n2 = sum(Lick == 2);
    if n1 > n2
        Lick = Lick == 1;
    else
        Lick = Lick == 2;
    end
    
    % Find idxLever
    idxLever = nan(length(tStart),2);
    
    for j = 1:length(tStart)
        if ~isempty(find(tLever >= tStart(j),1))
            idxLever(j,1) = find(tLever >= tStart(j),1);
        end
        if ~isnan(tTone(j))
            idxLever(j,2) = find(tLever >= tTone(j),1);
        end
    end
    R = nan(size(idxLever,1),diff(round(win/si))+1);
    R(~isnan(idxLever(:,2)),:) = makeRaster(Lever,idxLever(~isnan(idxLever(:,2)),2),round(win/si));
    allRasterLever(x,:) = R;
    R = nan(size(idxLever,1),diff(round(win/si))+1);
    R(~isnan(idxLever(:,2)),:) = makeRaster(Lick,idxLever(~isnan(idxLever(:,2)),2),round(win/si));
    allRasterLick(x,:) = R;
    
    k = k+idSess(i,4);
end

