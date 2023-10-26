clear; close all;
clc;

% Response after any type of trial done on all animals
% Version 3 :
%   - Need to modify crop criteria
%   - Shuffling does that work?
%   - compare begining of a session versus end

anList = {
%     'ANDbhChR201'
%     'ANDbhChR202'
%     'ANDbhChR203'
%     'ANDbhChR205'
    'ANDbhArch01'
    'ANDbhArch02'
    'ANDbhArch03'
    'ANDbhArch04'
    'ANDbhArch06'
%     'ANGRIN02'
%     'ANGRIN03'
%     'ANGRIN05'
%     'ANDBH11'
%     'ANDbh14'
%     'ANDbh21'
%     'ANDbh22'
%     'ANGRABNE01'
%     'ANGRABNE03'
%     'ANGRABNE05'
%     'ANGRABNE06'
%     'ANGRABNE07'
    };
P = [HFRootFolder_GF 'Data' filesep 'ToneDiscrimination' filesep];

showfig = false;
maxDeltaT = 10;
minNTrialsPerSession = 10;
nShuffle = 100;
maxFAR = 0.3;
minHR = 0.6;
nMovAVG = 40;
minNTrials = 1000;

kAllAN = 1;
dataAllAN = nan(length(anList)*5*4,7+4+4);
% rng(2);
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
        %
        %         if isfield(data.params,'trCrop')
        %             trCrop = data.params.trCrop;
        %         else
        %             warning('Data has not been cleaned up for %s, will use full session\n',FN{f});
        trCrop = [1 size(data.response.respMTX,1)];
        %         end
        
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
    trialSequence = nan(nTrials+nSess*padding,4); % Trial type; Tone intensity; Elapsed time since previous trial; Reaction time; trial type randomized order; idDate;
    trialSequenceShuffled = nan(nTrials+nSess*padding,4,nShuffle);
    k = padding;
    for f = 1:nSess
        % Load data
        load([P filesep anList{an} filesep FN{f}]);
        %         if isfield(data.params,'trCrop')
        %             trCrop = data.params.trCrop;
        %         else
        trCrop = [1 size(data.response.respMTX,1)];
        %         end
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
        for i = 1:nShuffle
            idxRnd = randperm(length(trID));
            trialSequenceShuffled(idxSequence,1,i) = trID(idxRnd); % same as trial id but with randomized order of trial sequence
            trialSequenceShuffled(idxSequence,2,i) = 4-mod(trType(idxRnd,3)+3,4);
            trialSequenceShuffled(idxSequence,3,i) = [0; diff(resp(idxRnd,1))]; % This one makes no sense but keep to have same number of columns
            trialSequenceShuffled(idxSequence,4,i) = resp(idxRnd,4) - resp(idxRnd,2);
        end
        %         trialSequence(idxSequence,10) = idDate(f);
    end
    
    %% Criteria to remove seq
    trialSequence = cleanUpSequence(trialSequence,maxFAR,minHR,nMovAVG);
    nTrialPostCleanUp = sum(~isnan(trialSequence(:,1)));
    
    if showfig
        plotAllSessions(trialSequence,nMovAVG);
        set(gcf,'name',anList{an});
        setFigure('large')
        setUpPlot
    end
    %% Sort trials by their previous trial type; Look at effect on performance vs. control
    if nTrialPostCleanUp > minNTrials
        perfoPost = zeros(6,4,4); % 1:3
        perfoCtl = zeros(6,4,4);
        for i = 1:4
            idxSel = trialSequence(:,1) == i & trialSequence(:,3) < maxDeltaT;
            trialSeqPost = trialSequence(find(idxSel)+1,:);
            % Response rate %%%%%%%%%%%%%%%%%%
%             for j = 1:4
                for j = 1
                % Post
                perfoPost(:,j,i) = perfo(trialSeqPost(:,1),trialSeqPost(:,4));
%                 perfoPost(:,j,i) = perfo(trialSeqPost(trialSeqPost(:,2) == j,1),trialSeqPost(trialSeqPost(:,2) == j,4));
            end
            
            %         % Control shuffled n times
            %         for ii =1:nShuffle
            %         idxSel = trialSequenceShuffled(:,1,ii) == i;
            %         trialSeqPostCtl = trialSequenceShuffled(find(idxSel)+1,:,ii);
            %         for j = 1:4
            %              perfoCtl(:,j,i) = perfoCtl(:,j,i) + perfo(trialSeqPostCtl(trialSeqPostCtl(:,2) == j,1),trialSeqPostCtl(trialSeqPostCtl(:,2) == j,4))';
            %         end
            %         end
            %         perfoCtl = perfoCtl/nShuffle;
            
            % Control all other trials
            idxSel = trialSequence(:,1) ~= i & trialSequence(:,3) < maxDeltaT;
            trialSeqPost = trialSequence(find(idxSel)+1,:);
            % Response rate %%%%%%%%%%%%%%%%%%
%             for j = 1:4
                            for j = 1
                % Post
%                 perfoCtl(:,j,i) = perfo(trialSeqPost(trialSeqPost(:,2) == j,1),trialSeqPost(trialSeqPost(:,2) == j,4));
                perfoCtl(:,j,i) = perfo(trialSeqPost(:,1),trialSeqPost(:,4));
            end
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
end

%%
figure;
k = 1;
yStr = {'Delta Hit rate','Delta FA','Delta d-prime','Delta Perfo','Delta RT'};
tStr = {'Post-H','Post-M','Post-CR','Post-FA'};
for j = [1 2 3 4 5]
    for i =1:4
        delta = dataAllAN(dataAllAN(:,1) == j & dataAllAN(:,2) == i ,4:7);
        [m,err] = mean_sem(delta);
        subplot(5,5,i+(k-1)*5)
        hold all
        plot(delta','k')
        errorbar(1:4,m,err,'-o')
        plot(xlim,[0 0],'k')
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
        plot(xlim,[0 0],'k')
        setUpPlotCompact;
    end
    k = k+1;
end

% %%
% figure;
% k = 1;
% yStr = {'Hit rate','FA','d-prime','Perfo','RT'};
% tStr = {'Post-H','Post-M','Post-CR','Post-FA'};
% for j = [1 2 3 4 5]
%     % for i =1:4
%     pPost = dataAllAN(dataAllAN(:,1) == j & dataAllAN(:,3) == 1,8:11);
%     pCtl = dataAllAN(dataAllAN(:,1) == j & dataAllAN(:,3) == 1 ,12:15);
%     [m,err] = mean_sem(pPost);
%     subplot(5,2,2*j-1)
%     hold all
%     plot(pPost','r')
%     errorbar(1:4,m,err,'-or')
%     plot(xlim,[0 0],'k')
%     set(gca,'xtick',1:4,'xticklabel',{'Low','','','High'})
%     xlabel('Tone intensities')
%     if i == 1
%         ylabel(yStr{j})
%     end
%     setUpPlotCompact;
%     
%     [m,err] = mean_sem(pCtl);
%     subplot(5,2,2*j)
%     hold all
%     plot(pCtl','k')
%     errorbar(1:4,m,err,'-ok')
%     plot(xlim,[0 0],'k')
%     set(gca,'xtick',1:4,'xticklabel',{'Low','','','High'})
%     xlabel('Tone intensities')
%     if i == 1
%         ylabel(yStr{j})
%     end
%     setUpPlotCompact;
%     
%     %     combo = nanmean(delta,2);
%     %     [m,err] = mean_sem(combo);
%     %     subplot(5,5,5+(k-1)*5)
%     %     hold all
%     %     errorbar(i,m,err,'o');
%     %     plot(xlim,[0 0],'k')
%     %     setUpPlotCompact;
%     % end
%     k = k+1;
% end

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

function plotAllSessions(trSeq,nMov)
% Playing around to select certain part of each session (example high FA
% low H etc; beginning versus end)
c = setColor;
trID = trSeq(:,1);
toneID = trSeq(:,2);

% Calculate instant HR and FAR; For each session; Have to split each
% session otherwise movsum would overlap begining with ends of other sess.
idSess = [find([false; diff(isnan(trID)) == -1]); length(trID)+3]; % Determine session Start; adds an extra entry at the end for balancing
hr = nan(size(trID));
far = nan(size(trID));
er = nan(size(trID));
for i = 1:length(idSess)-1
    idx = idSess(i):idSess(i+1)-4;
    selTrID = trID(idx);
    h = movsum(selTrID == 1 ,nMov);
    go = movsum((selTrID == 1 | selTrID == 2) ,nMov);
    fa = movsum(selTrID == 4 ,nMov);
    nogo = movsum((selTrID == 3 | selTrID == 4) ,nMov);
    hr(idx) = h./go;
    far(idx) = fa./nogo;
    er(idx) = movmean(selTrID == 0, nMov);
    % Begining vs end
end

figure
hold all
plot(hr,'color',c.blue2)
plot(far,'color',c.red)
plot(er,'color',c.orange)

% This part is to draw a line at begining of each sess
ylim([-0.1 1.1])
yl = ylim;
X  = [idSess(1:end-1) idSess(1:end-1) nan(size(idSess(1:end-1)))]';
X = X(:);
Y = [yl(1) yl(2) nan].*ones(size(idSess(1:end-1)));
Y = Y';
Y = Y(:);
plot(X,Y,'k','linewidth',1)
xlim([0 length(hr)])
ylabel('Response (%)')
xlabel('Trial #')
end


function trSeqCleaned = cleanUpSequence(trSeq,maxFAR,minHR,nMov)
% Playing around to select certain part of each session (example high FA
% low H etc; beginning versus end)
trID = trSeq(:,1);
toneID = trSeq(:,2);

% Calculate instant HR and FAR; For each session; Have to split each
% session otherwise movsum would overlap begining with ends of other sess.
idSess = [find([false; diff(isnan(trID)) == -1]); length(trID)+3]; % Determine session Start; adds an extra entry at the end for balancing
hr = nan(size(trID));
far = nan(size(trID));
er = nan(size(trID));
for i = 1:length(idSess)-1
    idx = idSess(i):idSess(i+1)-4;
    selTrID = trID(idx);
    h = movsum(selTrID == 1 ,nMov);
    go = movsum((selTrID == 1 | selTrID == 2) ,nMov);
    fa = movsum(selTrID == 4 ,nMov);
    nogo = movsum((selTrID == 3 | selTrID == 4) ,nMov);
    hr(idx) = h./go;
    far(idx) = fa./nogo;
    er(idx) = movmean(selTrID == 0, nMov);
    % Begining vs end
end

idSel = isnan(far) | (far < maxFAR & hr > minHR);
trSeqCleaned = nan(size(trSeq));
trSeqCleaned(idSel,:) = trSeq(idSel,:);
end