function test2Plot(points, pointRepetitions, l,p,desiredLength)

cd = zeros(1, points);
timesPerSuccess = zeros(1,points);
errors = linspace(0.00001,0.49999, points);

for i = 1:points
    for j = 1:pointRepetitions
        [success, time] = test2(l,p,desiredLength, errors(i));
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
title("BP Decoding Error Rate in LDPC (45x99)")
xlabel("Bit Error Rate")
ylabel("Probability of Correct Decoding")

% Plot decoding time per sucessful decoding
figure(2);
plot(errors, timesPerSuccess);
title("Decoding Complexity in LDPC (45x99)")
xlabel("Bit Error Rate")
ylabel("Average CPU Decoding Time per Successful Decoding (s)")

end