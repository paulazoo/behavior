function soundPlay(soundID,soundStorage)

waves = soundStorage(soundID).waves;
Fs = soundStorage(soundID).Fs;

%play sound
sound(waves, Fs);