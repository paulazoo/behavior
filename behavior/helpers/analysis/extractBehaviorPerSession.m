function dataTBL = extractBehaviorPerSession(ANID)

ANID = 'ANJoey';
fileNameWith = 'ToneDisc';
cutUpRT = 0.8;
toneOrder = [4 3 2 1 8 7 6 5];

% Select specific filenames
cd(HFRootFolder_GF);
cd('Data');
cd('ToneDiscrimination');
P = [pwd filesep ANID filesep];
FN = getfnamelist(P);
X = strfind(FN,fileNameWith);
idxSel = false(size(X));
for i = 1:length(X)
    if ~isempty(X{i})
        idxSel(i) = true;
    end
end
FN = FN(idxSel);


nSess = length(FN);

for f = 1:nSess
    % Load data
    load([P FN{f}])
    % Load settings for each session
    % Find date
    idx = findstr(FN{f},'_');
    idx = idx(2)+1;
    d = FN{f}(idx:idx+10);
    dateID(f,1) = datenum(d);
    
    % Load other params
    nTone(f,1) = data.params.toneSelection;
    amountReward(f,1) = data.params.amountReward;
    responseTime(f,1) = data.params.durations.decision;
    foreDistro(f,:) = data.params.durations.foreperiod.settings;
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
    
    % Load and calculate performance for each session
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
    nH(f) = sum(MTXTrialType(:,3) == 5 & respMTX(:,3) > 0 & ~Las);
    nHCorr(f) = sum(MTXTrialType(:,3) == 5 & RT <= cutUpRT & ~Las);
    nM(f) = sum(MTXTrialType(:,3) == 5 & respMTX(:,3) < 1 & ~Las);
    nGo(f) = sum(MTXTrialType(:,3) == 5 & ~isnan(respMTX(:,3)) & ~Las);
    nFA(f) = sum(MTXTrialType(:,3) == 1 & respMTX(:,3) > 0 & ~Las);
    nCR(f) = sum(MTXTrialType(:,3) == 1 & respMTX(:,3) < 1 & ~Las);
    nNoGo(f) = sum(MTXTrialType(:,3) == 1 & ~isnan(respMTX(:,3)) & ~Las);
    early = respMTX(:,6) > 0 & ~Las; 
    nE(f) =  sum(early);
    nTrials(f) = N - sum(Las);
    [m,err] = mean_sem(RT,1);
    mRT(f,:) = [m err];
    
    for i = 1:length(toneOrder)
        idTone = MTXTrialType(:,3) == toneOrder(i);
        n = sum(idTone & ~early);
        nPressTone(f,i) = sum(respMTX(:,3) > 0 & idTone & ~early);
        nTrialTone(f,i) = sum(idTone & ~early);
        RTTone(f,i) = mean(RT(respMTX(:,3) > 0 & idTone & ~early));
    end
    
end

%%
% MERGE SESSIONS SAME DATE
d = unique(dateID);
k = 1;
for i = d'
    idx = find(dateID == i);
    
    N = sum(nTrials(idx));
    n1 = sum(nGo(idx));
    n2 = sum(nNoGo(idx));
    nPerSess = nGo(idx)+nNoGo(idx);
    
    FileName(k,1) = FN(idx(1));
    NoGoFract(k,1) = n2/(n1+n2);
    ToneSelected(k,1) = max(nTone(idx));
    RewardVolume(k,1) = (nPerSess*amountReward(idx))/sum(nPerSess);
    ResponseTime(k,1) = (nPerSess*responseTime(idx))/sum(nPerSess);
    DurPreReinforcement(k,1) = (nPerSess*durPreReinf(idx))/sum(nPerSess);
    Laser(k,1) = (nPerSess*laser(idx))/sum(nPerSess);
    NumberOfTrials(k,1) = N;
    HitRate(k,1) = sum(nH(idx))/n1*100;
    HitRateCorr(k,1) = sum(nHCorr(idx))/n1*100;
    FalseAlarmRate(k,1) = sum(nFA(idx))/n2*100;
%     Performance(k,1) = (sum(nHCorr(idx))+sum(nCR(idx)))/(n1+n2);
    EarlyPress(k,1) = sum(nE(idx))/N*100;
    ReactionTime(k,1) = (nPerSess*mRT(idx,1))/sum(nPerSess);
    ReactionTime(k,2) = (nPerSess*mRT(idx,2))/sum(nPerSess);
    
    ResponseTone(k,:) = sum(nPressTone(idx,:),1)./sum(nTrialTone(idx,:),1)*100;
    
    for j = 1:4
        cr = sum(nTrialTone(idx,j),1) - sum(nPressTone(idx,j),1);
        h = sum(nPressTone(idx,j+4),1);
        Performance(k,j) = (h + cr)/(sum(nTrialTone(idx,j+4),1)+sum(nTrialTone(idx,j),1))*100;
        dPrime(k,j) = d_prime(ResponseTone(k,j+4)/100,ResponseTone(k,j)/100);
    end
    ReactionTone(k,:) = wmean(RTTone(idx,:),nTrialTone(idx,:),1);
%     ReactionTone(k,:) = sum(RTTone(idx,:),1)./sum(nTrialTone(idx,:),1);
    k = k+1;
end
%%

sessID(:,1) = 1:nSess;
dataTBL = table(FileName, NoGoFract, ToneSelected, RewardVolume, ResponseTime, DurPreReinforcement, Laser, NumberOfTrials, HitRate, HitRateCorr, FalseAlarmRate,Performance,dPrime,EarlyPress,ReactionTime,ResponseTone,ReactionTone);


