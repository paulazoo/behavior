function durValve = waterReward2duration(rewAmount,valveID,root_dir)
% Function to obtain the duration the valve should be opened (durValve) in sec
% for delivering a reward amount (rewAmount) in uL. Min is 2 uL.

% Initialize variables ===================
[~,systName] = system('hostname');
systName = systName(1:end-1);
cd([root_dir filesep 'helpers' filesep 'waterCalibration' filesep]);

% Load calibration file
if exist([systName filesep 'dataCalibration_valve' num2str(valveID) '.mat'],'file') > 0
    load([systName filesep 'dataCalibration_valve' num2str(valveID) '.mat'])
    valveDurTested = dataCalibration.valveDurTested;
    rewardDelivered = dataCalibration.rewardDelivered;
else
    fprintf('WARNING: No calibration file found in "%shelpers%scalibration%s%s%s".\n',root_dir,filesep,filesep,systName,filesep);
    durValve = nan;
    return
end

% Check date
dateCalib = dataCalibration.date;
today = date;
if datenum(today) - datenum(dateCalib) > 30
    fprintf('WARNING: Last time valve #%i was calibrated is %i days ago\n',valveID,datenum(today) - datenum(dateCalib));
    fprintf('Consider testing with ''calculateWaterCalibration'' function or calibrate!\n');
end

% Check amount set from calibration
if rewAmount < rewardDelivered(1)
    error('Reward amount (%3.1fuL) set too low for calibration data for valve %i.\n',rewAmount,valveID);
elseif rewAmount > rewardDelivered(end)
    error('Reward amount (%3.1fuL) set too high for calibration data for valve %i.\n', rewAmount,valveID);
end

% Extrapolate duration valve opening
if rewAmount ~= rewardDelivered(end)
    idx = find(rewAmount >= rewardDelivered,1,'last');
    durValve = valveDurTested(idx) + (rewAmount - rewardDelivered(idx))/(rewardDelivered(idx+1) - rewardDelivered(idx))*(valveDurTested(idx+1) - valveDurTested(idx));
else
    durValve = valveDurTested(end);
end

cd(root_dir);
end

