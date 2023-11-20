function MTXTrialType = choiceSwitchRandomizeTrial(nTrials,nTrialPerBlock,fractRew,fractFreeTrial)
% function MTXTrialType = choiceSwitchRandomizeTrial(nTrials,nTrialPerBlock,fractRew,fractFreeTrial)
% EXAMPLE:
% nTrials = 300;
% nTrialPerBlock = [10 15]; %can be a range or single value
% fractRew = 0.75; %fraction to be rewarded per block
% fractFreeTrial = 1; %fraction to give reward on both choice per block. Overwrite fraction reward

% Randomize trial type
if nargin < 4
    fractFreeTrial = 0;
    if nargin < 3
        fractRew = 1;
    end
end

% Determine block duration in terms of trials
possibleBlockDur = nTrialPerBlock(1):nTrialPerBlock(end);
idx = vecOfRandPerm(length(possibleBlockDur),ceil(nTrials/min(possibleBlockDur)));
blockDur = possibleBlockDur(idx);
nBlocks = length(blockDur);

% Determine first block is left or right (random)
currBlockType = randi([1 2]);

% Create block structure
rew = [];
blockID = [];
blockType = [];
for i = 1:nBlocks
    B = ones(blockDur(i),1)*i;
    BT = ones(blockDur(i),1)*currBlockType;
    R = ones(blockDur(i),1)*currBlockType;
    a = zeros(blockDur(i),1);
    a(1:round(fractRew * blockDur(i))) = 1;
    a = a(randperm(blockDur(i))) == 0;
    R(a) = 0;
    a = zeros(blockDur(i),1);
    a(1:round(fractFreeTrial * blockDur(i))) = 1;
    a = a(randperm(blockDur(i))) == 1;
    R(a) = 3;
    
    rew = [rew; R];
    blockID = [blockID; B];
    blockType = [blockType; BT];
    if currBlockType == 1
        currBlockType = 2;
    else
        currBlockType = 1;
    end
end

% Concatenate in one matrix [TRIAL# BLOCK# BLOCTYPE REW]
trialID = 1:length(blockID);
MTXTrialType = [trialID' blockID blockType rew];
MTXTrialType = MTXTrialType(1:nTrials,:);

% Some graph
% % Calculation of trial history probability
% A = MTXTrialType(:,4);
% nTrBack = 25;
% idx = repmat(1:nTrBack,length(A)-nTrBack,1)-nTrBack;
% b = nTrBack+1:length(A);
% trID = MTXTrialType(b,1);
% bID = MTXTrialType(b,3) == 1;
% idx = bsxfun(@plus,idx,b');
% B = A(idx) == 1;
% prob = mean(B,2);
% figure;
% hold all;
% area(trID,bID,'edgecolor','none','facecolor',[0.75 0.75 0.75])
% plot(trID,prob,'r')