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

            % Variable names.
            obj.names = names;

            % There is a limitation here, the first parameter is assumed to be omega.
            obj.lengths  = [dimension, dimension * ones(1, size(names, 2) - 1)];
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

            % Check if the object lengths is consistent with the provided vector.
            if sum(obj.lengths) ~= numel(vector)
                error('Input vector length does not match expected total parameter size')
            end

            % Index variable to assign the parameter values on each loop.
            idx = 1;

            for iParameter = 1 : numel(obj.names)
                % Get the ith parameter's name.
                name                      = obj.names{iParameter};

                % Get the ith parameter's length.
                parameterLength           = obj.lengths(iParameter);

                % Update the state of the ith parameter.
                obj.state.(name)          = vector(idx : ((idx + parameterLength) - 1));
                
                % Update the index.
                idx = idx + parameterLength;
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

            % Initialize vector and preallocate memory.
            vector = nan(1, sum(obj.lengths));

            % Index variable to define vector components to update on each loop.
            idx = 1;

            % Assign each parameter to the vector's corresponding components.
            for iParameter = 1 : numel(obj.names)
                
                % Get the ith parameter name
                name            = obj.names{iParameter};

                % Get the ith parameter value.
                value           = obj.state.(name);
                
                % Get the ith parameter length.
                parameterLength = obj.lengths(iParameter);

                % Assign the value to the vector's corresponding components.
                vector(idx : ((idx + parameterLength) - 1)) = value(:)'; % Ensure row vector for consistency.
                
                % Update the index.
                idx = idx + parameterLength;
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
        function names = getParameterNames(obj)
            names = obj.names;
        end
    end
end