function [ardIn,ardOut] = lever_cardSetUpInOutV3
% set up arduino used to send output
% - 2020 VBP -

[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName
    case '2P1Electro-PC'
        portIn = 'COM3';
        portOut = 'COM4';
    case 'VISSTIM-2P1'
        portIn = 'COM4';
        portOut = 'COM5';
    case 'DESKTOP-432ODAK'
        portIn = 'COM5';
        portOut = 'COM4';
    case 'TP3Vstim'
        portIn = 'COM3';
        portOut = 'COM4';
    case 'DESKTOP-TC5GOAV'
        portIn = 'COM4';
        portOut = 'COM5';
    case {'FIN-DE-SEMAINE.local';'FIN-DE-SEMAINE.lan'}
        portIn = '/dev/cu.usbmodem14201';
        portOut = '';
    case 'SIPE-VIS1'
        portIn = 'COM19';
        portOut = 'COM20';
end

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

baudRate = 19200;
ardIn = serialport(portIn,baudRate);
% ardIn.InputBufferSize = 50000;
ardIn.Timeout = 2;

if ~(strcmp(systName,'DESKTOP-TC5GOAV') || strcmp(systName,'FIN-DE-SEMAINE.local') || strcmp(systName,'FIN-DE-SEMAINE.lan'))
    ardOut = serial(portOut);
    ardOut.InputBufferSize = 50000;
    ardOut.BaudRate = 9600;
    ardOut.Timeout = 2;
    % ard.FlowControl = 'hardware';
    fopen(ardOut);
else
    ardOut = nan;
end

while ardIn.NumBytesAvailable < 1
end
read(ardIn,ardIn.NumBytesAvailable,'char');
% fopen(ardIn);
% fscanf(ardIn); % Read value returned via Serial communication