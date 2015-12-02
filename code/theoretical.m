close all
figure
sigmoid = @(t) (1 + exp(-t + 10)).^(-1)./2 + 0.25;
x = linspace(0,20,21);
y = sigmoid(x);
bar(x,y);
ylim([0 1]);
xlim([0 20])
xlabel 'Required angle to reach'
ylabel 'Percent of total area'
export_fig theoretical.png
