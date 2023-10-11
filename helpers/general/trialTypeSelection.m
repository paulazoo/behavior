
function [response,nRewarded2Switch,nRewInBlock,NEWBLOCKFLAG] = trialTypeSelection(response,params,idTrial,NEWBLOCKFLAG)
    % Function to select the trial type before each trial. In comparison to
    % 'choiceSwitchRandomizeTrial' that pre-allocates all trial types at
    % beginning
    
    nTrialPerBlock = params.nTrialPerBlock;
    fractRew = params.fractRew;
    fractFreeTrial = params.fractFreeTrial; 
    
    % If new block pick block and Reward
    if NEWBLOCKFLAG
        if idTrial == 1
            % If first trial pick randomly the blockType
            response.blockID(idTrial) = 1;
            response.blockType(idTrial) =randi(2,1);
        else
            response.blockID(idTrial) = response.blockID(idTrial-1)+1;
            if response.blockType(idTrial-1) == 1
                response.blockType(idTrial) = 2;
            else
                response.blockType(idTrial) = 1;
            end
        end
        NEWBLOCKFLAG = false;
        nRewarded2Switch = randi([nTrialPerBlock(1) nTrialPerBlock(end)],1,1);
        nRewInBlock = 0;
    else % If not new blockType = prev blockType and blockID = prev blockID
        response.blockID(idTrial) = response.blockID(idTrial-1);
        response.blockType(idTrial) = response.blockType(idTrial-1);
    end
    
    % Pick rewID
    response.rewID(idTrial) = response.blockType(idTrial);
    if rand > fractRew
        response.rewID(idTrial) = 0;
    end
    if rand < fractFreeTrial
        response.rewID(idTrial) = 3;
    end
    
