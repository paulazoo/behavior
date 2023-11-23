function snd = soundInit
soundAmp = 0.2; % Sound amplitude. Range 0 to 1.
dur =0.5;
freq1 = 4000;
freq2 = 12000;

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
    case 'DESKTOP-432ODAK' % Behavior cooler
        scalingFact = [1 0.5];
    case 'DESKTOP-V7798CL' % Behavior box
        scalingFact = [1 0.321];
    case 'TP3Vstim'
        scalingFact = [1 0.25];
    case 'DESKTOP-TC5GOAV'
        scalingFact = [1 1];
    case 'SIPE-VIS1' %2p4
        scalingFact = [.75 1];
    otherwise
        scalingFact = [1 1];
end

soundStimMatrix = [
    1 freq1 scalingFact(1)*soundAmp dur 50
    2 freq1 scalingFact(1)*soundAmp*0.3163 dur 50
    3 freq1 scalingFact(1)*soundAmp*0.1 dur 50
    4 freq1 scalingFact(1)*soundAmp*0.03163 dur 50
    
    5 freq2 scalingFact(2)*soundAmp dur 50
    6 freq2 scalingFact(2)*soundAmp*0.3163 dur 50
    7 freq2 scalingFact(2)*soundAmp*0.1 dur 50
    8 freq2 scalingFact(2)*soundAmp*0.03163 dur 50
    ]; % column 1 is index, 2 is freq, 3: amp, 4: dur; 5: SNR



%%% SETTING UP SOUND WAVES %%%
[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName
    case {'DESKTOP-432ODAK';'TP3Vstim';'DESKTOP-IFO4BCJ'; 'DESKTOP-V7798CL';'SIPE-VIS1'}
        soundDriverFreq = 48000;
    otherwise
        soundDriverFreq = 44100; %Max sound driver frequency
        
end

nSound = size(soundStimMatrix,1);

for i = 1:nSound
    f = soundStimMatrix(i,2);
    a = soundStimMatrix(i,3);
    d = soundStimMatrix(i,4);
    SNR = soundStimMatrix(i,5);;
    t = linspace(0,d,soundDriverFreq*d);
    s = a*sin(2*pi*f*t);
    s = s + randn(size(s))*std(s)/db2mag(SNR);
    allSound{i} = [s; s];
end


%%% INITIALIZE SOUND DRIVE + CREATE BUFFER FOR SOUNDS %%%
InitializePsychSound;
PsychPortAudio('Close');
snd.pahandle = PsychPortAudio('Open', [], [], 1, soundDriverFreq, 2);
PsychPortAudio('RunMode', snd.pahandle, 1);
for i = 1:nSound
    snd.buffers(i) = PsychPortAudio('CreateBuffer', snd.pahandle, allSound{i});
end


