function [ardIn,ardOut] = lever_cardSetUpInOutV3
% set up arduino used to send output

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

ardIn = serialport(portIn, 19200);
flush(ardIn)

ardOut = serial(portOut);
ardOut.InputBufferSize = 50000;
ardOut.BaudRate = 9600;
ardOut.Timeout = 2;