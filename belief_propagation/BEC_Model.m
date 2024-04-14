% Each byte of the returned message may take values {0, 1, inf}
% 0 -> 0
% 1 -> 1
% inf -> erasure
function out = BEC_Model(inputMessage, errorRate)

% Check if error rate is fine
if errorRate >= 1 || errorRate <= 0
    error('Invalid error rate value. Value should be in range of (0,1)')
end

randArray = rand(size(inputMessage));
out = inputMessage;
out(randArray <= errorRate) = inf;

end