function S = HFRootFolder_GF()

[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName

    case 'SIPE-VIS1' %2P4
        S =  'D:\Dropbox (MIT)\Giselle Fernandes\RL motor learning\';
    case 'Giselle-HP'
        S = 'C:\Users\gisfe\Dropbox (MIT)\Giselle Fernandes\RL motor learning\';

    otherwise
        error('HFRootFolder is not set up for this computer');
end
