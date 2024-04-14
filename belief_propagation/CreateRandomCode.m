function [G, H] = CreateRandomCode(wordLength, codewordLength)

I_h = eye(codewordLength - wordLength);
I_g = eye(wordLength);

P = logical(randi([0,1],[wordLength, codewordLength - wordLength]));
G = [I_g, P];
H = [transpose(P), I_h];

end