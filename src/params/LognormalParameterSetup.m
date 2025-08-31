classdef LognormalParameterSetup < ParameterSetup
    properties
        dimension
    end
    methods
        function obj = LognormalParameterSetup(dimension)
            arguments
                dimension
            end
            obj.dimension = dimension;
        end
        function vector = initializeAll(obj, data)
        %INITIALIZEALL Computes the initial values for the optimization algorithm.
        %
        % Input:
        %   obj     The LognormalParameterSetup object.
        %   data    Option tablized data.
        %
        % Output:
        %   vector  The intial values of the parameters.

            arguments
                obj StudentParameterSetup
                data table
            end
            vector = [...
                obj.initializeParameter("omega", data),...
                obj.initializeParameter("mu", data),...
                obj.initializeParameter("sigma", data),...
                ];
        end
        function initialValue = initializeParameter(obj, name, data)
        %INITIALIZEPARAMETER Computes initial value for the optimization for a single parameter.
        %
        % Input:
        %   obj             The LognormalParameterSetup object.
        %   name            The name of the parameter.
        %   data            Tablized option data.
        %
        % Output:
        %   initialValue    The initial value.

            arguments
                obj StudentParameterSetup
                name (1, 1) string
                data table
            end
            % Assign alias for the configuration of column names.
            cnf = ColumnNamesConfig();

            switch name
                case "omega"
                    initialValue = (1 / obj.dimension) * ones(1, obj.dimension - 1);
                case "mu"
                    forwardPrice             = data.(cnf.futuresPrice)(1);
                    initialValue = forwardPrice * ones(1, obj.dimension);
                case "sigma"

                    % All indices
                    idx                  = 1 : numel(data.(cnf.strike));
                    
                    % Get the underlying mid price for the corresponding day.
                    dayUnderlyingMid     = data.(cnf.underlyingMid)(1);
                    
                    % Indices for at the money options.
                    idxAtTheMoney        = idx(abs(data.(cnf.strike) - dayUnderlyingMid) ==...
                    min(abs(data.(cnf.strike) - dayUnderlyingMid)));
                    
                    % Just get the first implied volatilities, they are all the same.
                    impliedVolatilityIdx = idxAtTheMoney(1);
                    
                    % Assuming implied volatility comes in percentage of the underlying mid price.
                    impliedVolatility    = data.(cnf.impliedVolatility)(impliedVolatilityIdx) * dayUnderlyingMid;
                    initialValue         = impliedVolatility * ones(1, obj.dimension);
                otherwise
                    error(...
                        'Invalid parameter. Valid parameters: omega, mu, sigma'...
                        );
            end
        end
    end
    methods (Static)
        function names = getNames()
        %GETNAMES Retrieves the parameter names.
        %
        % Input:
        %
        % Output:
        %  names    The parameter names.
        
            names = {'omega', 'mu', 'sigma'};
        end
    end
end