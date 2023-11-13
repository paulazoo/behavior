function soundPlay(soundId,snd)
PsychPortAudio('Stop', snd.pahandle);
PsychPortAudio('FillBuffer', snd.pahandle, snd.buffers(soundId));
PsychPortAudio('Start', snd.pahandle);