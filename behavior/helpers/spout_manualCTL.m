function spout_manualCTL(direction,ardOut,duration)
% direction = 1 or 'extend' or 'out'
%             2 or 'retract' or 'in'

if nargin<3
    duration = 0.5;  
end
setUpDirHFB_GF

%% set direction
if ischar(direction)
    if strcmpi(direction,'out') || strcmpi(direction,'extend')
        direction = 1;
    elseif strcmpi(direction,'in') || strcmpi(direction,'retract')
        direction = 2;
    else
        fprintf('INVALID DIRECTION\n')
        return
    end
end

% Set up command line to send to arduino
if direction == 1
    cmdO = 'R';
    cmdC = 'S';
elseif direction == 2
    cmdO = 'L';
    cmdC = 'M';
else
    fprintf('INVALID DIRECTION\n')
    return
end


%% move spout
fprintf(ardOut,cmdO);
WaitSecs(duration);
fprintf(ardOut,cmdC);
if direction == 1
    fprintf('EXTEND\n')
else
    fprintf('RETRACT\n')
end

