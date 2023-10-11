function d = lever_readArduinoV3(ard,t0)
% function d = lever_readArduino(ard,t0,message)
%
% d(1) = absolute time
% d(2) = lever value
% d(3) = lickspout1 value
% d(4) = lickspout2 value
% d(5) = accelerator X value
% d(6) = accelerator Y value
% d(7) = accelerator Z value
%
%
% 2020 VBP V3 - Use of read() instead of fscanf. MATLAB R2020a required.
% Warning output d could be more that one row of data. This depends on how
% much data was already available in the buffer.
% brokenLineIn = broken line from previous read. if no inputs it will assume there wasn't.
% 'ard' needs to be generated with serialport instead of serial.
% That version drop fewer lines and his helpful to sync with visual stim. Harder to code though.
% Use ard.UserData to store timing of previous read and broken lines to concatenate
% t0 is the timing of a previous 'tic' in the script. Default is at the begining of the function.
% I have removed the msgOn feature cause it was slowing down the function
%
% 2020 VBP V2 - NOW WITH ACCELEROMETER INPUTS; DOES NOT USE getSecs FUNCTION
% ANYMORE. TRYING TO GET RID OF PSYCH TOOLBOX EVENTUALLY.
if nargin < 2
    t0 = tic;
end

% Params
nBytes = 8;
timeOut = 1;
tPrev = toc(t0);
brokenLine = [];
if ~isempty(ard.UserData) % Take tprev and broken line from user data if any
    tPrev = ard.UserData(1); % Time stamp of last serial port read
    if length(ard.UserData) > 1
        brokenLine = ard.UserData(2:end);
    end
end

try
% Verify the number of Bytes before attempting to read the serial port
tWait = tic;
while ard.NumBytesAvailable < nBytes && toc(tWait) < timeOut
end

if ard.NumBytesAvailable >= nBytes
    % Read the serial port
    x = read(ard,ard.NumBytesAvailable,'char');
    
    % Get time stamps from last 'tic'
    tCurr = toc(t0);
    
    % Convert x (char) to doubles and find indices of 'return' characters (#13)
    x = double(x);
    idxReturn = find(x == 13);
    
    % Put previous brokenline to current data
    if ~isempty(brokenLine)
        x = [brokenLine x];
    else
        if idxReturn(1) < nBytes
            x = x(idxReturn(1)+1:end); % Flush broken line at the begining if no brokenLine was stored yet
        end
    end
    idxReturn = find(x == 13); % Search again carriage returns after editing lines
    nLines = length(idxReturn);
    
    if nLines > 0
        % How much time since last read and redistribute that time evenly b/w time points
        tThisData = linspace(tPrev,tCurr,length(idxReturn)+1);
        tThisData = tThisData(1:end-1); % Remove last time point so it does not overlap with next read
        
        % Process outputs
        d = nan(nLines,7);
        d(:,1) = tThisData; % Approximate time of read
        d(:,2) = (x(idxReturn-6) *255 + x(idxReturn-5)) * -0.0049; % Lever data 'A0 on Arduino'
        lickByte = x(idxReturn-4)-100;
        d(:,3) = floor(lickByte/10); % Lick spout #1 'D2 on Arduino'
        d(:,4) = mod(lickByte,10); % Lick spout #2 'D4 on Arduino'
        d(:,5) = x(idxReturn-3); % Accelero X 'A3 on Arduino'
        d(:,6) = x(idxReturn-2); % Accelero Y 'A4 on Arduino'
        d(:,7) = x(idxReturn-1); % Accelero Z 'A5 on Arduino'
    else
        d = nan(1,7);
        d(1) = tCurr;
    end
    % Store brokenline and timing of last read in ard.UserData
    if idxReturn(end) ~= length(x)
        brokenLineOut = x(idxReturn(end)+1:end);
    else
        brokenLineOut = [];
    end
    ard.UserData = [tCurr brokenLineOut];
else
    d = nan(1,7);
    d(1) = toc(t0); % if problem with reading, the function returns NaN with a time stamp in position (1)
end
catch
warning('Read issue from Arduino serial port')
end