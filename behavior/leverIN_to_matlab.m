%{
    Record Arduino bytes as fast as possible straight from the serial port
    and save into `lever_data`

    Make sure:
    1) Serial port selected MUST BE EMPTY of anyone else trying to
    read it.
    2) BaudRate for the Arduino is also set to what is written here
    (e.g. 115200 is the max for Arduino UNO) 2 bytes of data are sent from Arduino
    4) lever_data only stores data for however long it has empty rows for
    5) MUST BE RUN ON ITS OWN CPU CORE, asynchronously from any other programs
    6) CLOSE SERIAL PORT CONNECTIONS AFTER FINISHED RUNNING

    While the loop is running, simply do Ctrl+C or stop the program to stop
    recording from serial port.

    231026: tested with Arduino UNO USB virtual serial port on M1 Mac-- 9kHz sampling rate somehow
    231027: tested with Arduino UNO USB virtual serial port on Windows-- >5kHz
    231030: tested with the real setup, start lever_data before session,
    end lever_data before session ESC OR after session ends normally
    ends--> 9kHz

%}

%%
clc
% leverIN Arduino initialization
%leverIN = serial("/dev/cu.usbmodem11401", 'BaudRate', 115200);

leverIN = serial("COM4", 'BaudRate', 115200);
fopen(leverIN);

% Data saving storage initialization
lever_data = zeros(72000000,1); % 2 hours = 7200000 milliseconds

% Main loop
n = 1;
tic
while 1
    % Get whatever the latest 2 bytes of data are
    leverIN_serial_output = fread(leverIN, 2);
    lever = typecast(uint8(leverIN_serial_output(1:2)), 'int16');
    
    % Save the data
    lever_data(n, :) = lever;
    
    n=n+1;
end

%% Plot the lever_data
%n = 10274480
%n = 15470
%scatter(15460:1:n, lever_data(15460:1:n))
scatter(1:1:n, lever_data(1:1:n))
%ylim([400 3700])

%% Save the lever_data
lever_data_filename = input('filename:\n','s');
save(lever_data_filename+".mat","lever_data");

%% Save the lever_data as json
% lever_data_json = jsonencode(lever_data)
% 
% lever_data_filename = input('filename:\n','s');
% json_file = fopen(lever_data_filename+'.json', 'w');
% fprintf(json_file, '%s', lever_data_json);
% fclose(json_file);

%% Close serial port connections
fclose(leverIN)
delete(leverIN)
clear leverIN