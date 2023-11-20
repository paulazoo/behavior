function trialSequence = extractTrialSequence(ANID,padding)
%     trialSequence(:,1) = trID; % 0 = Early; 1 = Hit; 2 = Miss; 3 = False alarm; 4 = Corr. rejection;
%     trialSequence(:,2) = 4-mod(trType(:,3)+3,4); %convert [1 2 3 4 5 6 7 8] to [4 3 2 1 4 3 2 1]
%     trialSequence(:,3) = [diff(resp(:,1)); 0]; % delta time until next trial
%     trialSequence(:,4) = resp(:,4) - resp(:,2); % reaction time
%     trialSequence(:,5) = trType(:,5); % laser trial?

if nargin < 2
    padding = 25;
end


%% Select specific file names in the ANID folder %%%
str = 'ToneDisc';
% Select specific filenames
P = [HFRootFolder_GF filesep 'Data' filesep 'ToneDiscrimination' filesep ANID filesep];

if ~exist(P,'dir')
    error('Cannot find %s in the animal list',ANID{a})
end

FN = getfnamelist(P);
idxWith = cellfun(@(x) ~isempty(strfind(x,str)),FN);
FN = FN(idxWith);
if isempty(FN)
    error('Cannot find files with ''%s'' in ''%s'' directory',str,ANID{a})
end
%% Sort file name  by date
for f = 1:length(FN)
    idx = strfind(FN{f},'_');
    idx = idx(2);
    d(f) = datenum(FN{f}((1:10)+idx));
    
end

[~,iSort] = sort(d);
FN = FN(iSort);

%% Select FN with session with tone selected == 4 and training switch is off %%%
N = zeros(length(FN),1);
nSessFA = nan(length(FN),1);
idSelF = false(length(FN),1);
for f = 1:length(FN)
    % Load data
    load([P FN{f}])
    if isfield(data.params,'training'); trainIO = data.params.training > 0;
    else; trainIO = 0;  end
    if isfield(data.params,'trCrop'); excl = isnan(data.params.trCrop(1));
    else; excl = false; end
    if isfield(data.params,'fractNoGo')
        idSelF(f,1) = data.params.toneSelection == 4 && data.params.fractNoGo > 0 && trainIO < 1 && ~excl;
        nSessFA(f) = data.params.fractNoGo > 0; % Determine how many sessions with FA
    else
        idSelF(f,1) = data.params.toneSelection == 4 && data.params.fractGo > 0 && trainIO < 1 && ~excl;
        nSessFA(f) = data.params.fractGo > 0; % Determine how many sessions with FA
    end
    %         N(f,1) = size(data.response.respMTXCrop,1);
    N(f,1) = size(data.response.respMTX,1);
end

nSessFA = cumsum(nSessFA);
nSessFA = nSessFA(idSelF);
FN = FN(idSelF);
N = N(idSelF);
idSelF = find(idSelF);
%% Combine sequence of trials for all sessions %%%
nSess = length(FN);
nTrials = sum(N);
trialSequence = nan(nTrials+(nSess+1)*padding,10); % Trial type; Tone intensity; Elapsed time since previous trial
k = padding;
for f = 1:nSess
    % === Load data ====
    load([P FN{f}]);
    trType = data.params.MTXTrialType;
    resp = data.response.respMTX;
    trType = trType(1:size(resp,1),:);
    
    % === For laser trials determine location and if control experiment (laser
    % on but not plugged in) ===
    if isfield(data.params,'laser')        
        if isfield(data.params,'laserCtrlIO');
            laserCtl = data.params.laserCtrlIO > 0;
        else
            laserCtl = false;
        end
        
        if isfield(data.params,'laserLocation')
            laserLocation = data.params.laserLocation;
        else
            laserLocation = 1;
        end
        
        % 1 = full trial 3 = reinforcement only
        if length(data.params.laser) == 3
            laserType = data.params.laser(3);
        else
            laserType = 0;
        end
    else
        laserCtl = false;
        laserLocation = 0;
        laserType = 0;
    end
    
    if laserCtl
        trType(:,5) = 0; % set trial type to zero if control; future code will take care of that
    end
    trType(trType(:,5) > 0,5) = laserLocation; % location
    laserType = (trType(:,5) > 0) * laserType;
    
    
    %         if isfield(data.params,'MTXTrialTypeCrop')
    %             trType = data.params.MTXTrialTypeCrop;
    %             resp = data.response.respMTXCrop;
    %         else
    %             error('Data has not been cleaned up for %s\n',FN{f});
    %         end

    
    % Add data to trial sequence
    idxSequence = k:k+N(f)-1;
    k = k+N(f)+padding;
    GoNoGo = trType(:,2);
    Press = resp(:,3);
    H = GoNoGo == 1 & Press == 1;
    M = GoNoGo == 1 & Press == 0;
    FA = GoNoGo == 0 & Press == 1;
    CR = GoNoGo == 0 & Press == 0;
    trID = H + 2*M + 3*FA + 4*CR;
    trialSequence(idxSequence,1) = trID; % 0 = Early; 1 = Hit; 2 = Miss; 3 = False alarm; 4 = Corr. rejection;
    trialSequence(idxSequence,2) = 4-mod(trType(:,3)+3,4); %convert [1 2 3 4 5 6 7 8] to [4 3 2 1 4 3 2 1]
    trialSequence(idxSequence,3) = [diff(resp(:,1)); 0]; % delta time until next trial
    trialSequence(idxSequence,4) = resp(:,4) - resp(:,2); % reaction time
    trialSequence(idxSequence,5) = trType(:,5); % laser trial? # = location [1 = lc 2 = pfc 3 = mc]
    trialSequence(idxSequence,6) = laserType; % laser type? # = type [1= full trial 2=chr2 3= reinforcement]
    trialSequence(idxSequence,7) = f; % Number of session
    
    % Rewarded?
    if size(resp,2) > 6
        rew = resp(:,7);
    else % Case before cr rejection surprise existed
        rew = trID == 1;
    end
    trialSequence(idxSequence,8) = rew; % rewarded?
    
    trialSequence(idxSequence,9) = nSessFA(f); % Number of session with false alarms (used to study effect of N exposure to air puff to trial histo. effect
    trialSequence(idxSequence,10) = idSelF(f); % Number of session from begining
end

