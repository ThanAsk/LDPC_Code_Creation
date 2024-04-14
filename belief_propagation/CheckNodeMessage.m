function out = CheckNodeMessage(NeighbourMessages)
    P = NeighbourMessages/2;
    P = tanh(P);
    
    out = 2*atanh(prod(P));