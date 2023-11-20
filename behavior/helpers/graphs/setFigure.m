function setFigure(style)
% function setFigure(style)
% List of style: 
% 'narrow'
% 'thin'
% 'large'
% 'tall'
% 'narrowtall'
% 'full'
% 'splitLeft'
% 'splitRight'
% 'compact'

if nargin <1
    style = '';
end

pos = get(gcf,'position');
scr = get(0,'screensize');
switch style
    case 'narrow'
        set(gcf,'position',[pos(1) pos(2) pos(3)/2 pos(4)]);
    case 'large'
        set(gcf,'position',[scr(3)/8 pos(2) scr(3)*3/4 pos(4)]);
    case 'thin'
        set(gcf,'position',[pos(1) pos(2) pos(3) pos(4)/2]);
    case 'tall'
        set(gcf,'position',[scr(3)/4 scr(2) scr(3)/2 scr(4)]);
    case 'narrowtall'
        set(gcf,'position',[pos(1) scr(4)/6 pos(3)/2 scr(4)*2/3]);
    case 'full'
        set(gcf,'position',scr);
    case 'splitLeft'
        set(gcf,'position',[scr(1) scr(2) scr(3)/2 scr(4)]);
    case 'splitRight'
        set(gcf,'position',[scr(3)/2 scr(2) scr(3)/2 scr(4)]);
    case 'compact'
        set(gcf,'position',[pos(1) pos(2) pos(3)/2 pos(4)/2]);
end