function dataCalibration = calculateWaterCalibration()
% Calibrate the opening of the valve duration and measure reward values
% and save it as dataCalibration_valve<valveID>.mat

root_dir = 'C:\Users\paulazhu\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior\';
cd([root_dir '\helpers\waterCalibration\']);
addpath([pwd filesep 'helpers' filesep 'waterCalibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card']);

% Params =================================
valveID = 2;
nTrials = 100; % For each opening duration
dur2test = [0.01:0.01:0.09] % in seconds
nRepeat = 1; % Number of time each duration is tested.

% SETUP ==================================
[ardIn,ardOut] = lever_cardSetUpInOutV2;

[~,systName] = system('hostname');
systName = systName(1:end-1);

escapeKey = KbName('esc');
[~,~,keyCode] = KbCheck;
ESC = false;

% Load previous calibration
if exist([systName '\dataCalibration_valve' num2str(valveID) '.mat'],'file') > 0
    load([systName '\dataCalibration_valve' num2str(valveID) '.mat'])
    prevRew = dataCalibration.rewardDelivered;
    prevDur = dataCalibration.valveDurTested;
else
    fprintf('WARNING: No previous calibration file found.\n');
    prevRew = nan;
    prevDur = nan;
end

% TESTING ==================================
FLAG = 0;
readValue = nan(nRepeat,length(dur2test));

while FLAG < 1 && ~ESC
    for d = 1:length(dur2test)
        for r = 1:nRepeat
            fprintf('Testing duration:%1.3f sec (%d/%d)\n',dur2test(d),r,nRepeat)
            input('Fill water and press ENTER\n');
            for i = 1:nTrials
                t0 = tic;
                deltaT = tic - toc(t0);
                fprintf(ardOut,'W');
                while deltaT < dur2test(d) && ~ESC
                    deltaT = GetSecs - t0;
                    
                    [~,~,keyCode] = KbCheck;
                    ESC = keyCode(escapeKey) > 0;
                    
                    if ESC; fprintf(ardOut,'X'); break; end
                end
                fprintf(ardOut,'X');
                pause(0.25);
                if ESC; fprintf(ardOut,'X'); break; end
            end
            if ESC; fprintf(ardOut,'X'); break; end
            readValue(r,d) = input('Enter amount of water in mL:\n\n');
        end
        if ESC; fprintf(ardOut,'X'); break; end
    end
    
    rewardDelivered = readValue/nTrials*1000;   
    fprintf(ardOut,'X');
    
    if ~ESC
        % Fit data linear curve
        x = repmat(dur2test(1:end),nRepeat,1);
        x = x(:)';
        y = rewardDelivered(1:end,:);
        y = y(:)';
        
        p = polyfit(x,y,1);
        yfit =  p(1) * x + p(2);
        yresid = y - yfit;
        SSresid = sum(yresid.^2);
        SStotal = (length(y)-1) * var(y);
        r2 = 1 - SSresid/SStotal;
        
        close all;
        figure;
        hold all;
%         yfit = polyval(p,0.01:0.001:0.09);
        plot(prevDur,prevRew,'-xb');
%         plot(10:100,yfit,'-r','linewidth',1)
        plot(dur2test,rewardDelivered,'-ok')
%         legend('Previous calibration','Fit','Current values');
        legend('Previous calibration','New calibration');
        xlabel('Duration (s)');
        ylabel('Reward amount (uL)');
        setUpPlot
        ylim([0 max(rewardDelivered(:))+1]);
        text(0.060,5,['r^2 = ' num2str(r2)])
        
        FLAG = input('Accept calibration Y[1] N[0]\n');
        
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) > 0;
    end
end

lever_cleanArduino(ardIn,'IN');
lever_cleanArduino(ardOut,'OUT');

if ESC
    fprintf('WARNING: ESCAPE KEY PRESSED. NO CALIBRATION DATA WAS SAVED\n')
else
    % Save data ========================================
    dataCalibration.valveID = valveID;
    dataCalibration.valveDurTested = dur2test;
    dataCalibration.rewardDelivered = rewardDelivered;
    dataCalibration.fitVal = p;
    dataCalibration.equation = 'p(1) * dur + p(2)';
    dataCalibration.date = date;
    
    if exist(systName,'dir') == 0
        mkdir(systName);
    end
    save([systName '\dataCalibration_valve' num2str(valveID)],'dataCalibration');
end