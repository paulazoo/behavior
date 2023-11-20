function MTXTrialType = conditioningRandomizeTrial(nTrials,toneSelect,paramITI,fractPunish)
% function MTXTrialType = conditioningRandomizeTrial(nTrials,toneSelect,ITI)
% % EXAMPLE:
% nTrials = 301;
% toneSelect = 1...3; 1 = reward only; 2 = reward/neutral; 3 = reward/neutral/punishment
% ITI = [2 10]; [mu max]

trialID = 1:nTrials;

%% Randomize trial type

a = repmat(1:toneSelect,1,toneSelect); % add a little bit of complexity to the randomization
% remove punishment trials (25% for toneSelect ==3)
if toneSelect == 3
    a(end) = [];
end
idx = vecOfRandPerm(length(a),nTrials);
trialType = a(idx)';


% %% Randomize tone
% a = 1:toneSelect; %GO;
% b = a+4; %noGo
% idx1 = vecOfRandPerm(length(a),nTrials);
% idx2 = vecOfRandPerm(length(b),nTrials);
% X = [a(idx1); b(idx2)];
% toneID = nan(size(trialType));
% toneID(trialType == 0) = X(1,1:sum(trialType == 0));
% toneID(trialType == 1) = X(2,1:sum(trialType == 1));


%% Dur foreperiod
durITI = zeros(nTrials,1) + paramITI(2);
while any(durITI >= paramITI(2)) % Values higher than max ITI get re-shuffled
    i = durITI >= paramITI(2);
    N = sum(i);
    durITI(i) = exprnd(paramITI(1),1,N);
end
durITI = round(durITI,2);


%% Some checkups
if size(trialID,2) == 1
    trialID = trialID';
end
if size(trialType,2) == 1
    trialType = trialType';
end
if size(durITI,2) == 1
    durITI = durITI';
end

% Concatenate in one matrix [TRIAL#; TRIALTYPE(1=rew / 2=punish / 3=neutral); durITI]
MTXTrialType = [trialID; trialType; durITI]';