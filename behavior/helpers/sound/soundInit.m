function snd = soundInit
soundAmp = 0.5; % Sound amplitude. Range 0 to 1.
soundStimMatrix = [
    1 2000 soundAmp 0.5
    2 14000 soundAmp 0.5
    3 880 soundAmp 20
    4 -1 soundAmp/6 20 % BLUE
    5 -2 soundAmp/6 20 % PINK
    6 -3 soundAmp/6 20 % RED
    7 -4 soundAmp/6 20 % VIOLET
    8 -4000 soundAmp 2
    ]; % column 1 is index, 2 is freq, 3: amp, 4: dur;



%%% SETTING UP SOUND WAVES %%%
[~,systName] = system('hostname');
systName = systName(1:end-1);
switch systName
    case 'DESKTOP-432ODAK'
        soundDriverFreq = 48000;
    otherwise
        soundDriverFreq = 44100; %Max sound driver frequency        
end
nSound = size(soundStimMatrix,1);

for i = 1:nSound
    f = soundStimMatrix(i,2);
    a = soundStimMatrix(i,3);
    d = soundStimMatrix(i,4);
    if f > 0
        t = linspace(0,d,soundDriverFreq*d);
        s = a*sin(2*pi*f*t);
    elseif f == -1
        s = bluenoise(soundDriverFreq*d)*a;
    elseif f == -2
        s = pinknoise(soundDriverFreq*d)*a;
    elseif f == -3
        s = rednoise(soundDriverFreq*d)*a;
    elseif f == -4
        s = violetnoise(soundDriverFreq*d)*a;
    elseif f == -4000
        SNR = 5; 
        t = linspace(0,d,soundDriverFreq*d);
        s = sin(2*pi*4000*t);
        s = s + randn(size(s))*std(s)/db2mag(SNR);
    end
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