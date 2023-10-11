clear all; close all; clc;

%% Parameters

% Durations
durITI = 0.5;
durStim = 5;

% Vis stim properties
sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
tf = 2;
dir = 0; % in degree
angle = 0;
sineWaveOn = false;
cntrst = 1;

% Other hardware params
physical_screen_ratio = 16/9; % used to display squares.
skipSyncTest = true;

% Cues?
% cues = false;
% cuesSpecs.backColor = 0.5; % Background color of cue screen
% cuesSpecs.foreColor = 0; % Luminance of cues.
% cuesSpecs.sqSize = 100; % Size of cues in pixels
% cuesSpecs.location = 'bottom'; % Location of cues

%% SET UP

% ARDUINO SET UP
[ardIn,~] = lever_cardSetUpInOutV3;
lever_readArduinoV3(ardIn);


nSample = round((durITI*2+durStim)/(11/ardIn.BaudRate*8)*2);
dataArd = nan(nSample,7); 
k = 0;

% Determine systname
[~,systName] = system('hostname');
systName = systName(1:end-1);

% Determine screen
screens=Screen('Screens');
switch systName
    case 'FIN-DE-SEMAINE.local'
        screenNumber = 0;
end

% Screen size
[x_pixel,y_pixel]= Screen('WindowSize',screenNumber); % Pixel resolution
distortFactor = physical_screen_ratio*y_pixel/x_pixel ;

% Find the color values which correspond to white, black, and gray
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=round((white+black)/2);
inc=white-gray;

% Create gratings matrix to input as different textures
% Texture
pixPerCycle=ceil(1/sf); % pixels/cycle, rounded up.
fr=sf*2*pi;
[x,y]=meshgrid(-x_pixel:x_pixel + pixPerCycle, 1);
%         [x,y]=meshgrid(-W:W + p, 1);
grating=gray + cntrst*inc*cos(fr*x);
if ~sineWaveOn
    grating(grating>gray)  = white * (1+cntrst)/2;
    grating(grating<=gray) = black + white * (1-cntrst)/2;
end

%% Screen set up

fprintf('Setting up visual stim')
% Take control of display
AssertOpenGL; fprintf('.')

% Open a double buffered fullscreen window, measure flip interval
if skipSyncTest
    Screen('Preference', 'SkipSyncTests', 1);
end
fprintf('.')

try
    
    scr=Screen('OpenWindow',screenNumber,gray); fprintf('.')
    [ifi]=Screen('GetFlipInterval',scr,100,0.0001,20); fprintf('.')
    
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(scr); fprintf('.')
    Priority(priorityLevel); fprintf('.')
    
    % Load texture in buffer
    gratingtex=Screen('MakeTexture', scr, grating); fprintf('.')
    blankscreen = Screen('MakeTexture',scr,gray*ones(y_pixel,x_pixel)); fprintf('DONE!\n')
    
    %% START OF FLIPS
    
    % Blank
    lever_resetArduinoIn(ardIn);
    Screen('DrawTexture',scr,blankscreen);
    Screen('Flip', scr, 0, 0, 1);
    t0 = tic;
    tStart = tic;
    while toc(tStart) <= durITI && ~KbCheck
        x = lever_readArduinoV3(ardIn,t0);
        nLines = size(x,1);
        dataArd((1:nLines)+k,:) = x;
        k = k+nLines;
        fprintf('t = %3.2f press = %i\n',dataArd(k-1,1),dataArd(k-1,2))
    end
    
    % Stim
    % NOTE: The idea is that flip are only done when needed. That way other
    % behavior components can be monitored
    % First flip is done while waiting for vertical retrace. 
    % Other flip are done without waiting but at an interval in time close to screen refreshing rate (slightly under)
    % The timing of each flip is not extremely accurate but good enough? 
    tStart = tic;
    FlipFlag = true;
    FirstFlag = true;
    nFlip = 0;
    pressed = false;
    while toc(tStart) <= durStim && ~pressed && ~KbCheck
        if FlipFlag
            % Create texture of gratings offset by temporal frequency *
            % pixPerCycle
            xoffset = mod(toc(tStart)*tf*pixPerCycle,pixPerCycle);
            srcRect=[xoffset 0 xoffset + x_pixel*2 y_pixel*2];            
            Screen('DrawTexture', scr, gratingtex, srcRect, [],  angle);
            
            if FirstFlag % First flip of the serie. Done in sync with VBL. Scripts wait for the flip to be done in order to obtain a precise flip0 measurement.
                flip0 = Screen('Flip',scr); 
                FirstFlag = false;
            else % Other flips are done with VBL but the script doesn't wait for it.
                Screen('Flip', scr, 0,0,1);
            end
            nFlip = nFlip+1;
            FlipFlag = false;
        end
            
        %% Insert code here to monitor behavior
        x = lever_readArduinoV3(ardIn,t0);
        nLines = size(x,1);
        dataArd((1:nLines)+k,:) = x;
        pressed = dataArd(k,2) < -1;
        k = k+nLines;
        
%         dataArd(k,1) = d(1); 
%         dataArd(k,2) = d(2) < -1;
%         pressed = d(2) < -1;
%         k = k+1;
        fprintf('t = %3.2f press = %i\n',dataArd(k-1,1),dataArd(k-1,2))
        
        % This part of the code monitor if a flip is needed
        if GetSecs-flip0 > ifi*(nFlip-1)+ifi*0.95 
                FlipFlag = true;
        end
    end
    
    % Blank
    Screen('DrawTexture',scr,blankscreen);
    tStart = tic;
    Screen('Flip', scr, 0, 0, 1);
    while toc(tStart) <= durITI && ~KbCheck
        x = lever_readArduinoV3(ardIn,t0);
        nLines = size(x,1);
        dataArd((1:nLines)+k,:) = x;
        k = k+nLines;
        fprintf('t = %3.2f press = %i\n',dataArd(k-1,1),dataArd(k-1,2))
    end

    % Clean up
    Screen('CloseAll');
    Priority(0);
catch ME
    % Clean up
    Screen('CloseAll');
    Priority(0);
    rethrow(ME)
end

%%
dataArd = dataArd(~isnan(dataArd(:,1)),:);

figure;
% plot(tStamps,[ifi; diff(tStamps)])
plot(diff(dataArd(:,1)))

figure;
plot(dataArd(:,1), dataArd(:,2))