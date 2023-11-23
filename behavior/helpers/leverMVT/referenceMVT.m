function MVT0 = referenceMVT(ARDUINO,num_reference_samples)
% ARDUINO is a structure with fields
%   in = serial port for input arduino
%   out = serial port for output arduino
%   idx = current idx number. Increased everytime arduino in is sampled
%   t0 = reference start time to evaluate data from
%   data = data read from arduino

keepTrying = true;
ii = 1;
while keepTrying
    MVT0 = nan(num_reference_samples,1);
    %     flushinput(ARDUINO.in);
    for sample_i = 1:num_reference_samples
        d = readArduino(ARDUINO.in);
        MVT0(sample_i) = d(2);
    end
    
    if max(std(MVT0))<0.05
        keepTrying = false;
        fprintf('Measured BL:  %1.3f\n',median(MVT0,'omitnan'))
        if median(MVT0,'omitnan') > -0.1 || median(MVT0,'omitnan') < -4.9
            error('Lever voltage is off. Are you sure it is connected???')
        end
    else
        ii = ii + 1;
        fprintf('Try again #%d\n',ii, ' bc MVT0 changed too much')
    end
end