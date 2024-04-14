function [success, time] = test2(l, p, desired_length, e)

H = CreateLDPC(desired_length, l, p);

wordLength = size(H,2) - size(H,1);
codewordLength = size(H,2);
word = CreateRandomWord(wordLength);

G = zeros(wordLength, codewordLength);

C = Coder(G,H);

sentCodeword = C.Encode(word);
receivedCodeword = BEC_Model(sentCodeword, e);

% Time the decoder
tStart = tic;
[decoderSuccess, decodedCodeword] = C.BEC_Belief_Decode(receivedCodeword);
time = toc(tStart);

correctBits = sum(decodedCodeword == sentCodeword);

success = correctBits == codewordLength;

end