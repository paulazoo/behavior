function soundClean(snd)
%%% CLEAN UP
    % Stop playback:
    PsychPortAudio('Stop', snd.pahandle);
    % Close the audio device:
    PsychPortAudio('Close', snd.pahandle);
