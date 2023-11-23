pause(5);
value1=readArduino(ARDUINO.in, ARDUINO.t0);
soundPlay(1,soundPlayer);
disp(value1(2));
pause(5);
value2=readArduino(ARDUINO.in, ARDUINO.t0);
soundPlay(2,soundPlayer);
disp(value2(2));
disp(value2(2) - value1(2))

%% 231122 VALUE TESTING
%{
lever bar is 2 mm diameter.

Displacement of the lever end and Voltages:
6mm = 0.3861V, 0.4936V, 0.4252V
3mm =  0.2688V, 0.2395V, 0.2493V
1.5mm = 0.0929V, 0.2053V, 0.1613V
%}