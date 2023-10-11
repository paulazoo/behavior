function spout_testMVT(n)

% TEST IF TWO CALIBRATIONS GIVE ~ SAME AMOUNT OF REWARDS
clc;
if nargin < 1
    n = 5;
end

durMVT = 0.3;

% SETUP ==================================
% setUpDirHFB

[~,ardOut] = lever_cardSetUpInOut_GF;

% Keyboard --
if strcmp(computer,'MACI64')
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
end
% Test keyboard (speed issue if done during the loop)
KbCheck;
ESC = false;

% RUN TEST ==================================================
% Open each valve n times
for i = 1:n

        t0 = GetSecs;
        deltaT = 0;
            fprintf(ardOut,'R');
        while deltaT < durMVT && ~ESC
            deltaT = GetSecs - t0;
            [~,~,keyCode] = KbCheck;
            ESC = keyCode(escapeKey) > 0;
            if ESC; break; end
        end
        fprintf(ardOut,'S');
        WaitSecs(0.5);
        t0 = GetSecs;
        deltaT = 0;
        fprintf(ardOut,'L');
        while deltaT < durMVT && ~ESC
            deltaT = GetSecs - t0;
            [~,~,keyCode] = KbCheck;
            ESC = keyCode(escapeKey) > 0;
            if ESC; break; end
        end
        fprintf(ardOut,'M');
        WaitSecs(0.5);

        if ESC; break; end
end


% CLEAN UP =======================================
lever_cleanArduino(ardOut,'OUT');

