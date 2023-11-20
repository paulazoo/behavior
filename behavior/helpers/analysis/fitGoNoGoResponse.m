
function [xFit,yFit,B,ev] = fitGoNoGoResponse(toneInt,r,showfig)
% Fit data to probability of response in the go/no-go auditory detection task
% use ln(Pr/(1-Pr)) = b0 + b1*s_nogo + b2*s_go
%
% Inputs:
% r: response matrix. size(r,1) = n observations; size(r,2) = 8: all 8 tones
% toneInt: value for each tone intensity
%   Example:   offSet = 0.5;
%              toneInt = [(-3:0)-offset (0:3)+offset];
% showfit: logical value to indicate if you want to plot the fit value over
% the data

if nargin < 3
    showfig = false;
end

% Arrange X and Y for logistic regression
x = [-toneInt(1:4) 0 0 0 0];
x_nogo = repmat(x,size(r,1),1);
x = [0 0 0 0 toneInt(5:8)];
x_go = repmat(x,size(r,1),1);
X = [x_nogo(:) x_go(:)];
    Y = r(:);

% Fit function
[B,~,stats] = glmfit(X,Y,'binomial','link','logit');

% Outputs
resEval = 0.01;
xeval = 0:resEval:toneInt(end)+0.5;
yfit1 = glmval(B,[xeval' zeros(size(xeval))'],'logit');
yfit2 = glmval(B,[zeros(size(xeval))' xeval' ],'logit');
yFit = [yfit1(end:-1:1); nan(length(-xeval(1):resEval:xeval(1)),1) ; yfit2]';
xFit = [-xeval(end:-1:1) -xeval(1):resEval:xeval(1) xeval];

ev = 1-var(stats.resid)/var(Y);

% Figure
c = setColor;
if showfig
    figure;
    setFigure('compact')
    [m,err] = mean_sem(r);
    hold all
    plot(xFit(xFit < 0),yFit(xFit < 0),'color',c.red2)
    errorbarVBP(toneInt(toneInt < 0),m(toneInt < 0),err(toneInt < 0),c.red2)
    plot(xFit(xFit > 0),yFit(xFit > 0),'color',c.blue3)
    errorbarVBP(toneInt(toneInt > 0),m(toneInt > 0),err(toneInt > 0),c.blue3)
    xlabel('Delta tone intensity')
    ylabel('P_r_e_s_p')
    ylim([0 1])
    setUpPlot
end

