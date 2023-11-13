function lever_cleanArduino(ard,type)
if nargin < 2
    type = 'OUT';
end

switch type
    case {'OUT','out'}
        fprintf(ard,'O'); % Water off + THit off
        fprintf(ard,'M'); % Air off
        fprintf(ard,'S'); % Air off 2
        fprintf(ard,'J'); % LED off
        fprintf(ard,'B'); % TStart pin back to 0
end
fclose(ard);
delete(ard);
