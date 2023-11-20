function [overall, corrL, corrR, bias] = checkPerfo(response,N,messageIO)
    if nargin < 2
        N = length(response.timeTrialStart);
        if nargin < 3
            messageIO = false;
        end
    end
    
    nDecisionR = sum(response.decision(1:N) == 1);
    nRwhenR = sum(response.blockType(1:N) == 1 & response.decision(1:N) == 1 & ~isnan(response.decision(1:N)));
    nR = sum(response.blockType(1:N) == 1 & ~isnan(response.decision(1:N)));
    nDecisionL = sum(response.decision(1:N) == 2);
    nLwhenL = sum(response.blockType(1:N) == 2 & response.decision(1:N) == 2 & ~isnan(response.decision(1:N)));
    nL = sum(response.blockType(1:N) == 2 & ~isnan(response.decision(1:N)));
    nMiss = sum(response.decision(1:N) == -1);
    nBoth = sum(response.decision(1:N) == -2);
    nNoLever = sum(isnan(response.decision(1:N)));
    
    overall = (nLwhenL+nRwhenR)/(nL+nR)*100;
    corrL = nLwhenL/nL*100;
    corrR = nRwhenR/nR*100;
    bias = nDecisionL/(nDecisionL + nDecisionR)*100;
    
    if messageIO
        fprintf('SUMMARY TRIAL #%i:\n',N);
        fprintf('L=%i\tR=%i\tM=%i\tB=%i\tN/L=%i\n',nDecisionL, nDecisionR,nMiss,nBoth,nNoLever)
        fprintf('CORR LEFT = %3.1f%%\tRIGHT = %3.1f%%\tOVERALL = %3.1f%%\n',corrL,corrR,overall)
        fprintf('BIAS: PERCENTAGE LEFT = %3.1f%%\n',bias)
    end
