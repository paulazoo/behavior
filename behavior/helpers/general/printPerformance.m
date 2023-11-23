function str = printPerformance(respMTX,MTXTrialType,N)
respWindow4Hit = 0.8; % Used for Hrate corrected

% PRINT PERFORMANCE ========================================================================================
RT = respMTX(:,4) - respMTX(:,2);
nH = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) > 0);
nM = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) < 1);
nFA = sum(MTXTrialType(:,2) < 1 & respMTX(:,3) > 0);
nCR = sum(MTXTrialType(:,2) < 1 & respMTX(:,3) < 1);
HRate = nH/sum(MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3)))*100;
HRateCorr = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) > 0 & RT < respWindow4Hit)/sum(MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3)))*100;
FARate = nFA/sum(MTXTrialType(:,2) < 1 & ~isnan(respMTX(:,3)))*100;
Perfo = (nH + nCR)/(nH + nM + nFA + nCR)*100;
nE = sum(respMTX(:,6) > 0);
Early = nE/N*100;

str = sprintf('SUMMARY TRIAL #%i:\nH=%i M=%i FA=%i CR=%iE=%i\nHR = %3.1f%% HRCORR = %3.1f%% FAR = %3.1f%% OVERALL = %3.1f%%ER = %3.1f%%\n',N,nH, nM,nFA,nCR,nE,HRate,HRateCorr,FARate,Perfo,Early);