% Convert decimal to binary in the form of [0,1] matrix with [1,N ]dimensions
% https://www.mathworks.com/matlabcentral/answers/440906-how-to-convert-decimal-into-binary
function out = Dec2BinNumeric(D, N, msb)
  B = rem(floor(D(:) ./ bitshift(1, N-1:-1:0)), 2);
  
  if strcmp(msb, 'left-msb')
      out = B;
  elseif strcmp(msb, 'right-msb')
      out = flip(B);
  else
      error ("msb should either be 'left-msb' or 'right-msb'")
  end
end