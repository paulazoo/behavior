function cleanArduino(ard,type)
if nargin < 2
    type = 'OUT';
end

switch type
    case {'OUT','out'}
        fprintf(ard,'X'); % Water off
        fprintf(ard,'B'); % Air off
        fprintf(ard,'J'); % tStart off
end
fclose(ard);
delete(ard);
end
