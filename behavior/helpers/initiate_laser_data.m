function [outputdata,stimType] = initiate_laser_data(options)

% Options
% options.sr - Sample rate. default: 2000 Hz
% options.laserMode - Stimulation mode: PULSES or continuous
% options.laserAmp - Amplitude from 0 to 5. Default: 5 mV
% options.laserDuration - Duration of stimulation. Default: 1 sec
% options.laserPulseDur - Pulse duration in msec. Default: 0.01 sec
% options.laserPulseFreq - Pulse frequency in Hz. Default: 10 Hz
% options.extra - Extra time added at end of stimulus. Default 0.001 sec
% options.cardOn - 0 or 1. To bypass any nidaq card setup. Default: 1.

% Default value
sr = 2000; % sample rate
laserMode = 'ramp'; % 
laserAmp = 5; % amplitude from 0 to 5.
duration = [1 2]; % duration of stimulation. Can define more than one.
pulseDur = 0.01; % pulse duration in sec.
pulseFreq = [5 10 25]; % pulse frequency in Hz. Can define more than one.
extra_post = 0.5; % extratime added at end of stimulus to allow for PMT shutters to reopen
extra_pre = 0.5; %add 10 ms before and after pulse to allow PMT shutters to close
% % ==========================
% Some checkups
if nargin > 0
    if isfield(options,'laser');
            if isfield(options.laser,'extra_pre'); extra_pre = options.laser.extra_pre; end
            if isfield(options.laser,'extra_post'); extra_post = options.laser.extra_post; end
            if isfield(options.laser,'laserAmp'); laserAmp = options.laser.laserAmp; end
            if isfield(options.laser,'mode'); laserMode = options.laser.mode; end
            if isfield(options.laser,'duration'); duration = options.laser.duration; end
            if isfield(options.laser,'pulseDur'); pulseDur = options.laser.pulseDur; end
            if isfield(options.laser,'pulseFreq'); pulseFreq = options.laser.pulseFreq; end
            if isfield(options.laser,'sr'); sr = options.laser.sr; end
    end

end

% stimulus parameters
switch laserMode
    case 'continuous'
        k = 1;
        for i = 1:length(duration)
            outputdata{k} = [zeros(sr*extra_pre,1);laserAmp*ones(sr*duration(i),1);zeros(sr*extra_post,1)];
            stimType(:,k) = [duration(i) 0];
            k = k + 1;
        end
    case 'pulses'
        k = 1;
        for i = 1:length(duration)
            for j = 1:length(pulseFreq)
                pulse = [laserAmp*ones(pulseDur*sr,1); zeros(round(sr/pulseFreq(j)-pulseDur*sr),1)];
                outputdata{k} = [zeros(sr*extra_pre,1); repmat(pulse,[round(duration(i)*sr/length(pulse)),1]);zeros(sr*extra_post,1)];
                stimType(:,k) = [duration(i) pulseFreq(j)];
                k = k+1;
            end
        end
        %pulse;
    case 'ramp' %half the duration is a step, other half used to ramp down
        k = 1;
        for i = 1:length(duration)
                pulse = laserAmp*ones(sr*duration(i),1);
                pulse((1:sr*duration(i)/2)) = linspace(laserAmp,0,sr*duration(i)/2);
                outputdata{k} = [zeros(sr*extra_pre,1); pulse ;zeros(sr*extra_post,1)];
                stimType(:,k) = [duration(i) pulseFreq];
                k = k+1;
          end
        end
        
end
