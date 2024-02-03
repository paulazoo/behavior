function dataCalibration = calculateWaterCalibration()
% Calibrate the opening of the valve duration and measure reward values
% and save it as dataCalibration_valve<valveID>.mat

%%
root_dir = 'D:\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior';
cd([root_dir '\helpers\waterCalibration\']);
addpath([pwd filesep 'helpers' filesep 'waterCalibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card']);
[~,systName] = system('hostname');
systName = systName(1:end-1);

%% Params =================================
valveID = 2;
nTrials = 100; % For each opening duration
dur2test = [0.01:0.01:0.09] % in seconds
nRepeat = 1; % Number of time each duration is tested.

%% SETUP ==================================
[ardIn,ardOut] = setupArduino();


%% TESTING ==================================
FLAG = 0;
readValue = nan(nRepeat,length(dur2test));

while FLAG < 1
    for d = 1:length(dur2test)
        for r = 1:nRepeat
            fprintf('Testing duration:%1.3f sec (%d/%d)\n',dur2test(d),r,nRepeat)
            input('Fill water and press ENTER\n');

            for i = 1:1:nTrials
                t0 = tic;
                deltaT = toc(t0);
                fprintf(ardOut,'W'); % WATER REWARD
                while deltaT < dur2test(d)
                    deltaT = toc(t0);
                end
                fprintf(ardOut,'X');
                pause(0.1);
            end
            
            readValue(r,d) = input('Enter amount of water in mL:\n');
        end
    end
    
    rewardDelivered = readValue/nTrials*1000;   
    fprintf(ardOut,'X');
    
    %% Fit data linear curve
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
    plot(dur2test,rewardDelivered,'-ok')
    legend('New calibration');
    xlabel('Duration (s)');
    ylabel('Reward amount (uL)');
    setUpPlot
    ylim([0 max(rewardDelivered(:))+1]);
    text(0.060,5,['r^2 = ' num2str(r2)])
    
    FLAG = input('Accept calibration Y[1] N[0]\n');
end

%% Clean up
cleanArduino(ardIn,'IN');
cleanArduino(ardOut,'OUT');

%% Save data ========================================
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