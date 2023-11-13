function water_testCalibrationRL(rewAmount)

% TEST IF TWO CALIBRATIONS GIVE ~ SAME AMOUNT OF REWARDS
clc;
if nargin < 1
    rewAmount = input('Enter reward amount to be tested\n');
end

% PARAMS ==============================
n = 100;

% SETUP ==================================
[ardIn,ardOut] = lever_cardSetUpInOutV2;
durValve(1) = water_reward2duration(rewAmount,1); % RIGHT
durValve(2) = water_reward2duration(rewAmount,2); % LEFT

fprintf('Testing reward:%1.3f uL\n',rewAmount)
input('Fill both reservoirs and press ENTER\n');

% Keyboard --
if strcmp(computer,'MACI64')
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
end
% Test keyboard (speed issue if done during the loop)
[~,~,keyCode] = KbCheck;
ESC = false;

% RUN TEST ==================================================
% Open each valve n times
for i = 1:n
    for v =1:2
        t0 = GetSecs;
        deltaT = 0;
        if v == 1
            fprintf(ardOut,'W');
        elseif v == 2
            fprintf(ardOut,'E');
        end
        while deltaT < durValve(v) && ~ESC
            deltaT = GetSecs - t0;
            
            [~,~,keyCode] = KbCheck;
            ESC = keyCode(escapeKey) > 0;
            if ESC; fprintf(ardOut,'O'); break; end
        end
        fprintf(ardOut,'O');
        pause(0.2);
        if ESC; fprintf(ardOut,'O'); break; end
    end
end

fprintf('Total volume delivered = %2.2f mL\n',rewAmount*n*10^-3);

% CLEAN UP =======================================
lever_cleanArduino(ardIn,'IN');
lever_cleanArduino(ardOut,'OUT');

