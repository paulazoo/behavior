function soundStorage = soundInit(root_dir)

cd([root_dir filesep 'helpers' filesep 'sound' filesep]);

soundStorage = [];
[soundStorage(1).waves, soundStorage(1).Fs] = audioread('soundFiles/4000Hz_500ms_48000.mp3');

[soundStorage(5).waves, soundStorage(5).Fs] = audioread('soundFiles/12000Hz_500ms_48000.mp3');

[soundStorage(9).waves, soundStorage(9).Fs] = audioread('soundFiles/click_500ms.mp3');

cd(root_dir);






