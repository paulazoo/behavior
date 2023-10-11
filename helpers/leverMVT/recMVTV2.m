function ARDUINO = recMVTV2(ARDUINO,dur)
tStart = tic;
while toc(tStart) < dur
    ARDUINO.data(ARDUINO.idx,:) = lever_readArduinoV2(ARDUINO.in,ARDUINO.t0);
    ARDUINO.idx = ARDUINO.idx+1;
end
