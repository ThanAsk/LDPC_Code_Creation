function out = BSC_MessageToLog(message, e)
  
% Check if error rate is fine
if e >= 1 || e <= 0
    error('Invalid error rate value. Value should be in range of (0,1)')
end

logs = zeros(size(message));
logs(message == 0) = log((1-e)/e);
logs(message == 1) = log(e/(1-e));

out = logs;
    
end