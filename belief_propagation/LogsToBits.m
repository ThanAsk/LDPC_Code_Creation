function out = LogsToBits(logArray)

% Note: For a channel with error rate of 0.5 the tree defaults to a zero
% code word so this might always  return the zero or the one codeword
out = double( logArray <= 0);

end