%% WILL NOT HAVE AS FAST SAMPLING RATE DUE TO ESC LISTENING


%%
clc; clear all; close all;
disp("Running....")
% leverIN Arduino initialization
leverIN = serial("COM11", "Baudrate", 115200);
fopen(leverIN);

% Keyboard
escapeKey = KbName('esc');
[~,~,keyCode] = KbCheck;
ESC = keyCode(escapeKey) == 0;

% Data saving storage initialization
lever_bytes = zeros(72000000,2); % 2 hours = 7200000 milliseconds

disp("Recording lever data...")
% Main loop
n = 1;
while ESC
    % Get whatever the latest 2 bytes of data are
    leverIN_serial_output = fread(leverIN, 2);
    lever_bytes(n, :) = uint8(leverIN_serial_output(1:2));
    
    n=n+1;
    
    [~,~,keyCode] = KbCheck;
    ESC = keyCode(escapeKey) == 0;
end

disp('Closing...')
fclose(leverIN)
delete(leverIN)
clear leverIN
disp('Closed')

%% Convert bytes into data
% will take up to 69 seconds lol for 7200000 (2 hours worth) of samples
tic
lever_data = zeros(72000000,1); % 2 hours = 7200000 milliseconds
for i=1:1:n
    lever_data(i, :) = typecast(uint8(lever_bytes(i, :)), "int16");
end
toc

%% Plot the lever_data
figure()
subplot(1,2,1)
hold on
scatter(1:1:n, lever_data(1:1:n, :))
%ylim([0 3000])
title('non-reversed')

%% Try the reverse lever_data
% will take up to 5.6 min for 7200000 (2 hours worth) of samples
tic
reversed_lever_bytes = zeros(72000000,2);
reversed_lever_bytes = horzcat(lever_bytes(1:end-1, 2), lever_bytes(2:end, 1));
reversed_lever_data = zeros(72000000,1); % 2 hours = 7200000 milliseconds
for i=1:1:n
    reversed_lever_data(i, :) = typecast(uint8(reversed_lever_bytes(i, :)), "int16");
end
toc

%% Plot the reversed lever_data
subplot(1,2,2)
hold on
scatter(1:1:n, reversed_lever_data(1:1:n, :))
%ylim([0 3000])
title('reversed')

%% Pick which lever_data to save
lever_data_saved = false;
while lever_data_saved == false
    lever_data_choice = input('Use non-reversed or reversed? [1 or 2]\n', 's');
    if lever_data_choice == '1'
        lever_data_filename = input('saving non-reversed lever data. Filename:\n','s');
        save("LeverData_"+lever_data_filename+".mat", "lever_data", "lever_data_choice");
        lever_data_saved = true;
    elseif lever_data_choice == '2'
        lever_data_filename = input('saving reversed lever data. Filename:\n','s');
        lever_data = reversed_lever_data;
        save("LeverData_"+lever_data_filename+".mat", "lever_data", "lever_data_choice");
        lever_data_saved = true;
    else
        fprintf('input not recognized. asking again...\n')
    end
end


%% Preview butterworth filtered lever_data and check that noise is gone
fc=40;
fs=5888;
[b,a] = butter(6, fc/(fs/2));
filtered_lever_data = filter(b,a,lever_data(1:1:1000000, :));
figure()
hold on
scatter((1:1:1000000), (filtered_lever_data-2000)*5/1023)
title('Butterworth filter preview')
xlabel('seconds')
hold off
