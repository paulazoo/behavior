%% Server initialization
addpath("./src")
server = EchoServer(30000);

%% leverIN Arduino initialization
leverIN = serial("/dev/cu.usbmodem11401", 'BaudRate', 115200);
fopen(leverIN);

%% Data saving storage initialization
lever_time = zeros(999999,2);

%% Find client
clientCode = server.Connections(1).HashCode;

%% Main loop
n = 1;
%t0 = clock;
while 1
    % Get 6 bytes of data
    leverIN_serial_output = fread(leverIN, 6);
    lever = typecast(uint8(leverIN_serial_output(1:2)), 'uint16');
    time = typecast(uint8(leverIN_serial_output(3:6)), 'int32');
    %time = round(etime(clock,t0) * 1000);
    
    % Save the data 
    lever_time(n, :) = [time, lever]; 
    
    % Send the data across the server
    %server.sendTo(clientCode, uint8(leverIN_serial_output))
    
    n=n+1;
end

%% Closer server connections
server.stop
delete(server);
clear server;

%% Close serial port connections
fclose(leverIN)
delete(leverIN)
clear leverIN