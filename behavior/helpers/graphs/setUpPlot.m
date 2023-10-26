function setUpPlot(h)
% Layout graph
% h = handle to graph axis. Optional

if nargin < 1
    h = gca;
end

set(h,'tickdir','out');
set(h,'ticklength',[0.02 0.05]);
set(h,'fontsize',14);
set(h,'titlefontweight','normal');
set(gcf,'color','w');
set(h,'linewidth',0.75);
set(h,'XColor','k','YColor','k', 'ZColor','k');
set(h, 'GridColor', 'k');
set(h, 'MinorGridColor', 'k');
% set(h,'linewidth',1);
box off;
drawnow
