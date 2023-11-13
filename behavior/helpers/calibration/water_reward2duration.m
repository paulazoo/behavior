function durValve = water_reward2duration(rewAmount,valveID)
% function durValve = water_reward2duration(rewAmount,valveID);
% Function to obtain the duration the valve should be opened (durValve) in sec
% for delivering a reward amount (rewAmount) in uL. Min is 2 uL.

% Initialize variables ===================
if nargin < 2
    valveID = 1;
end

[~,systName] = system('hostname');
systName = systName(1:end-1);
Root = HFRootFolder_GF;
cd([Root filesep 'helpers' filesep 'calibration' filesep]);

% Load calibration
if exist([systName filesep 'dataCalibration_valve' num2str(valveID) '.mat'],'file') > 0
    load([systName filesep 'dataCalibration_valve' num2str(valveID) '.mat'])
    d = dataCalibration.valveDurTested;
    r = dataCalibration.rewardDelivered;
else
    fprintf('WARNING: No calibration file found in "%shelpers%scalibration%s%s%s".\n',Root,filesep,filesep,systName,filesep);
    durValve = nan;
    return
end

% Check date
dateCalib = dataCalibration.date;
today = date;
if datenum(today) - datenum(dateCalib) > 30
    fprintf('WARNING: Last time valve #%i was calibrated is %i days ago\n',valveID,datenum(today) - datenum(dateCalib));
    fprintf('Consider testing with ''water_testCalibrationRL'' function or calibrate!\n');
end

% Check amount set from calibration
if rewAmount < r(1)
    error('Reward amount (%3.1fuL) set too low for calibration data for valve %i.\n',rewAmount,valveID);
elseif rewAmount > r(end)
    error('Reward amount (%3.1fuL) set too high for calibration data for valve %i.\n', rewAmount,valveID);
end

% Extrapolate duration valve opening
if rewAmount ~= r(end)
    idx = find(rewAmount >= r,1,'last');
    durValve = d(idx) + (rewAmount - r(idx))/(r(idx+1) - r(idx))*(d(idx+1) - d(idx));
else
    durValve = d(end);
end
