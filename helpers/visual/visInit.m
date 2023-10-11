function [visTextures,scr,scrProperties] = visInit(visProperties)
% Initialize psychtoolbox. Load textures of visual stim that will be used
% for go no-go. Fixed spatial freq, but list of contrast to modulate
% difficulty.
%
% Vis stim properties

if nargin < 1
    sf = 0.005; % pix/cycles (not measured by receptive field in degree yet)
    sineWaveOn = false;
    cntrst = 10.^(linspace(-1,0,4));
    bckgrnd = 0.5;
else
    sf = visProperties.sf; % pix/cycles (not measured by receptive field in degree yet)
    sineWaveOn = visProperties.sineWaveOn;
    cntrst = visProperties.cntrst;
    bckgrnd = visProperties.background;
end
% Other hardware params
physical_screen_ratio = 16/9; % used to display squares.
skipSyncTest = false;

%% SET UPS
% Determine systname
[~,systName] = system('hostname');
systName = systName(1:end-1);

% Determine screen
switch systName
    case {'FIN-DE-SEMAINE.local';'FIN-DE-SEMAINE.lan'}
        screenNumber = 0;
        skipSyncTest = true;
    case 'TP3Vstim'
        screenNumber = 1;
end

% Screen size
[x_pixel,y_pixel]= Screen('WindowSize',screenNumber); % Pixel resolution
distortFactor = physical_screen_ratio*y_pixel/x_pixel ;

% Find the color values which correspond to white, black, and gray
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=round((white+black)/2);
bckgrnd = bckgrnd * white;

inc=white-gray;

%% Create gratings matrix to input as different textures
allGratings = cell(length(cntrst)+1,1);
for i = 1:length(cntrst)
    pixPerCycle=ceil(1/sf); % pixels/cycle, rounded up.
    fr=sf*2*pi;
    [x,~]=meshgrid(-x_pixel:x_pixel + pixPerCycle, 1);
    %         [x,y]=meshgrid(-W:W + p, 1);
    grating=gray + cntrst(i)*inc*cos(fr*x);
    if ~sineWaveOn
        grating(grating>gray)  = white * (1+cntrst(i))/2;
        grating(grating<=gray) = black + white * (1-cntrst(i))/2;
    end
    allGratings{i} = grating;
end
allGratings{i+1} = bckgrnd*ones(y_pixel,x_pixel); % (gray texture idx is length(cntrst) + 1


%% Initialize psychtoolbox

fprintf('Setting up visual stim')
% Take control of display
AssertOpenGL; fprintf('.')

% Open a double buffered fullscreen window, measure flip interval
if skipSyncTest
    Screen('Preference', 'SkipSyncTests', 1);
end
fprintf('.')

scr=Screen('OpenWindow',screenNumber,bckgrnd); fprintf('.')
ifi=Screen('GetFlipInterval',scr,100,0.0001,20); fprintf('.')

% Use realtime priority for better timing precision:
priorityLevel=MaxPriority(scr); fprintf('.')
Priority(priorityLevel); fprintf('.')


%% Load texture in buffer
for i = 1:length(allGratings)
visTextures{i}=Screen('MakeTexture', scr, allGratings{i}); fprintf('.');

end

%% scrProperties structure
scrProperties.ifi = ifi;
scrProperties.size = [x_pixel,y_pixel];
