function checkWaterCalibration(rewAmount)
% TEST IF TWO CALIBRATIONS GIVE ~ SAME AMOUNT OF REWARDS 
if nargin < 1
    rewAmount = input('Enter reward amount to be tested\n');
end

root_dir = 'C:\Users\paulazhu\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior\';
cd(root_dir);
addpath([pwd filesep 'helpers' filesep 'waterCalibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card']);

% PARAMS ==============================
n = 100;

% SETUP ==================================
escapeKey = KbName('esc');
[~,~,keyCode] = KbCheck;
ESC = false;

[ardIn,ardOut] = setupArduino();
durValve = waterReward2duration(rewAmount,2,root_dir);

fprintf('Testing reward:%1.3f uL\n',rewAmount)
input('Fill both reservoirs and press ENTER\n');

% RUN TEST ==================================================
for i = 1:n % Open valve n times
    t0 = tic;
    deltaT = 0;
    fprintf(ardOut,'W');
    if ESC; fprintf(ardOut,'X'); break; end

    while deltaT < durValve && ~ESC
        deltaT = toc(t0);;
        
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) > 0;

        if ESC; fprintf(ardOut,'X'); break; end
    end

    fprintf(ardOut,'X');
    pause(0.2);
end

fprintf('Total volume delivered = %2.2f mL\n',rewAmount*n*10^-3);

% CLEAN UP =======================================
cleanArduino(ardIn,'IN');
cleanArduino(ardOut,'OUT');

