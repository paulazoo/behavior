function [ARDUINO,ESC] = recordContinuous(ARDUINO,recordingDuration,escapeKey)
    % RECORD ARDUINO LEVER AND LICK DATA CONTINUOUSLY FOR A SET DURATION OF TIME
    % ARDUINO is a structure with fields
    %   in = serial port for input arduino
    %   out = serial port for output arduino
    %   idx = current idx number. Increased everytime arduino in is sampled
    %   t0 = reference start time to evaluate data from
    %   data = data read from arduino:
    %        d(1) = absolute time
    %        d(2) = lever value
    %        d(3) = lickspout1 value
    %        d(4) = lickspout2 value
    %        d(5) = accelerator X value
    %        d(6) = accelerator Y value
    %        d(7) = accelerator Z value
    
    ESC = true;
    
    recordingStart_time = tic;
    current_time = toc(recordingStart_time);
    while leverPress == false && ESC && current_time < recordingDuration
        % update time
        current_time = toc(recordingStart_time);

        % update arduinoIN data
        ARDUINO.data(ARDUINO.idx,:) = readArduino(ARDUINO.in, ARDUINO.t0);

        % for escaping
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;

        % increment Arduino.idx
        ARDUINO.idx = ARDUINO.idx+1;
    end
    
    