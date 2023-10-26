function [s,sequence] = soundCloudStim(freq,rate,soundParams)
% function [s,sequence] = soundCloudStim(freq,rate,soundParams)
%
% Freq(1:2) = center frequency of each tone groups
% Rate (1) determine the rate (in sound clip /10 ms) of freq (1)
% Rate (2) determine the rate (in sound clip /10 ms) of freq (2)
% Note: rate*100 need to be a multiple of 5 otherwise it does not work.
% Sequence = sequence of tone ID ranging from 1 to 10. 1:5 are low freq and
% 6:10 are high freq. This is the sequence of low or high tones in time


% Set Up ==============
durStim = soundParams.durStim; %Total sound duration in s
durSub = soundParams.durSub; %Duration of each sub sound in s
freqSub = soundParams.freqSub; %Frequency of each sub sound in Hz
sr = soundParams.samplingFrequency;

nTone = round(freqSub*durStim);
totalSample = sr*durStim;
subSample = round(sr*durSub);
tSub = ((1:freqSub*durStim)-1)*sr/freqSub;

% Create a frequency list centered around both frequencies ==============
a = logspace(log10(freq(1)),log10(freq(2)),64);
delta = mean(diff(log10(a)));
listFLow = 10.^(log10(freq(1))+delta*(-2:2));
listFHigh = 10.^(log10(freq(2))+delta*(-2:2));
allF = [listFLow listFHigh];

% Shuffle frequency list at the desire rate
nRep = rate *100/5;
nRep = [nRep 10-sum(nRep)]; 
idF = [repmat(1:5,1,nRep(1)) repmat(6:10,1,nRep(2)) repmat((1:5)*0,1,nRep(3))];
sequence = idF(vecOfRandPerm(length(idF),length(tSub)));

soundOn = zeros(length(allF),totalSample);

tri = [1:30 29:-1:1];
tri = tri/trapz(tri); % Used to smooth tone onset and offset with convolution

for j = 1:length(allF)
    idx = (tSub(sequence == j)) + (1:subSample)';
    idx = idx(:);
    idx = idx(idx < totalSample);
    soundOn(j,idx) = 1;
    soundOn(j,:) = conv(soundOn(j,:),tri,'same');
end

%     subplot(1,8,i)
%     imagesc(1-soundOn{i})
%     colormap(gray)
%     setUpPlotCompact

% end

%% create matrix of all freq waves
listWave = nan(length(allF),totalSample);
a = 1;
t = linspace(0,durStim,sr*durStim);
for i = 1:length(allF)
    f = allF(i);
    listWave(i,:) = a*sin(2*pi*f*t);
end

% for i = 1:length(rate)
s = zeros(length(allF),totalSample);
s = listWave.*soundOn;
s = [sum(s); sum(s)];
%     allSound{i} = [sum(s); sum(s)];
%     X = reshape(X,;
% end

% %%
% %%% INITIALIZE SOUND DRIVE + CREATE BUFFER FOR SOUNDS %%%
% InitializePsychSound;
% PsychPortAudio('Close');
% snd.pahandle = PsychPortAudio('Open', [], [], 1, sr, 2);
% PsychPortAudio('RunMode', snd.pahandle, 1);
% tic
% for i = 1:length(allSound)
%     snd.buffers(i) = PsychPortAudio('CreateBuffer', snd.pahandle, allSound{i});
% end
% toc
%
% %%% play sound
%
% for j = 1:3
%     for i = 1:length(allSound)%:nSound
%         fprintf('Sound id #%d\n',i)
%         soundPlay(i,snd),
%         pause(2)
%         soundStop(snd)
%         %     fprintf('Stopped\n');
%     end
% end
% soundClean(snd)
%
%
%
% %%
% P = nan(sr/freqSub/2+1,length(tSub));
% %%
% figure
% set(gcf,'name','FFT')
% for j = 1:length(allSound)
% for i = 1:length(tSub)
%     Y = allSound{j}(1,(1:sr/freqSub)+(i-1)*sr/freqSub);
%     X = fft(Y);
%     amp = abs(X);
%     P(:,i) = amp(1:length(amp)/2+1);
% end
% freqFFT = sr*(0:length(X)/2)/length(X)/1000;
%
% subplot(1,8,j)
% imagesc(P)
% end
%
%
