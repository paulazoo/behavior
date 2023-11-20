function water_manualCTL
% Open water valve
% Keyboard: o or O = Open valve
% Keyboard: c or C = Close valve
% Keyboard: ESC = escape

% Simple script to control the opening of the reward valve with the keyboard.

% SETUP ==================================
[ardIn,ardOut] = lever_cardSetUpInOut_GF;
setUpDirHFB_GF

% Initialize variables ===================

% Keyboard --
if strcmp(computer,'MACI64');
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
    openKeyLeft = KbName('l');
    openKeyRight = KbName('r');
    closeKey = KbName('c');
end
ESC = false;

% Test keyboard (speed issue if done during the loop)

clc;
fprintf('Water valve manual control:\nPress L to open left\nPress R to open right\nPress c to close\nPress ESC to quit\n');
while ~ESC
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) > 0;
    if keyCode(openKeyLeft) > 0
        fprintf(ardOut,'E');
    elseif keyCode(openKeyRight) > 0
        fprintf(ardOut,'W');
    elseif keyCode(closeKey) > 0
        fprintf(ardOut,'O');
    end
end
fprintf('Goodbye\n');
lever_cleanArduino(ardIn);
lever_cleanArduino(ardOut);

