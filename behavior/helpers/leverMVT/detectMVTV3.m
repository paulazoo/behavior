function [ARDUINO,isMVT,ESC] = detectMVTV3(ARDUINO,params,escapeKey)
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
deltaMVT = 0;
ESC = true;

% Check if movement for a fixed duration
tStart = tic;
% flushinput(ARDUINO.in);
while toc(tStart) < dur && any(deltaMVT < thresh) && ESC
    d = lever_readArduinoV3(ARDUINO.in,ARDUINO.t0);
    nLines = size(d,1);
    ARDUINO.data((1:nLines)-1+ARDUINO.idx,:) = d;
    ARDUINO.idx = ARDUINO.idx+nLines;
    
    lev = d(:,2);
    deltaMVT = abs(lev-MVT0);
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
end

% MVT detected?
isMVT = true;
if any(deltaMVT < thresh)
    isMVT = false;
end
