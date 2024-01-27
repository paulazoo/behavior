function [ardIn,ardOut] = setupArduino()
% set up arduino used to send output
% - 2020 VBP -

[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName
    case 'SIPE-VIS1' %2P4 room
        portIn = 'COM3';
        portOut = 'COM4';
    case 'minicomputer' %2P4 room
        portIn = 'COM9';
        portOut = 'COM10';
end

% close all currently open ports
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

ardIn = serial(portIn);
ardIn.InputBufferSize = 50000;
ardIn.BaudRate = 19200;
ardIn.Timeout = 2;

ardOut = serial(portOut);
ardOut.InputBufferSize = 50000;
ardOut.BaudRate = 9600;
ardOut.Timeout = 2;
% ard.FlowControl = 'hardware';
fopen(ardOut);

fopen(ardIn);
fscanf(ardIn); % Read value returned via Serial communication