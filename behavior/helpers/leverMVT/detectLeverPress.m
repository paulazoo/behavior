function [ARDUINO,leverPress,ESC] = detectLeverPress(ARDUINO,params,escapeKey)
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
    % params = [duration MVT0 noMvtThresh mvtThresh maxMvtDuration];
    
    duration = params(1);
    MVT0 = params(2);
    noMvtThresh = params(3);
    mvtThresh = params(4);
    maxMvtDuration = params(5);

    leverPress = false;

    ESC = true;
    
    % Check if movement for a fixed duration
    started_below_noMvtThresh = false;
    time_since_noMvtThresh = 0;
    detectionStart_time = tic;
    while leverPress == false && ESC && current_time < duration
        % update time
        current_time = toc(detectionStart_time)

        % update arduinoIN data
        ARDUINO.data(ARDUINO.idx,:) = readArduino(ARDUINO.in, ARDUINO.t0);
        deltaMVT = ARDUINO.data(ARDUINO.idx,2)-MVT0;

        % if we previously started below the noMvtThresh
        if started_below_noMvtThresh == true
            time_since_noMvtThresh = current_time - noMvtThresh_time;

            % check if we made it past mvtThresh and did a lever press
            if ARDUINO.data(ARDUINO.idx,2) > (MVT0+mvtThresh)
                leverPress = true;
            
            % otherwise check if the time for completing a leverPress Mvt is up
            elseif time_since_noMvtThresh > maxMvtDuration
                started_below_noMvtThresh = false;
                time_since_noMvtThresh = 0;
            end
        end

        % check if we have started below the noMvtThresh
        if ARDUINO.data(ARDUINO.idx,2) < (MVT0+noMvtThresh)
            started_below_noMvtThresh = true;
            noMvtThresh_time = current_time;
        end

        % for escaping
        [~,~,keyCode] = KbCheck;
        ESC = keyCode(escapeKey) == 0;

        % increment Arduino.idx
        ARDUINO.idx = ARDUINO.idx+1;
    end
    
    