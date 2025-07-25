classdef ValueHandler < handle
    properties
        lengths (1,:)
        names (1,:) cell {mustBeCellOfChar}
        state struct
    end
    methods
        function obj = ValueHandler(dim,names,values)
            arguments
                dim (1,1)
                names (1,:) cell {mustBeCellOfChar}
                values (1,:)
            end
            obj.names = names;
            obj.lengths = [dim-1,dim*ones(1,size(names,2)-1)];
            idx = 1;
            obj.state(1) = struct();
            for iPar = 1:numel(names)
                len = obj.lengths(iPar);
                obj.state.(names{iPar}) = values(idx:idx+len-1);
                idx = idx+len;
            end
        end
        function setVector(obj,vec)
            arguments
                obj ValueHandler
                vec (1,:)
            end
            if sum(obj.lengths) ~= numel(vec)
                error('Input vector length does not match expected total parameter size')
            end
            idx = 1;
            for iPar = 1:numel(obj.names)
                name = obj.names{iPar};
                len = obj.lengths(iPar);
                obj.state.(name) = vec(idx:idx+len-1);
                idx = idx+len;
            end
        end
        function vec = getVector(obj)
            vec = [];
            for iPar = 1:numel(obj.names)
                name = obj.names{iPar};
                value = obj.state.(name);
                vec = [vec,value(:)']; %ensure row vector for consistency
            end
%             v = zeros(1,numel(obj.names));
%             for j = 1:numel(obj.names)
%                 v(j) = obj.values.(obj.names{j});
%             end
        end
        function s = getStruct(obj)
            s = obj.state;
        end
        function val = getParameter(obj,name)
            arguments
                obj ValueHandler
                name char
            end
            val = obj.state.(name);
        end
    end
end