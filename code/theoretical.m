close all
figure
% sigmoid = @(t) (1 + exp(-t + 10)).^(-1)./2 + 0.25;
x = linspace(-20,20,41);
y = x.^2 - 10^2;
xx = linspace(-5,5,11);
yy = -xx.^2 + 5^2;
bar([x(y>0) xx(yy>0)],[y(y>0) yy(yy>0)]);
% ylim([0 1]);
xlim([-20 20])
xlabel 'Required angle'
ylabel 'Num pixels'
title 'A theoretical result'
export_fig '../outputs/theoretical.png'
