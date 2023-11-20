function [snd,soundParams] = soundInitCloud
% Similar to sound initII but no pre load buffer
% buffer are loaded as the animal is performing the task


% Scaling factor to adjust amplitude of both tones
[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName
    case '2P1Electro-PC'
        scalingFact = [1 0.15];
    case 'VISSTIM-2P1'  % OLD Behavior EPHYs
        scalingFact = [1 0.4];
    case 'DESKTOP-IFO4BCJ'
        scalingFact = [1 0.3];
    case 'DESKTOP-432ODAK' % Behavior box
        scalingFact = [1 0.5];
    case 'TP3Vstim'
        scalingFact = [1 0.25];
    case 'DESKTOP-TC5GOAV'
        scalingFact = [1 1];
    otherwise
        scalingFact = [1 1];
end


%%% SETTING UP PARAMS %%%
[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName
    case {'DESKTOP-432ODAK';'TP3Vstim';'DESKTOP-IFO4BCJ'}
        soundDriverFreq = 48000;
    otherwise
        soundDriverFreq = 44100; %Max sound driver frequency
        
end
soundParams.durStim = 0.8 ; %Total sound duration in s
soundParams.durSub = 0.03; %Duration of each sub sound in s
soundParams.frequencies = [4000 12000]; %No-go / go tone frequency 
soundParams.freqSub = 40; %repeating Frequency of each sub sound in Hz; not to be confused with actual frequency of each tone
soundParams.samplingFrequency = soundDriverFreq; % sound driver frequency
soundParams.scalingFact = scalingFact;

%%% INITIALIZE SOUND DRIVE + CREATE BUFFER FOR SOUNDS %%%
InitializePsychSound;
PsychPortAudio('Close');
snd.pahandle = PsychPortAudio('Open', [], [], 1, soundDriverFreq, 2);
PsychPortAudio('RunMode', snd.pahandle, 1);
