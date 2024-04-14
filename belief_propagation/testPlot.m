function testPlot(N)

X = zeros(1,N);
Y = zeros(1,N);

for i = 1:N
    sum_x = 0;
    sum_y = 0;
    maxJ = 100;
    for j = 1:maxJ
        [x,y] = test(10, 20, 0.1, N);
        sum_x = sum_x + x;
        sum_y = sum_y + y;
    end
    X(i) = (sum_x - sum_y)/(20*maxJ);
    Y(i) = i;
end

plot(Y,X);