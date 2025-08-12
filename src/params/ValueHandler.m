classdef ValueHandler < handle
    properties
        lengths (1, :)
        names (1, :) cell {mustBeCellOfChar}
        state struct
    end
    methods
        function obj = ValueHandler(dimension, names, values)
            arguments
                dimension (1, 1)
                names (1, :) cell {mustBeCellOfChar}
                values (1, :)
            end
            obj.names    = names;

            % There is a limitation here, the first parameter is assumed to be omega.
            % The last component of omega is redundant, so store the other ones.
            obj.lengths  = [dimension - 1, dimension * ones(1, size(names, 2) - 1)];
            idx          = 1;
            obj.state(1) = struct();
            for iPar = 1:numel(names)
                length                  = obj.lengths(iPar);
                obj.state.(names{iPar}) = values(idx : (idx + length - 1));
                
                idx = idx + length;
            end
        end
        function setVector(obj, vector)
        %SETVECTOR Sets the parameter vector values.
        %
        % Input:
        %   obj     The ValueHandler object.
        %   vector  The parameter values to set.
        % Output:
        %

            arguments
                obj ValueHandler
                vector (1, :)
            end
            if sum(obj.lengths) ~= numel(vector)
                error('Input vector length does not match expected total parameter size')
            end
            idx = 1;
            for iPar = 1 : numel(obj.names)
                name             = obj.names{iPar};
                length           = obj.lengths(iPar);
                obj.state.(name) = vector(idx : idx + length - 1);
                
                idx = idx + length;
            end
        end
        function vector = getVector(obj)
        %GETVECTOR Retrieves a vector of the parameter values.
        %
        % Input:
        %   obj     The ValueHandler object.
        %
        % Output:
        %   vector  A vector of the parameter values.

            vector = [];
            for iPar = 1 : numel(obj.names)
                name   = obj.names{iPar};
                value  = obj.state.(name);
                vector = [vector, value(:)']; %ensure row vector for consistency
            end
        end
        function structured = getStructure(obj)
        %GETSTRUCTURE Retrieves the parameters in structured form.
        %
        % Input:
        %   obj           The ValueHandler object.
        %
        % Output:
        %   structured    The parameters.

            structured = obj.state;
        end
        function value = getParameter(obj, name)
        %GETPARAMETER Retrieves the parameter value.
        %
        % Input:
        %   obj      The ValueHandler object.
        %   name     The parameter name to retrieve the value from.
        %
        % Output:
        %   value    The parameter value.

            arguments
                obj ValueHandler
                name char
            end
            value = obj.state.(name);
        end
    end
end