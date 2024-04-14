classdef Coder
    properties (Access = private)
        G (:,:) 
        H (:,:)
        sizeH (1,2)
    end
    methods
        % Constructor
        function obj = Coder(g, h)
            obj.G = g;
            obj.H = h;
            
            % Check if G and H are orthogonal
            if sum( mod( g*transpose(h), 2)) ~= 0
                error("G and H must be orthogonal");
            end
            
            obj.sizeH = size(h);
        end 
        
        % BSC decoding for factor graph with loops
        function [success, sentCodeword] = BSC_Decode(obj, receivedCodeword, errorRate, maxLoops)
            success = 0;
            
            % Check if error rate is fine
            if errorRate >= 0.5 || errorRate <= 0
                error('Invalid error rate value. Value should be in range of (0,0.5)')
            end
            
            logs = BSC_MessageToLog(receivedCodeword, errorRate);
            messages_VtoC = inf(obj.sizeH(1),obj.sizeH(2));
            messages_CtoV = inf(obj.sizeH(1),obj.sizeH(2));
            marginals = inf(1,obj.sizeH(2));
            
            % Initialize
            messages_VtoC = obj.H.*logs; 
            
            
            for N = 1:maxLoops
                CtoV();
                CalculateMarginals();
                sentCodeword = LogsToBits(marginals);
                
                if obj.isCodeword(sentCodeword)
                    success = 1;
                    break
                end
                
                VtoC();
                
            end
            
            % Send messages from all check nodes to variable nodes
            function CtoV()
                for i = 1:obj.sizeH(1)
                    for j = 1:obj.sizeH(2)
                        if obj.H(i,j) == 1
                            newH = obj.H;
                            newH(i,j) = 0;
                            nMessages = messages_VtoC(i, newH(i,:) == 1);
                            messages_CtoV(i,j) = CheckNodeMessage(nMessages);
                        end
                    end
                end
            end
            
            % Send messages from all variable nodes to all check nodes
            function VtoC()
                for j = 1:obj.sizeH(2)
                    for i = 1:obj.sizeH(1)                    
                        if obj.H(i,j) == 1
                            newH = obj.H;
                            newH(i,j) = 0;
                            nMessages = messages_CtoV(newH(:,j) == 1,j);
                            messages_VtoC(i,j) = VariableNodeMessage([transpose(nMessages),  logs(j)]);
                            %messages_VtoC(i,j) = VariableNodeMessage([transpose(nMessages)]);
                        end
                    end
                end
            end
            
            % Calculate marginals
            function CalculateMarginals()
                for j = 1:obj.sizeH(2)
                    nMessages = messages_CtoV(obj.H(:,j) == 1,j);
                    marginals(j) = VariableNodeMessage([ transpose(nMessages), logs(j) ]);   
                    %marginals(j) = VariableNodeMessage([ transpose(nMessages)]);
                end
            end
            
        end               
            
        % BSC decoding only for tree factor graphs
        function sentCodeword = BSC_Tree_Decode(obj, receivedCodeword, errorRate)
            
            % Check if error rate is fine
            if errorRate >= 0.5 || errorRate <= 0
                error('Invalid error rate value. Value should be in range of (0,0.5)')
            end           

            logs = BSC_MessageToLog(receivedCodeword, errorRate);
            messages_VtoC = inf(obj.sizeH(1),obj.sizeH(2));
            messages_CtoV = inf(obj.sizeH(1),obj.sizeH(2));

            marginals = inf(1,obj.sizeH(2));

            for vNode = 1:obj.sizeH(2)
               for cNode = 1:obj.sizeH(1)
                   if obj.H(cNode, vNode) == 1
                       CtoV(cNode, vNode)
                   end
               end
               neighbourMessages = transpose(messages_CtoV( obj.H(:,vNode) == 1, vNode ));

               % Add the channel message to the neighbour messages in orded to
               % calculate the final marginal
               marginals(vNode) = VariableNodeMessage([neighbourMessages, logs(vNode)]);
            end

            sentCodeword = LogsToBits(marginals);
            
            % Find the message from variable node j to channel node i
            % recursively
            function VtoC(i, j)
                check = obj.H(:,j);

                % Create a neighbour messages array and add the channel node message
                nMessages = inf(1, obj.sizeH(1));
                nMessages(1) = logs(j);
                % Create an index to know the next empty position of the
                % array
                nCount = 2;
                
                % d
               % a = messages_CtoV

                % If sum of code in column is 1 then we have a leaf so we get the
                % channel value
                if sum(check) == 1
                    messages_VtoC(i,j) = logs(j);
                else
                    % Find/calculate the neighbour messages in the collumn apart from the
                    % one we are searching right now
                    for k = 1:obj.sizeH(1)
                        if check(k) == 1 && i ~= k
                            % If the message we need does not exist
                            % calculate it recursively
                            if messages_CtoV(k, j) == inf
                                CtoV(k,j)
                            end
                            % Add the message to the neighbour messages and
                            % increase the empty position index
                            nMessages(nCount) = messages_CtoV(k,j);
                            nCount = nCount + 1;
                        end
                    end

                    % Calculate the final message from the neighbour
                    % messages
                    messages_VtoC(i,j) = VariableNodeMessage(nMessages);
                end    
            end

            % Find the message from channel node i to variable node j
            % recursively
            function CtoV(i, j)
                check = obj.H(i,:);

                % Create a neighbour messages array and an index to know the next empty position of the
                % array
                nMessages = inf(1, obj.sizeH(1));
                nCount = 1;
                
               % a = messages_VtoC
                if sum(check) == 1
                    % TODO: function for leaf?
                else
                    % Find/calculate the neighbour messages in the row apart from the
                    % one we are searching right now
                    for k = 1:7
                        if check(k) == 1 && j ~= k
                            % If the message we need does not exist
                            % calculate it recursively
                            if messages_VtoC(i,k) == inf
                                VtoC(i,k)
                            end
                            % Add the message to the neighbour messages and
                            % increase the empty position index
                            nMessages(nCount) = messages_VtoC(i,k);
                            nCount = nCount + 1;
                        end
                    end
                end
                
                % Calculate the final message from the neighbour
                % messages
                messages_CtoV(i,j) = CheckNodeMessage(nMessages);        
            end
        end
        
        % Belief propagation BEC decoding
        function [success, sentCodeword] = BEC_Belief_Decode(obj, receivedCodeword)
            messages = inf(obj.sizeH(1),obj.sizeH(2));
            
            sentCodeword = receivedCodeword;
            success = true;
                        
            for vNode = 1:obj.sizeH(2)
                % In case of erasure start searching
                if sentCodeword(vNode) == inf
                    ok = false;
                    checked = false(obj.sizeH(1), obj.sizeH(2));
                    for cNode = 1:obj.sizeH(1)
                        if obj.H(cNode, vNode) == 1
                            ok = CtoV(cNode, vNode); 
                            if ok 
                            % If the erasure is corrected replace it in
                            % sentCodewod                               
                                sentCodeword(vNode) = messages(cNode, vNode);
                                break
                            end
                        end
                    end
                    if (~ok)
                        % If the erasure was not corrected terminate the searches and return false 
                        success = false;
                        break
                    end
                end                
            end

            % Tries to find the messages(i,j) and returns true or false
            function success_c = CtoV(i, j)
                if checked(i,j)
                    if messages(i, j) == inf
                        success_c = false;
                    else
                        success_c = true;
                    end
                else
                    checked(i,j) = true;                    
                    
                    % Default condition in order to avoid runtime errors in
                    % the very unlikely (and unwanted) scenario where a
                    % check node is only connected to a sole erased variable
                    % node (check node degree 1)
                    success_c = false;
                    
                    % Sum the neighboors of the check node in order to get
                    % the outgoing message
                    sum = 0;
                    for k = 1:obj.sizeH(2)
                        if k ~= j && obj.H(i,k) == 1
                            success_c = VtoC(i,k);
                            if success_c
                                sum = sum + messages(i,k);
                            else
                                % If we cant calculate a neighboor message
                                % stop searching and return false
                                break
                            end
                        end
                    end
                    if success_c
                        messages(i, j) = mod(sum,2);
                    end
                end
            end
            
            % Tries to find the messages(i,j) and returns true or false
            function success_v = VtoC(i, j)
                if checked(i,j)
                    if messages(i, j) == inf
                        success_v = false;
                    else
                        success_v = true;
                    end
                else
                    checked(i,j) = true;
                    
                    if sentCodeword(j) ~= inf
                        messages(i, j) = sentCodeword(j);
                        success_v = true;
                    else
                        % Try to find at least one neighboor message and
                        % copy its value to messages(i,j)
                        for k = 1:obj.sizeH(1)
                            if obj.H(k, j) == 1
                                success_v = CtoV(k,j);
                                if success_v
                                    messages(i, j) = messages(k, j);
                                    break
                                end
                            end
                        end
                    end
                end
            end                   
        end
        
        function codeword = Encode(obj, word)
            codeword = mod((word * obj.G), 2);
        end
        
        function word = Decode(obj, codeword)
            x = gflineq(transpose(obj.G), transpose(codeword));
            word = transpose(x);
        end
    end  
    methods %(Access = private)
        function out = isCodeword(obj, codeword)
            out = sum( mod(obj.H*transpose(codeword), 2)) == 0;
        end
    end
end