function BERtoCodeWordPlot(word)

errorRates = linspace(0.00001,0.99999,100);
codedErrorRates = zeros(1,100);
uncodedErrorRates = zeros(1,100);

codeword = SimpleEncoder(word);

for i = 1:100
    [codedErrorRates(i), uncodedErrorRates(i)] = BSC_Main(codeword, errorRates(i));
end

plot(errorRates,codedErrorRates);
hold
plot(errorRates,uncodedErrorRates);
xlabel('BSC(e)')
ylabel('BER')

figure(2)
plot(errorRates, codedErrorRates-uncodedErrorRates)

end