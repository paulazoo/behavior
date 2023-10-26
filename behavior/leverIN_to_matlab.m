%% leverIN Arduino initialization
leverIN = serial("/dev/cu.usbmodem11401", 'BaudRate', 115200);
fopen(leverIN);

%% Data saving storage initialization
lever_time = zeros(7200000,1); % 2 hours = 7200000 milliseconds

%% Main loop
n = 1;
while 1
    % Get 6 bytes of data
    leverIN_serial_output = fread(leverIN, 2);
    lever = typecast(uint8(leverIN_serial_output(1:2)), 'int16');
    
    % Save the data
    lever_data(n, :) = lever;
    
    n=n+1;
end

%% Close serial port connections
fclose(leverIN)
delete(leverIN)
clear leverIN