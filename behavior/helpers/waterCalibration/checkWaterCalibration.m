function checkWaterCalibration(rewAmount)
% TEST IF TWO CALIBRATIONS GIVE ~ SAME AMOUNT OF REWARDS 
if nargin < 1
    rewAmount = input('Enter reward amount to be tested\n');
end

%%
root_dir = 'D:\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior';
cd(root_dir);
addpath([pwd filesep 'helpers' filesep 'waterCalibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card'])

%% PARAMS ==============================
nTrials = 1;

%% SETUP ==================================
[ardIn,ardOut] = setupArduino();
durValve = waterReward2duration(rewAmount,2,root_dir);

fprintf('Testing reward:%1.3f uL\n',rewAmount)
input('Fill water and press ENTER\n');

%% RUN TEST ==================================================
for i = 1:1:nTrials
    t0 = tic;
    deltaT = toc(t0);
    fprintf(ardOut,'W'); % WATER REWARD
    while deltaT < durValve
        deltaT = toc(t0);
    end
    fprintf(ardOut,'X');
    pause(0.1);
end

fprintf('Total volume delivered = %2.2f uL\n',rewAmount*nTrials);

%% CLEAN UP =======================================
cleanArduino(ardIn,'IN');
cleanArduino(ardOut,'OUT');

