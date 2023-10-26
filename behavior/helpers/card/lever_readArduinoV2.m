function d = lever_readArduinoV2(ard)
% d(1) = absolute time
% d(2) = lever value

%fopen(ardOut);

%fopen(ardIn);
%fscanf(ardIn); % Read value returned via Serial communication

nBytes = 6

raw_port_output = fscanf(ard);

double_port_output = double(raw_port_output);
d(1) = double_port_output(1) % micros time
d(2) = double_port_output(2) * 255 + double_port_output(3); % lever
