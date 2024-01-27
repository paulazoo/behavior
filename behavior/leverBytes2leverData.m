%% Load lever_bytes
load hi.mat

%% Convert bytes into data
% will take up to 69 seconds lol for 7200000 (2 hours worth) of samples
tic
lever_data = zeros(72000000,1); % 2 hours = 7200000 milliseconds
for i=1:1:1000000
    lever_data(i, :) = typecast(uint8(lever_bytes(i, :)), "int16");
end
toc

%% Plot the lever_data
figure()
scatter((1:1:n+100)/5888, lever_data(1:1:n+100, :)*5/1023)
ylim([0 5])

%% Try the reverse lever_data
% will take up to 5.6 min for 7200000 (2 hours worth) of samples
tic
reversed_lever_bytes = zeros(72000000,2);
reversed_lever_bytes = horzcat(lever_bytes(1:end-1, 2), lever_bytes(2:end, 1));
lever_data = zeros(72000000,1); % 2 hours = 7200000 milliseconds
for i=1:1:1000000
    lever_data(i, :) = typecast(uint8(reversed_lever_bytes(i, :)), "int16");
end
toc

%% Plot the lever_data
figure()
scatter((1:1:n+10000)/5888, lever_data(1:1:n+10000, :))
ylim([0 3100])

%% Preview butterworth filtered lever_data and check that noise is gone
fc=50;
fs=5888;
[b,a] = butter(6, fc/(fs/2));
filtered_lever_data = filter(b,a,lever_data(1:1:n+10000, :));
figure()
scatter((1:1:n+10000)/5888, (filtered_lever_data-2000)*5/1023)

%% Save the lever_data
lever_data_filename = input('filename:\n','s');
save(lever_data_filename+".mat", "lever_data");
