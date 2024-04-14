function testHammingPlot(points, pointRepetitions, parityBits, maxLoops)

cd = zeros(1, points);
timesPerSuccess = zeros(1,points);
errors = linspace(0.00001,0.49999, points);

for i = 1:points
    for j = 1:pointRepetitions
        [success, time] = testHamming(parityBits, errors(i), maxLoops);
        if success
            cd(i) = cd(i) + 1;
            timesPerSuccess(i) = timesPerSuccess(i) + time;
        end       
    end
    if cd(i) ~= 0
        timesPerSuccess(i) = timesPerSuccess(i)/cd(i);
    end
    cd(i) = cd(i)/pointRepetitions;
end

% Plot percentage of correct decodings
plot(errors, cd);

% Plot decoding time per sucessful decoding
figure(2);
plot(errors, timesPerSuccess);