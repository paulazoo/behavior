function d = readArduino(ard,t0,msgOn)
% d(1) = absolute time
% d(2) = lever value
% d(3) = lickspout value
%
% t0 = tic in at the start of session

if nargin < 3
    msgOn = false;
    if nargin < 2
        t0 = tic;
    end
end

minBytes = 5;

flushinput(ard); % to avoid lags, clean buffer
% fscanf collects until a CR (13 in bytes) is recorded
behaviorINOutput = fscanf(ard);
% there will be a 10 byte at the end using fscanf()
while length(behaviorINOutput) < minBytes + 1
    flushinput(ard); % to avoid lags, clean buffer
    behaviorINOutput = fscanf(ard);
end

d(1) = toc(t0);
leverOutput = typecast(uint8(behaviorINOutput(1:2)), "int16"); % lever
d(2) = double(leverOutput)*5/1023;
d(3) = typecast(uint8([behaviorINOutput(3), 0]), "int16"); % lick

if msgOn; fprintf('time: %3.3f\n lever: %2.3f\n lick: %d\n',d(1),d(2),d(3)); end
end
