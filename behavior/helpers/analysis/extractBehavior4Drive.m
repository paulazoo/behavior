function dataTBL = extractBehavior4Drive(ANID,messageOn)
if nargin < 2
    messageOn = true;
end
%Print out a table easy to copy paste into google drive

% ANID = 'ANTEST1';
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
    responseTime(f,1) = data.params.durations.decision;
    
    % Load opto params
    if isfield(data.params,'laser')
        if data.params.laser(1) > 0
            if length(data.params.laser) > 2
                optoType(f,1) = data.params.laser(3);
            else
                optoType(f,1) = 1;
            end
            if isfield(data.params,'laserLocation')
                laserLoc(f,1) = data.params.laserLocation;
            else
                laserLoc(f,1) = 1; 
            end
        else
            optoType(f,1) = 0;
            laserLoc(f,1) = 0;
        end
    else
        optoType(f,1) = 0;
        laserLoc(f,1) = 0;
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
laserExpStr = {'No opto' 'Arch/Jaws'  'ChR2'  'Arch/Jaws-Reinf' 'ArchSurprise'};
laserLocStr = {'N/D' 'LC' 'dmPFC' 'MC'};
d = unique(dateID);
k = 1;
for i = d'
    idx = find(dateID == i);
    
    N = sum(nTrials(idx));
    n1 = sum(nGo(idx));
    n2 = sum(nNoGo(idx));
    nPerSess = nGo(idx)+nNoGo(idx);
    
    ResponseTime(k,1)  = (nPerSess*responseTime(idx))/sum(nPerSess);    
    ToneSelected(k,1)  = max(nTone(idx));
    
    OptoExp = laserExpStr{max(optoType(idx)) + 1};
    OptoLoc = laserLocStr{max(laserLoc(idx)) + 1};
    NumberOfTrials(k,1)  = N;
    HitRateCorr(k,1)  = sum(nHCorr(idx))/n1*100;
    FalseAlarmRate(k,1)  = sum(nFA(idx))/n2*100;
    EarlyPress(k,1)  = sum(nE(idx))/N*100;
    
    ResponseTone = sum(nPressTone(idx,:),1)./sum(nTrialTone(idx,:),1)*100;
    dPrime(k,1) = d_prime(ResponseTone(8)/100,ResponseTone(4)/100);
    
    % Print results
    if messageOn
        fprintf('%s\t%2.2f\t%d\t%s\t%s\t%3.1f\t%3.1f\t%3.1f\t%3.2f\t%d\n',datestr(i),ResponseTime(k,1),ToneSelected(k,1),OptoExp,OptoLoc,HitRateCorr(k,1),EarlyPress(k,1),FalseAlarmRate(k,1),dPrime(k,1),NumberOfTrials(k,1))
    end
    k = k+1;
end

if nargout > 0
    dataTBL = table(ResponseTime,ToneSelected,HitRateCorr,EarlyPress,FalseAlarmRate,dPrime,NumberOfTrials);
end