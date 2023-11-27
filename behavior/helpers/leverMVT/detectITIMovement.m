function [ARDUINO,ITIMovement,ESC] = detectITIMovement(ARDUINO,params,escapeKey)
    % DETECT LEVER MOVEMENT ABOVE THRHESHOLD DEFINED IN PARAMS
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
    % params = [detectionDuration MVT0 noMvtThresh];
    
    detectionDuration = params(1);
    MVT0 = params(2);
    noMvtThresh = params(3);

    ITIMovement = false;

    ESC = true;
    
    % Check if movement for a fixed duration
    detectionStart_time = tic;
    current_time = toc(detectionStart_time);
    while ITIMovement == false && ESC && current_time < detectionDuration
        % update time
        current_time = toc(detectionStart_time);

        % update arduinoIN data
        ARDUINO.data(ARDUINO.idx,:) = readArduino(ARDUINO.in, ARDUINO.t0);

        % check if went above the noMvtThresh
        if ARDUINO.data(ARDUINO.idx,2) > (MVT0+noMvtThresh)
            ITIMovement = true;
        end

        % for escaping
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;

        % increment Arduino.idx
        ARDUINO.idx = ARDUINO.idx+1;
    end
    
    