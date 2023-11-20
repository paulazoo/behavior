function lever_resetArduinoIn(ardIn)
% To flush the buffer and reset user data
% Requires MATLAB R2020a 
% VBP 2020
ardIn.UserData = [];
flush(ardIn);