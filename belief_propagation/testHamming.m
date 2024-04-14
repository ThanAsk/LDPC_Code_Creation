function [success, time] = testHamming(parityBits, e, MaxLoops)

[G, H] = CreateHammingCode(parityBits);
C = Coder(G,H);

wordLength = size(G, 1);
codewordLength = size(G, 2);

word = CreateRandomWord(wordLength);

sentCodeword = C.Encode(word);
receivedCodeword = BSC_Model(sentCodeword, e);

% Time the decoder
tStart = tic;
[decoderSuccess, decodedCodeword] = C.BSC_Decode(receivedCodeword, e, MaxLoops);
time = toc(tStart);

correctBits = sum(decodedCodeword == sentCodeword);

success = correctBits == codewordLength;

end