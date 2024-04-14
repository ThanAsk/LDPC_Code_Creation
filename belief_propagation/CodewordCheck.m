function out = CodewordCheck(codeword)
H = [0,1,0,1,1,0,0;0,0,1,1,0,1,0;1,0,0,1,0,0,1];

check = mod(codeword * transpose(H), 2);
out = sum(check) == 0;

end