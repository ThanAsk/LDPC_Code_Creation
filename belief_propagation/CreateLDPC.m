function H = CreateLDPC(desiredVNodes, l, p)

cNodesDegrees = 0;
vNodesDegrees = 0;
edges = 0;

ok = FindSockets(desiredVNodes);
searchDistance = 0;
while ~ok
    searchDistance = searchDistance + 1;
    
    ok = FindSockets(desiredVNodes + searchDistance);
    if ~ok
        ok = FindSockets(desiredVNodes - searchDistance);
    end
end

cNodesDegrees = MatrixRandPerm(cNodesDegrees);
vNodesDegrees = MatrixRandPerm(vNodesDegrees);

H = false( size(cNodesDegrees,2), size(vNodesDegrees,2));

rp = randperm(edges);

c = 1;
for k = 1:edges
    while cNodesDegrees(c) == 0
        c = c + 1;
    end
    
    vSum = 0;
    for v = 1:size(vNodesDegrees, 2)
        vSum = vSum + vNodesDegrees(v);
        if vSum >= rp(k)
            %H(c, v) = ~H(c,v);
            H(c, v) = true;
            break
        end
    end   
       
    cNodesDegrees(c) = cNodesDegrees(c) - 1;
end

    % Accepts a matrix with dimensions [1,N] and returns a randomly
    % permutated matrix of same dimensions
    function perm = MatrixRandPerm(aMatrix)
        if size(aMatrix,1) ~= 1
            error("Matrix size should be [1,N]")
        end
        r = randperm(size(aMatrix,2));
        perm = aMatrix(1,r);
    end

    function success = FindSockets(newVNodes)
        L = round(newVNodes*l);
        vNodes = sum(L);

        vNodesDegrees = zeros(1, vNodes);

        s = 1;
        for i = 1:vNodes
            while L(s) == 0
                s = s + 1;
            end
            vNodesDegrees(i) = s;
            L(s) = L(s) - 1;
        end

        vEdges = sum(vNodesDegrees);

        test = p;

        for i = 1:size(p,2)
            test(i) = i*test(i);
        end

        cMult = vEdges/sum(test);

        P = round(cMult*p);
        cNodes = sum(P);

        cNodesDegrees = zeros(1, cNodes);

        s = 1;
        for i = 1:cNodes
            while P(s) == 0
                s = s + 1;
            end
            cNodesDegrees(i) = s;
            P(s) = P(s) - 1;
        end

        cEdges = sum(cNodesDegrees);
        
        success = cEdges == vEdges;
        edges = cEdges;
    end
end