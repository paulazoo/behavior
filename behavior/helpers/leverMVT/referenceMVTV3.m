function MVTBL = referenceMVTV3(ARDUINO,nRef)
% function MVTBL = referenceMVT(ARDUINO,nRef)
% ARDUINO is a structure with fields
%   in = serial port for input arduino
%   out = serial port for output arduino
%   idx = current idx number. Increased everytime arduino in is sampled
%   t0 = reference start time to evaluate data from
%   data = data read from arduino

BLFlag = true;
ii = 1;
while BLFlag
    MVTBL = nan(nRef,1);
%     flushinput(ARDUINO.in);
    for i = 1:nRef
        d = lever_readArduinoV3(ARDUINO.in);
        MVTBL(i) = d(end,2); % Take the last line of the data in the buffer. Much simpler for now.
    end
    
    if max(std(MVTBL))<0.05
        %             MVT0 = nanmedian(MVTBL);
        BLFlag = false;
        fprintf('Measured BL:  %1.3f\n',nanmedian(MVTBL))
    else
        ii = ii + 1;
        fprintf('Try again #%d\n',ii)
    end
end