function laserManualCTL
% Open water valve
% Keyboard: o or O = Open valve
% Keyboard: c or C = Close valve
% Keyboard: ESC = escape

% Simple script to control the opening of the reward valve with the keyboard.

% SETUP ==================================
[ardIn,ardOut] = lever_cardSetUpInOut_GF;


% Initialize variables ===================

% Keyboard --
if strcmp(computer,'MACI64');
    escapeKey = KbName('ESCAPE');
else
    escapeKey = KbName('esc');
    turnOnKey = KbName('l');
%     turnOffKey = KbName('c');ll
end
ESC = false;

% Test keyboard (speed issue if done during the loop)

clc;
fprintf('Laser manual control:\nPress L to turn on\nPress ESC to quit\n');
while ~ESC
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) > 0;
    if keyCode(turnOnKey) > 0
        fprintf(ardOut,'A');
%     elseif keyCode(turnOffKey) > 0
%         fprintf(ardOut,'B');
    end
end
fprintf('Goodbye\n');
lever_cleanArduino(ardIn);
lever_cleanArduino(ardOut);

