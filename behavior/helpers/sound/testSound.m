 close all; clc;
    clear all;
snd = soundInitII;
nSound = length(snd.buffers);

for j = 1:25
    for i = [1 5 2 6 3 7 4 8]%:nSound
        fprintf('Sound id #%d\n',i)
        soundPlay(i,snd),
        pause(2)
        soundStop(snd)
        %     fprintf('Stopped\n');
    end
end
soundClean(snd)
