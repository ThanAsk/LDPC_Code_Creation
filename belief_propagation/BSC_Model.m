% Simulates a binary symmetric channel
function out = BSC_Model(inputMessage, errorRate)

% Check if error rate is fine
if errorRate >= 1 || errorRate <= 0
    error('Invalid error rate value. Value should be in range of (0,1)')
end

randArray = rand(size(inputMessage));
out = inputMessage;
out(inputMessage == 1 & randArray <= errorRate) = 0;
out(inputMessage == 0 & randArray <= errorRate) = 1;

end