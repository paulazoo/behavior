function setUpDirHFB_GF()

[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName
 
    case 'SIPE-VIS1'
        cd 'D:\Dropbox (MIT)\Giselle Fernandes\RL motor learning\';
        
    case 'Giselle-HP'
        cd 'C:\Users\gisfe\Dropbox (MIT)\Giselle Fernandes\RL motor learning\';

end

cd 'D:\Dropbox (MIT)\Giselle Fernandes\DataShare_with_Paula\behavior\';

addpath([pwd filesep 'helpers' filesep]);
addpath([pwd filesep 'helpers' filesep 'analysis']);
addpath([pwd filesep 'helpers' filesep 'calibration' filesep]);
addpath([pwd filesep 'helpers' filesep 'card']);
addpath([pwd filesep 'helpers' filesep 'general']);
addpath([pwd filesep 'helpers' filesep 'sound']);
addpath([pwd filesep 'helpers' filesep 'graphs']);
addpath([pwd filesep 'helpers' filesep 'leverMVT']);
addpath([pwd filesep 'helpers' filesep 'visual']);



