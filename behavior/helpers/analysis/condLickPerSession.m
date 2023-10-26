function tbl = condLickPerSession(ANID,showfig)

fileNameWith = 'Cond';
win = [-2.5 2.5];
if nargin < 2
    showfig = true;
end
% Select specific filenames ===============================
cd(HFRootFolder_GF);
cd('Data');
cd('Conditioning');
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

% Find date of each file
nSess = length(FN);
for f = 1:nSess
    idx = findstr(FN{f},'_');
    idx = idx(2)+1;
    d = FN{f}(idx:idx+10);
    dateID(f,1) = datenum(d);
end
dateList = unique(dateID);

%% Extract data for each date ============================
BLLick = nan(length(dateList),1);
errBLLick = nan(length(dateList),1);
antLick = nan(length(dateList),3); %1-REW 2-NEUTRAL 3-PUNISH
errAntLick = nan(length(dateList),3); %SEM on antLick 1-REW 2-NEUTRAL 3-PUNISH
strD = cell(length(dateList),1);
for d = 1:length(dateList)
    strD{d} = datestr(dateList(d));
    id = find(dateID == dateList(d));
    AllR = [];
    toneID = [];
    % Merge raster for the data taken from the same day. In case you
    % have one session broken into multiple files)
    for i = 1:length(id)
        %%%%% Load data %%%%%
        load([P FN{id(i)}])
        
        % Load behavior data
        dataArduino = data.response.dataArduino;
        respMTX = data.response.respMTX;
        N = size(respMTX,1);
        MTXTrialType =data.params.MTXTrialType(1:N,:);
        toneID = [toneID; MTXTrialType(:,2)];
        
        %%%%% Make raster of licks %%%%%
        % Raster params
        arduinoDelay = 0.1;
        
        
        % Resample arduino data at a fixed rate
        arduinoRate = 125;
        ardRS = resample(dataArduino(:,2:end),dataArduino(:,1),arduinoRate);
        ardRS(:,2) = ardRS(:,2) > 0.5; % Put back the resampled data to logical
        ardRS(:,3) = ardRS(:,3) > 0.5; % Put back the resampled data to logical
        t = ((0:size(ardRS,1)-1)/arduinoRate)+dataArduino(1,1);
        
        % Load lick data and tone timing
        L = abs([0; diff(ardRS(:,2)) > 0]);
        tUS = respMTX(:,3)+arduinoDelay;
        tUS = tUS(~isnan(tUS));
        
        % Find index of tone in dataArduino
        idxUS = nan(length(tUS),1);
        for j = 1:length(tUS)
            idxUS(j) = find(t > tUS(j),1);
        end
        
        % Make raster of lick data aligned to tone
        R = makeRaster(L,idxUS,round(win*arduinoRate));
        R = R > 0;
        tR = linspace(win(1),win(2),size(R,2));
        if size(R,2) == 1
            R = R';
        end
        AllR = logical(cat(1,AllR,R));
    end
    
    %%%%% Calculate various lick rates for each session %%%%%
    % Calculate BL lick
    winBL = [-2 -1.5];
    idBL = tR > winBL(1) & tR < winBL(2);
    [BLLick(d),errBLLick(d)] = mean_sem(sum(AllR(:,idBL),2)/diff(winBL),1);
    
    % Calculate ANT lick
    winAnt = [-1.5 0];
    idAnt = tR > winAnt(1) & tR < winAnt(2);
    for i = 1:3
        [antLick(d,i),errAntLick(d,i)] = mean_sem(sum(AllR(toneID == i,idAnt),2)/diff(winAnt),1);
    end
    
    %%%%% Plot for each type of trial raster and lick rate %%%%%
    if showfig
        c = setColor;
        tStr = {'Reward','Neutral','Punish'};
        fig2 = figure;
        setFigure('narrowtall')
        set(gcf,'name',datestr(dateList(d)))
        h2 = [];
        for i = 1:3
            if i == 1
                col = c.blue2;
            elseif i == 2
                col = c.gray;
            elseif i == 3
                col = c.red;
            end
            
            figure(fig2)
            subplot(4,1,i)                      
            plotSpikeRaster(AllR(toneID == i,:),'TimePerBin',arduinoRate,'rasterWindowOffset',win(1)*arduinoRate);
            title(tStr{i})
            ylabel('Trial #')
            setUpPlotCompact;
            
            subplot(4,1,4)
            [~, m, err] = estimateSpikeRateRaster(AllR(toneID == i,:),log10(1/arduinoRate),10/arduinoRate);
            hold all
            if ~isnan(m)
                h2(i) = boundedline(tR,m,err,'cmap',col);
            end
            xlim(win)
            ylim([0 15])
            xlabel('Time - US aligned (s)')
            ylabel('Lick rate (Hz)')
            setUpPlotCompact
        end
        plot(-1.5*[1 1],ylim,'color',c.green)
        legend(h2,tStr,'location','best');
    end
end


%%%%% Calculate delta lick (BL subtracted) %%%%%
dLick = antLick - BLLick;

tbl = table(strD,dLick,antLick,errAntLick,BLLick,errBLLick);
