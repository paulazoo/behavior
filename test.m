% if nargin < 1
anID = input('Please enter animal ID:\n','s');
% end

% % Define params
params = defineParamsToneDiscrimination_GF(anID);
if ~isstruct(params) && isnan(params)
    returnARDUINO
end


% Open communication with Arduino ---
[ardIn,ardOut] = lever_cardSetUpInOutV2_GF;
ARDUINO.in = ardIn;
ARDUINO.out = ardOut;
ARDUINO.idx = 1;

% Initialize variables ---
estSamplingRate = 250;
estDur = 70; %minutes
nSamples = estSamplingRate*60*estDur;
ARDUINO.data = nan(nSamples,7);

while True:
    print(ARDUINO.idx)