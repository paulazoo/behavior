function sendBehaviorMessage(str,subjectStr,userID)
% Function to send a behavior text message 'str' to user 'userID'
switch userID
    case {'VBP';'vincentbp';'vincent breton-provencher';'vbp'}
        send_text_message('8572343442','sprint',subjectStr,str);
    case {'GD';'Gabi';'gd';'Gabi Drummond'}
        send_text_message('8457021639','verizon',subjectStr,str);
    case {'DHY';'Dae Hee';'dhy';'Dae Hee Yun'}
        send_text_message('6178007425','att',subjectStr,str);
    case {'KJ';'Kyle';'kj';'Kyle Jenks'}       
        send_text_message('6034907084','verizon',subjectStr,str);
    case {'JP';'Jiho';'jp'}
        send_text_message('6176312196','verizon',subjectStr,str);
    case {'JS';'js';'jen';'Jen'}
        send_text_message('9253486079','verizon',subjectStr,str);
    otherwise
        warning('User is not defined for sending text alerts\n')
end