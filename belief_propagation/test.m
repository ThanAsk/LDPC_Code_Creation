function [x,y] = test(wordlength, codewordlength, e, MaxLoops)

word = CreateRandomWord(wordlength);

[G, H] = CreateRandomCode(wordlength, codewordlength);

C = Coder(G,H);

sentCodeword = C.Encode(word);
receivedCodeword = BSC_Model(sentCodeword, e);

[success, decodedCodeword] = C.BSC_Decode(receivedCodeword, e, MaxLoops);
success

%decodedWord = C.Decode(decodedCodeword)
%word

x = sum(receivedCodeword == sentCodeword);
y = sum(decodedCodeword == sentCodeword);

end