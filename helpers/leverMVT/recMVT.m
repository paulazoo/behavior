function ARDUINO = recMVT(ARDUINO,dur)
tStart = tic;
deltaT = 0;
while deltaT < dur
    ARDUINO.data(ARDUINO.idx,:) = lever_readArduino(ARDUINO.in,ARDUINO.t0);
    deltaT = toc(tStart);
    ARDUINO.idx = ARDUINO.idx+1;
end
