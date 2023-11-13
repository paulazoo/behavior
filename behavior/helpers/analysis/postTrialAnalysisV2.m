clear; %close all; 
clc;

% Response after any type of trial done on all animals
% Version 2 :
%   - Now allows to run it directly from the data folder of
%   HeadFixedBehavior
%   - Also keeps track of date. Can split results by dates.
%   - Compares to shuffle
% WARNING: DO NOT USE THIS VERSION. IT HAS MAJOR ISSUES IN SHUFFLING AND IDENTIFYING POST
% TRIALS TONE IDENDITY. 

anList = {
    'ANDbhChR201'
    'ANDbhChR202'
    'ANDbhChR203'
    'ANDbhChR205'
    'ANDbhArch01'
    'ANDbhArch02'
    'ANDbhArch03'
    'ANDbhArch04'
    'ANDbhArch06'
    'ANGRIN02'
    'ANGRIN03'
    'ANGRIN05'
%     'ANDBH5'
%     'ANDBH7'
    'ANDBH11'
%     'ANDbh13'
    'ANDbh14'
    'ANDbh21'
    'ANDbh22'
    'ANGRABNE01'
    'ANGRABNE03'
    'ANGRABNE05'
    'ANGRABNE06'
    'ANGRABNE07'
    };
P = [HFRootFolder_GF 'Data' filesep 'ToneDiscrimination' filesep];

maxDeltaT = 10;
minNTrialsPerSession = 50;

kAllAN = 1;
dataAllAN = nan(length(anList)*5*4,7+4+4);
rng(2);
for an =1:length(anList)
    
    %% Select specific file names in the ANID folder %%%
    str = 'ToneDisc';
    FN = fileWith(str,[P filesep anList{an}]);
    if isempty(FN)
        error('Cannot find files with ''%s'' in ''%s'' directory',str,anList{an})
    end
    
    %% Select FN with session with tone selected == 4 and training switch is off  and n trials < minNTrialsPerSession %%%
    N = nan(length(FN),1);
    idDate = nan(length(FN),1);
    idSelF = false(length(FN),1);
    for f = 1:length(FN)
        % Load data
        load([P filesep anList{an} filesep FN{f}])
        if isfield(data.params,'training'); trainIO = data.params.training > 0;
        else; trainIO = false;  end
        if isfield(data.params,'trCrop'); excl = isnan(data.params.trCrop(1));
        else; excl = false; end
        if isfield(data.params, 'fractGo'); fractGo = data.params.fractGo > 0;
        else; fractGo = data.params.fractNoGo > 0; end
                    
        if isfield(data.params,'trCrop')
            trCrop = data.params.trCrop;
        else
            warning('Data has not been cleaned up for %s, will use full session\n',FN{f});
            trCrop = [1 size(data.response.respMTX,1)];
        end
                
        idSelF(f,1) = data.params.toneSelection == 4 && fractGo && ~trainIO && ~excl && minNTrialsPerSession < diff(trCrop)+1;
        N(f,1) = diff(trCrop)+1;
        idDate(f,1) = findDateInBehFileName(FN{f});
    end
    FN = FN(idSelF);
    N = N(idSelF);
    idDate = idDate(idSelF);
    
    %% Combine sequence of trials for all sessions %%%
    padding = 3;
    nSess = length(FN);
    nTrials = sum(N);
    trialSequence = nan(nTrials+nSess*padding,5); % Trial type; Tone intensity; Elapsed time since previous trial; Reaction time; trial type randomized order; idDate;
    k = padding;
    for f = 1:nSess
        % Load data
        load([P filesep anList{an} filesep FN{f}]);
        if isfield(data.params,'trCrop')
            trCrop = data.params.trCrop;
        else
            trCrop = [1 size(data.response.respMTX,1)];
        end
        trType = data.params.MTXTrialType(trCrop(1):trCrop(2),:);
        resp = data.response.respMTX(trCrop(1):trCrop(2),:);
        
        % Add data to trial sequence
        idxSequence = k:k+N(f)-1;
        k = k+N(f)+padding;
        GoNoGo = trType(:,2);
        Press = resp(:,3);
        H = GoNoGo == 1 & Press == 1;
        M = GoNoGo == 1 & Press == 0;
        FA = GoNoGo == 0 & Press == 1;
        CR = GoNoGo == 0 & Press == 0;
        trID = H + 2*M + 3*CR + 4*FA;
        trialSequence(idxSequence,1) = trID; % 0 = Early; 1 = Hit; 2 = Miss; 3 = Corr. rejection; 4 = False alarm;
        trialSequence(idxSequence,2) = 4-mod(trType(:,3)+3,4); %convert [1 2 3 4 5 6 7 8] to [4 3 2 1 4 3 2 1]
        trialSequence(idxSequence,3) = [0; diff(resp(:,1))]; % delta time since last trial
        trialSequence(idxSequence,4) = resp(:,4) - resp(:,2); % reaction time
        trialSequence(idxSequence,5) = trID(randperm(length(trID))); % same as trial id but with randomized order of trial sequence
        trialSequence(idxSequence,6) = trID(randperm(length(trID))); % same as trial id but with randomized order of trial sequence
        trialSequence(idxSequence,7) = trID(randperm(length(trID))); % same as trial id but with randomized order of trial sequence
        trialSequence(idxSequence,8) = trID(randperm(length(trID))); % same as trial id but with randomized order of trial sequence
        trialSequence(idxSequence,9) = trID(randperm(length(trID))); % same as trial id but with randomized order of trial sequence
        trialSequence(idxSequence,10) = idDate(f);
    end
    
    %% Sort trials by their previous trial type; Look at effect on performance vs. control
    perfoPost = zeros(6,4,4); % 1:3
    perfoCtl = zeros(6,4,4);
    for i = 1:4
        idxSel = trialSequence(:,1) == i & trialSequence(:,3) < maxDeltaT;
        trialSeqPost = trialSequence(find(idxSel)+1,:);
        % Response rate %%%%%%%%%%%%%%%%%%
        for j = 1:4
            % Post
            perfoPost(:,j,i) = perfo(trialSeqPost(trialSeqPost(:,2) == j,1),trialSeqPost(trialSeqPost(:,2) == j,4));
        end
        
        % Control shuffled 5 times
        for ii =5:9
        idxSel = trialSequence(:,ii) == i;
        trialSeqPostCtl = trialSequence(find(idxSel)+1,:);
        for j = 1:4
             perfoCtl(:,j,i) = perfoCtl(:,j,i) + perfo(trialSeqPostCtl(trialSeqPostCtl(:,2) == j,1),trialSeqPostCtl(trialSeqPostCtl(:,2) == j,4))';
        end
        end
        perfoCtl = perfoCtl/5;
        deltaPerfo = perfoPost - perfoCtl;
        
        % Store data of all animals
        for j = 1:6
            dataAllAN(kAllAN,1) = j; % TYPE; 1 = Hit rate; 2 = FA rate; 3 = d-prime 4 = performance 5=RT Hits; 6=RT FA;
            dataAllAN(kAllAN,2) = i; % Post what?; 1- Post-H; 2- Post-M; 3- Post-FA; 4- Post-CR
            dataAllAN(kAllAN,3) = an;
            dataAllAN(kAllAN,4:7) = squeeze(deltaPerfo(j,:,i));
            dataAllAN(kAllAN,8:11) = squeeze(perfoPost(j,:,i));
            dataAllAN(kAllAN,12:15) = squeeze(perfoCtl(j,:,i));
            kAllAN = kAllAN+1;
        end
    end
end

%%
figure;
k = 1;
yStr = {'Delta Hit rate','Delta FA','Delta d-prime','Delta Perfo','Delta RT'};
tStr = {'Post-H','Post-M','Post-CR','Post-FA'};
for j = [1 2 3 4 5]
for i =1:4
    delta = dataAllAN(dataAllAN(:,1) == j & dataAllAN(:,2) == i ,4:7);
%     pPost = dataAllAN(dataAllAN(:,1) == j & dataAllAN(:,2) == i ,8:11);
%     pCtl = dataAllAN(dataAllAN(:,1) == j & dataAllAN(:,2) == i ,12:15);
    [m,err] = mean_sem(delta);
    subplot(5,5,i+(k-1)*5)
    hold all
    plot(delta','k')
    errorbar(1:4,m,err,'-o')
    set(gca,'xtick',1:4,'xticklabel',{'Low','','','High'})
    xlabel('Tone intensities')
    if i == 1
        ylabel(yStr{j})
    end
    if j == 1
        title(tStr{i})
    end
    setUpPlotCompact;

    combo = nanmean(delta,2);
    [m,err] = mean_sem(combo);
    subplot(5,5,5+(k-1)*5)
    hold all
    errorbar(i,m,err,'o');
    setUpPlotCompact;
end
k = k+1;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName = fileWith(str,path)
% function fileName = fileWith(str,path)
% Select file name containing a certain string 'str' from a directory 'path'
% fileName is a cell with the name of file
% Select specific filenames in the ANID folder

% CHECK UPS
if nargin < 2
    path = pwd;
end

% CODE
fileName = getfnamelist(path);
idxSel = false(length(fileName),1);
for i = 1:length(fileName)
    if ~isempty(strfind(fileName{i},str))
        idxSel(i) = strfind(fileName{i},str);
    end
end
fileName = fileName(idxSel);
end

function d = findDateInBehFileName(fname)
%% Determine date in a fname string in the format XXX_ANID_'DD-MMM-YYYY'x.mat
idUnderScore = strfind(fname,'_');
dStr = fname(idUnderScore(2)+(1:11));
d = datenum(dStr);
end

function [p,n] = perfo(trialSeq,rt)
nH = sum(trialSeq == 1);
nGo = sum(ismember(trialSeq,[1,2]));
nFA = sum(trialSeq == 4);
nNoGo = sum(ismember(trialSeq,[3,4]));
n = length(trialSeq);
p(1) = nH/nGo; % Hit rate
p(2) = nFA/nNoGo; % FA rate
p(3) = d_prime(nH/nGo,nFA/nNoGo); % D-PRIME
p(4) = (nH + sum(trialSeq == 3))/(nGo + nNoGo);% Performance
p(5) = nanmean(rt(trialSeq == 1)); % RT on Hits
p(6) = nanmean(rt(trialSeq == 4)); % RT on FA
end





%
%
%
% %%
% ANID = {
%     'ANDBHArch01'
%     'ANDBHArch02'
%     'ANDBHArch03'
%     'ANDBHArch04'
%     %         'ANGad02'
%     'ANGad03'
%     'ANGadArch01'
%     'ANGadArch03'
%     'ANGadArch04'
%         'ANDBH10'
% %         'ANDBH11'
%         'ANDBH12'
%     };
% maxDeltaT = 10;
%
% dataAllAN = zeros(12*length(ANID),7);
% RTAllAN = zeros(8*length(ANID),7);
% kAllAN = 1;
% kRTAllAN = 1;
% for a = 1:length(ANID)
%     %% Select specific file names in the ANID folder %%%
%     str = 'ToneDisc';
%     P = [pwd filesep ANID{a} filesep];
%     if ~exist(P,'dir')
%         error('Cannot find %s in the animal list',ANID{a})
%     end
%     FN = fileWith(str,P);
%     if isempty(FN)
%         error('Cannot find files with ''%s'' in ''%s'' directory',str,ANID{a})
%     end
%
%     %% Select FN with session with tone selected == 4 and training switch is off %%%
%     N = zeros(length(FN),1);
%     idSelF = false(length(FN),1);
%     for a = 1:length(FN)
%         % Load data
%         load([P FN{a}])
%         if isfield(data.params,'training'); trainIO = data.params.training > 0;
%         else; trainIO = 0;  end
%         if isfield(data.params,'trCrop'); excl = isnan(data.params.trCrop(1));
%         else; excl = false; end
%         idSelF(a,1) = data.params.toneSelection == 4 && data.params.fractGo > 0 && trainIO < 1 && ~excl;
%         N(a,1) = size(data.response.respMTXCrop,1);
%     end
%     FN = FN(idSelF);
%     N = N(idSelF);
%
%     %% Combine sequence of trials for all sessions %%%
%     padding = 3;
%     nSess = length(FN);
%     nTrials = sum(N);
%     trialSequence = nan(nTrials+nSess*padding,4); % Trial type; Tone intensity; Elapsed time since previous trial
%     k = padding;
%     for a = 1:nSess
%         % Load data
%         load([P FN{a}]);
%         if isfield(data.params,'MTXTrialTypeCrop')
%             trType = data.params.MTXTrialTypeCrop;
%             resp = data.response.respMTXCrop;
%         else
%             error('Data has not been cleaned up for %s\n',FN{a});
%         end
%
%         % Add data to trial sequence
%         idxSequence = k:k+N(a)-1;
%         k = k+N(a)+padding;
%         GoNoGo = trType(:,2);
%         Press = resp(:,3);
%         H = GoNoGo == 1 & Press == 1;
%         M = GoNoGo == 1 & Press == 0;
%         FA = GoNoGo == 0 & Press == 1;
%         CR = GoNoGo == 0 & Press == 0;
%         trID = H + 2*M + 3*FA + 4*CR;
%         trialSequence(idxSequence,1) = trID; % 0 = Early; 1 = Hit; 2 = Miss; 3 = False alarm; 4 = Corr. rejection;
%         trialSequence(idxSequence,2) = 4-mod(trType(:,3)+3,4); %convert [1 2 3 4 5 6 7 8] to [4 3 2 1 4 3 2 1]
%         trialSequence(idxSequence,3) = [0; diff(resp(:,1))]; % delta time since last trial
%         trialSequence(idxSequence,4) = resp(:,4) - resp(:,2); % reaction time
%     end
%
%     %% Sort trials by their previous trial type; Look at effect on performance vs. control
%     perfoPost = zeros(3,4,4);
%     perfoCtl = zeros(3,4,4);
%     RTPost = zeros(2,4,4);
%     RTCtl = zeros(2,4,4);
%     for i = 1:4
%         idxSel = trialSequence(:,1) == i & trialSequence(:,3) < maxDeltaT;
%         trialSeqPost = trialSequence(find(idxSel)+1,:);
%         idxSel = ismember(trialSequence(:,1),setdiff(1:4,i)); % Find index of trial post other type of trials. Example if H are selected, trials post-M-FA-CR are used as control.
%         trialSeqCtl = trialSequence(find(idxSel)+1,:);
%
%         % Response rate %%%%%%%%%%%%%%%%%%
%         for j = 1:4
%             % Post
%             nH = sum(trialSeqPost(:,1) == 1 & trialSeqPost(:,2) == j);
%             nGo = sum(ismember(trialSeqPost(:,1),[1,2]) & trialSeqPost(:,2) == j);
%             nFA = sum(trialSeqPost(:,1) == 3 & trialSeqPost(:,2) == j);
%             nNoGo = sum(ismember(trialSeqPost(:,1),[3,4]) & trialSeqPost(:,2) == j);
%             perfoPost(1,j,i) = nH/nGo; % Hit rate
%             perfoPost(2,j,i) = nFA/nNoGo; % FA rate
%             perfoPost(3,j,i) = d_prime(nH/nGo,nFA/nNoGo); % D-PRIME
%             % CTRL
%             nH = sum(trialSeqCtl(:,1) == 1 & trialSeqCtl(:,2) == j);
%             nGo = sum(ismember(trialSeqCtl(:,1),[1,2]) & trialSeqCtl(:,2) == j);
%             nFA = sum(trialSeqCtl(:,1) == 3 & trialSeqCtl(:,2) == j);
%             nNoGo = sum(ismember(trialSeqCtl(:,1),[3,4]) & trialSeqCtl(:,2) == j);
%             perfoCtl(1,j,i) = nH/nGo; % Hit rate
%             perfoCtl(2,j,i) = nFA/nNoGo; % FA rate
%             perfoCtl(3,j,i) = d_prime(nH/nGo,nFA/nNoGo); % D-PRIME
%         end
%         deltaPerfo = perfoPost - perfoCtl;
%         % Store data of all animals
%         for j = 1:3
%             dataAllAN(kAllAN,1) = j; % TYPE; 1 = Hit rate; 2 = FA rate; 3 = d-prime
%             dataAllAN(kAllAN,2) = i; % Post what?; 1- Post-H; 2- Post-M; 3- Post-FA; 4- Post-CR
%             dataAllAN(kAllAN,3) = a;
%             dataAllAN(kAllAN,4:end) = squeeze(deltaPerfo(j,:,i));
%             kAllAN = kAllAN+1;
%
%             % Figure PERFO;
%             TITLE = {'Post-H','Post-M','Post-FA','Post-CR'};
%             c = setColor;
%             cA{1} = c.blue2; cA{3} = [0 0 0]; cA{2} = c.red; cA{4} = c.purple;
%             figure(1);
%             subplot(3,4,i+(j-1)*4)
%             hold all;
%             plot(45:10:75,squeeze(deltaPerfo(j,:,i)),'color',tint(cA{j},0.5))
%             plot([42 77],[0 0],'k','linewidth',0.5)
%             title(TITLE{i})
%             ylim([-0.5 0.5])
%             if i == 1 && j == 1; ylabel('Delta hit rate'); end
%             if i == 1 && j == 2; ylabel('Delta FA rate'); end
%             if i == 1 && j == 3; ylabel('Delta d-prime'); xlabel('Tone intensity'); end
%             if j == 3; ylim([-1.5 1.5]); end
%             setUpPlotCompact;
%         end
%
%         % Reaction time %%%%%%%%%%%%%%
%         for j = 1:4
%             % Post
%             RT_H = nanmean(trialSeqPost(trialSeqPost(:,1) == 1 & trialSeqPost(:,2) == j,4));
%             RT_FA = nanmean(trialSeqPost(trialSeqPost(:,1) == 3 & trialSeqPost(:,2) == j,4));
%             RTPost(1,j,i) = RT_H;
%             RTPost(2,j,i) = RT_FA;
%             % Ctl
%             RT_H = nanmean(trialSeqCtl(trialSeqCtl(:,1) == 1 & trialSeqCtl(:,2) == j,4));
%             RT_FA = nanmean(trialSeqCtl(trialSeqCtl(:,1) == 3 & trialSeqCtl(:,2) == j,4));
%             RTCtl(1,j,i) = RT_H;
%             RTCtl(2,j,i) = RT_FA;
%         end
%         deltaRT = RTPost - RTCtl;
%          % Store data of all animals
%         for j = 1:2
%             RTAllAN(kRTAllAN,1) = j; % TYPE; 1 = RT Hit; 2 = RT FA;
%             RTAllAN(kRTAllAN,2) = i; % Post what?; 1- Post-H; 2- Post-M; 3- Post-FA; 4- Post-CR
%             RTAllAN(kRTAllAN,3) = a;
%             RTAllAN(kRTAllAN,4:end) = squeeze(deltaRT(j,:,i));
%             kRTAllAN = kRTAllAN+1;
%
%             % Figure RT;
%             TITLE = {'Post-H','Post-M','Post-FA','Post-CR'};
%             c = setColor;
%             cA{1} = c.blue2; cA{3} = [0 0 0]; cA{2} = c.red; cA{4} = c.purple;
%             figure(2);
%             subplot(2,4,i+(j-1)*4)
%             hold all;
%             plot(45:10:75,squeeze(deltaRT(j,:,i)),'color',tint(cA{j},0.5))
%             plot([42 77],[0 0],'k','linewidth',0.5)
%             title(TITLE{i})
%             ylim([-0.2 0.2])
%             if i == 1 && j == 1; ylabel('Delta RT - Hit (s)'); end
%             if i == 1 && j == 2; ylabel('Delta RT - FA (s)'); end
%             setUpPlotCompact;
%         end
%
%     end
% end
%
% %% Plot average for each condition in figure 1
% % PERFO
% set(figure(1),'name','PERFORMANCE')
% for i = 1:3
%     for j = 1:4
%         figure(1)
%         subplot(3,4,j+(i-1)*4)
%         idSel = dataAllAN(:,1) == i & dataAllAN(:,2) == j;
%         [m,err] = mean_sem(dataAllAN(idSel,4:end),1);
%         errorbar(45:10:75,m,err,'-o','color',cA{i},'linewidth',1,'markerfacecolor',cA{i})
%     end
% end
%
% % RT
% set(figure(2),'name','REACTION TIME')
% for i = 1:2
%     for j = 1:4
%         figure(2)
%         subplot(2,4,j+(i-1)*4)
%         idSel = RTAllAN(:,1) == i & RTAllAN(:,2) == j;
%         [m,err] = mean_sem(RTAllAN(idSel,4:end),1);
%         errorbar(45:10:75,m,err,'-o','color',cA{i},'linewidth',1,'markerfacecolor',cA{i})
%     end
% end
%
% %% Average post- for each mouse
%
% % Performance %%%%%%%%%%%
% mDelta = mean_sem(dataAllAN(:,4:end),2);
% k = 1;
% figure;
% for i = 1:3
%     subplot(1,3,i)
%     idSel = dataAllAN(:,1) == i;
%     gr = dataAllAN(idSel,2);
%     hold all;
%     plot([0 4.5],[0 0],'-k')
%     dotPlot(mDelta(idSel),gr);
%     XL = xlim;
%     set(gca,'xtick',1:4,'xticklabel',{'Post-H','Post-M','Post-FA','Post-CR'},'xticklabelrotation',30)
%     if i == 1; title('Hit'); ylabel('\Delta Response'); ylim([-0.3 0.3]); end
%     if i == 2; title('False Alarm'); ylabel('\Delta Response'); ylim([-0.3 0.3]); end
%     if i == 3; title('Sensitivity'); ylabel('\Delta d-prime'); ylim([-1.5 1.5]); end
%     setUpPlotCompact
%
%     for j = 1:4
%         [~,PVAL(k,1)] = ttest(mDelta(idSel & dataAllAN(:,2) == j));
%         PVAL(k,2) = signrank(mDelta(idSel & dataAllAN(:,2) == j));
%         k = k+1;
%     end
% end
%
% % Reaction time %%%%%%%%%%%
% mDelta = mean_sem(RTAllAN(:,4:end),2);
% k = 1;
% figure;
% for i = 1:2
%     subplot(1,2,i)
%     idSel = RTAllAN(:,1) == i;
%     gr = RTAllAN(idSel,2);
%     hold all;
%     plot([0 4.5],[0 0],'-k')
%     dotPlot(mDelta(idSel),gr);
%     XL = xlim;
%     set(gca,'xtick',1:4,'xticklabel',{'Post-H','Post-M','Post-FA','Post-CR'},'xticklabelrotation',30)
%     if i == 1; title('Hit'); ylabel('\Delta Reaction time'); ylim([-0.2 0.2]); end
%     if i == 2; title('False Alarm'); ylabel('\Delta Reaction time'); ylim([-0.2 0.2]); end
%     setUpPlotCompact
%
%     for j = 1:4
%         [~,PVALRT(k,1)] = ttest(mDelta(idSel & RTAllAN(:,2) == j));
%         PVALRT(k,2) = signrank(mDelta(idSel & RTAllAN(:,2) == j));
%         k = k+1;
%     end
% end