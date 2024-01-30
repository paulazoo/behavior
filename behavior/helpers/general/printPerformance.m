function str = printPerformance(respMTX,MTXTrialType,N)
respWindow4Hit = 10; % Used for Hit corrected rate

% PRINT PERFORMANCE ========================================================================================
RT = respMTX(:,4) - respMTX(:,2);
nHits = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) > 0);
nM = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) < 1);
nFA = sum(MTXTrialType(:,2) < 1 & respMTX(:,3) > 0);
nCR = sum(MTXTrialType(:,2) < 1 & respMTX(:,3) < 1);
HRate = nHits/sum(MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3)))*100;
HRateCorr = sum(MTXTrialType(:,2) > 0 & respMTX(:,3) > 0 & RT < respWindow4Hit)/sum(MTXTrialType(:,2) > 0 & ~isnan(respMTX(:,3)))*100;
FARate = nFA/sum(MTXTrialType(:,2) < 1 & ~isnan(respMTX(:,3)))*100;
Perfo = (nHits + nCR)/(nHits + nM + nFA + nCR)*100;
nITIPress = sum(respMTX(:,6) > 0);
ITIPress = nITIPress/N*100;

str = sprintf('SUMMARY TRIAL #%i:\nHits=%i M=%i FA=%i CR=%i ITIPress=%i\nHR = %3.1f%% HRCORR = %3.1f%% FAR = %3.1f%% OVERALL = %3.1f%% ITIPressR = %3.1f%%\n',N,nHits, nM,nFA,nCR,nITIPress,HRate,HRateCorr,FARate,Perfo,ITIPress);