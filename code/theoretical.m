sigmoid = @(t) (1 + exp(-t + 10)).^(-1)./2 + 0.25;
x = linspace(1,20,20);
y = sigmoid(x);
bar(x,y)
