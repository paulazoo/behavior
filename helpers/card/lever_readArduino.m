function d = lever_readArduino(ard,t0,msgOn)
% function d = lever_readArduino(ard,message)
%
% d(1) = absolute time
% d(2) = lever value
% d(3) = lickspout1 value
% d(4) = lickspout2 value
%
% - 2018 VBP -
if nargin < 3
    msgOn = false;
    if nargin < 2
        t0 = 0;
    end
end
minBytes = 5;
a = [];
GO = true;
while length(a) <= minBytes || GO
%     fprintf(ard,'R');  % Serial send read request to Arduino
    bytes = ard.BytesAvailable;
    while bytes < minBytes
        bytes = ard.BytesAvailable;
    end
    [a,~] = fscanf(ard); % Read value returned via Serial communication
    if strcmp(a(1),'X')
        GO = false;
    end
end

if strcmp(a(1),'X') && length(a) >= minBytes
% if length(a) >= minBytes
    d(1) = GetSecs - t0;
    d(2) = -str2num(a(2:end-4))*0.0049;
    d(3) = str2num(a(end-3));
    d(4) = str2num(a(end-2));
else
    d(1) = GetSecs - t0;
    d(2:4) =  nan;
end
if msgOn; fprintf('%3.3f\t%2.3f\t%d\t%d\n',d(1),d(2),d(3),d(4)); end;