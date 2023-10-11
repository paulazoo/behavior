function MTXTrialType = randomizeTrialGoNoGo(nTrials,stimSelect,fractGo,foreperiod,paramLaser)
% function MTXTrialType = randomizeTrialGoNoGo(nTrials,stimSelect,fractGo,foreperiod,paramLaser)
% New version for randomizing trial for a go/no-go task 
% More generalizable: 
% a) does not assume what kind of stimuli will
% be presented
% b) does not assume that 4 tones in each go/no-go could be potentially
% used.
% % EXAMPLE:
% nTrials = 301;
% stimSelect = [1 4]; % (1) = number of stim in each category. (2) = total
% potential stim. Stim are sorted from easy to difficult for each category
% fractGo = 0.4; %fraction of go trials.
% foreperiod = [0.65 0.2];
% paramLaser = [0.25 10]; %fractLaser trials; ntrial baseline (at the beginning of a session)
% % possible values for fractLaser: 0.5 0.4 1/3 0.3 1/4 0.2 0.1 0
nTonePerTrialType = 10;
trialID = 1:nTrials;

%% Randomize trial type (go vs no-go)
if round(fractGo*10) == 5
    nGo = 2;
    nNoGo = 2;
else
    [nGo,tot] =rat(round(fractGo*10)/10);
    nNoGo = tot-nGo;
end
a = [zeros(nGo,1); ones(nNoGo,1)];
idx = vecOfRandPerm(length(a),nTrials);
trialType = a(idx)';


%% Randomize tone identity for each stim
a = 1:stimSelect(1); %GO;
b = a+stimSelect(2); %NoGo
idx1 = vecOfRandPerm(length(a),nTrials);
idx2 = vecOfRandPerm(length(b),nTrials);
X = [a(idx1); b(idx2)];
stimID = nan(size(trialType));
stimID(trialType == 0) = X(1,1:sum(trialType == 0));
stimID(trialType == 1) = X(2,1:sum(trialType == 1));


%% Dur foreperiod
durFore = -ones(nTrials,1);
while any(durFore < 0) % Negative values get re-shuffled
    i = durFore < 0;
    N = sum(i);
    durFore(i) = randn(1,N)*foreperiod(2)+foreperiod(1);
end
durFore = round(durFore,2);

%% Create sequence laser trial
% fract laser has to be less or equal to 0.5 (50%)
if paramLaser(1) > 0.5
    warning('Fraction of laser trials cannot be more than 0.5; fractLaser adjusted back to 0.5');
    a = [0 1];
elseif round(paramLaser(1)*10) == 5
        a = [0 1];
elseif round(paramLaser(1)*10) == 4
    a = [0 1 0 1 0  1 0 0 1 0  1 0 1 0 0  0 0 1 0 1  0 1 0 1 0  0 1 0 0 1];
elseif paramLaser(1) == 1/3
    a = [0 0 1  0 1 0  1 0 0  0 1 0  0 1 0  1 0 0  1 0 1  0 0 0  1 0 0  0 1 0];
elseif paramLaser(1) == 1/4
    a = [0 0 0 1  0 0 1 0  0 1 0 0  1 0 0 0  1 0 0 0  0 0 1 0  0 1 0 0  0 0 0 1];
elseif round(paramLaser(1)*10) == 3
    a = [0 0 1 0 0 1 0 0 1 0  0 1 0 0 0 1 0 0 1 0  0 0 1 0 0 0 1 0 0 1];
elseif round(paramLaser(1)*10) == 2
    a = [0 0 0 0 1  0 0 0 1 0  0 0 1 0 0  0 1 0 0 0  1 0 0 0 0  0 1 0 0 0];
elseif round(paramLaser(1)*10) == 1
    a = [0 0 0 0 0 0 0 0 0 1  0 0 0 0 1 0 0 0 0 0  0 1 0 0 0 0 0 0 0 0  0 0 0 0 0 1 0 0 0 0];
else
    a = 0;
end

idx = repmat(1:length(a),1,ceil(nTrials/length(a)));
laserIO = a(idx)';
laserIO = laserIO(1:nTrials);

% Set 1st trials (paramLaser(2)) to no laser excitation
if paramLaser(2) >= 1
    laserIO(1:round(paramLaser(2))) = 0;
end

%% Some checkups
if size(trialID,2) == 1
    trialID = trialID';
end
if size(trialType,2) == 1
    trialType = trialType';
end
if size(stimID,2) == 1
    stimID = stimID';
end
if size(durFore,2) == 1
    durFore = durFore';
end
if size(laserIO,2) == 1
    laserIO = laserIO';
end

% Concatenate in one matrix [TRIAL#; TRIALTYPE(0 no-go / 1 go); TONEID; durFOREPERIOD]
MTXTrialType = [trialID; trialType; stimID; durFore; laserIO]';