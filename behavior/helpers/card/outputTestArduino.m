clear all;
close all;
clc;

[ardIn,ardOut] = lever_cardSetUpInOut;


fprintf(ardOut,'W'); % OPEN RIGHT
fprintf('OPEN WATER RIGHT\n');
pause(0.5);
fprintf(ardOut,'O'); % CLOSE
pause(1);
fprintf(ardOut,'E'); % OPEN LEFT
fprintf('OPEN WATER LEFT\n');
pause(0.5);
fprintf(ardOut,'O'); % CLOSE
pause(1);
fprintf(ardOut,'L'); % AIR LEFT
fprintf('OPEN AIR LEFT\n');
pause(0.5);
fprintf(ardOut,'M'); % CLOSE AIR LEFT
pause(1);
fprintf(ardOut,'R');  % AIR RIGHT
fprintf('OPEN AIR RIGHT\n');
pause(0.5);
fprintf(ardOut,'S'); % CLOSE AIR RIGHT
pause(1);
fprintf(ardOut,'I'); % LED ON
fprintf('TURN ON LED\n');
pause(0.5);
fprintf(ardOut,'J'); % LED OFF
pause(0.5);

% CLEAN UP =======================================================
fprintf(ardOut,'O');
lever_cleanArduino(ardIn);
lever_cleanArduino(ardOut);
