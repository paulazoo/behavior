function [ARDUINO,isMVT,ESC] = detectMVT(ARDUINO,params,escapeKey)
% function [ARDUINO,ESC] = detectMVT(ARDUINO,params,ESC)
% 
% DETECT LEVER MOVEMENT ABOVE THRHESHOLD DEFINED IN PARAMS
% ARDUINO is a structure with fields
%   in = serial port for input arduino
%   out = serial port for output arduino
%   idx = current idx number. Increased everytime arduino in is sampled
%   t0 = reference start time to evaluate data from
%   data = data read from arduino
%
% params = [duration MVT0 threshold(V)];

dur = params(1);
MVT0 = params(2);
thresh = params(3);
deltaT = 0;
deltaMVT = 0;
ESC = true;

% Check if movement for a fixed duration
tStart = GetSecs;
flushinput(ARDUINO.in);
while deltaT < dur && deltaMVT < thresh && ESC
    ARDUINO.data(ARDUINO.idx,:) = lever_readArduino(ARDUINO.in,ARDUINO.t0);
    ARDUINO.idx = ARDUINO.idx+1;
    deltaT = GetSecs - tStart;
    deltaMVT = abs(ARDUINO.data(ARDUINO.idx-1,2)-MVT0);
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
end

% MVT detected?
isMVT = true;
if deltaMVT < thresh
    isMVT = false;
end
