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
clc; clear all; close all;
disp("Running....")
% leverIN Arduino initialization
leverIN = serial("COM11", "Baudrate", 115200);
fopen(leverIN);

% Data saving storage initialization
lever_bytes = zeros(72000000,2); % 2 hours = 7200000 milliseconds

disp("Recording lever data...")
% Main loop
n = 1;
while 1
    % Get whatever the latest 2 bytes of data are
    leverIN_serial_output = fread(leverIN, 2);
    lever_bytes(n, :) = uint8(leverIN_serial_output(1:2));
    
    n=n+1;
end

%% Save the lever_bytes
lever_bytes_filename = input('filename:\n','s');
save(lever_bytes_filename+".mat","lever_bytes","n");

%% Close serial port connections
fclose(leverIN)
delete(leverIN)
clear leverIN