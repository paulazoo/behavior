function [ardIn,ardOut] = lever_cardSetUpInOut
% set up arduino used to send output
% - 2018 VBP -

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
    case 'SIPE-VIS1' %2P4
        portIn = 'COM19';
        portOut = 'COM20';
end

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

ardIn = serial(portIn);
ardIn.InputBufferSize = 50000;
ardIn.BaudRate = 9600;
ardIn.Timeout = 2;

if ~strcmp(systName,'DESKTOP-TC5GOAV')
    ardOut = serial(portOut);
    ardOut.InputBufferSize = 50000;
    ardOut.BaudRate = 9600;
    ardOut.Timeout = 2;
    % ard.FlowControl = 'hardware';
    fopen(ardOut);
else
    ardIn.BaudRate = 19200;
    ardOut = nan;
end


% ardIn.FlowControl = 'hardInware';
fopen(ardIn);
% fprintf(ardIn,'R');
fscanf(ardIn); % Read value returned via Serial communication