% Create a hamming code with N parity bits
function [H,G] = CreateHammingCode(parityBits)

% Check if parity bits is a number greater than 2
if parityBits <= 2 
    error("parityBits should be greater than 2")
end

totalBits = 2^parityBits - 1;
dataBits = 2^parityBits - parityBits - 1;

H = zeros(totalBits - dataBits, totalBits);

for m = 1:totalBits
    bin = Dec2BinNumeric(m, parityBits, 'right-msb');
    for n = 1:size(bin,2)
        if bin(n) == 1
            H(n,m) = true;
        end
    end
end

% Always use a zero codeword
G = zeros(dataBits,totalBits);

end