clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;
% Make 0.1 seconds sampled every 1/1000 of a second
t = 0 : 1/48000 : 0.1;
% Define sine wave parameters.
f1 = 400; % per second
T1 = 1/f1; % period, seconds
amp1 = 1; % amplitude
f2 = 1200; % per second
T2 = 1/f2; % period, seconds
amp2 = 0.8; % amplitude
% Make signals.
signal1 = amp1 * sin(2*pi*t/T1);
signal2 = amp2 * sin(2*pi*t/T2);
signal = signal1 + signal2;
plot(t, signal1, 'r-', 'LineWidth', 1, 'MarkerSize', 16);
hold on;
plot(t, signal2, 'm-', 'LineWidth', 1, 'MarkerSize', 16);
plot(t, signal, 'b-', 'LineWidth', 1, 'MarkerSize', 16);
title('Sine Waves', 'FontSize', fontSize);
xlabel('Time', 'FontSize', fontSize);
ylabel('Signal', 'FontSize', fontSize);
