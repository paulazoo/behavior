function [ARDUINO,ESC] = recMVTV3(ARDUINO,dur,escapeKey)
tStart = tic;
ESC = true;
while toc(tStart) < dur && ESC
    d = lever_readArduinoV3(ARDUINO.in,ARDUINO.t0);
    nLines = size(d,1);
    ARDUINO.data((1:nLines)-1+ARDUINO.idx,:) = d;
    ARDUINO.idx = ARDUINO.idx+nLines;
    
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
end
