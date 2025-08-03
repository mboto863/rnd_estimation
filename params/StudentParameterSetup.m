classdef StudentParameterSetup < ParameterSetup
    properties
        dimension (1, 1)
    end
    methods
        function obj = StudentParameterSetup(dimension)
            arguments
                dimension (1, 1)
            end
            obj.dimension = dimension;
        end
        function vector = initializeAll(obj, data)
        %INITIALIZEALL Computes the initial values for the optimization algorithm.
        %
        % Input:
        %   obj     The StudentParameterSetup object.
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
                obj.initializeParameter("nu", data),...
                ];
        end
        function lower = getAllLowerBounds(obj)
        %GETALLLOWERBOUNDS Computes the parameter lower bounds.
        %
        % Input:
        %   obj     The StudentParameterSetup object.
        %
        % Output:
        %   lower   The lower bounds.

            arguments
                obj StudentParameterSetup
            end
            lower = [...
                obj.getLowerBound("omega"),...
                obj.getLowerBound("mu"),...
                obj.getLowerBound("sigma"),...
                obj.getLowerBound("nu")...
                ];
        end
        function upper = getAllUpperBounds(obj)
        %GETALLUPPERBOUNDS Computes the parameter upper bounds. 
        %
        % Input:
        %   obj     The StudentParameterSetup object.
        %
        % Output:
        %   upper   The upper bounds.

            arguments
                obj StudentParameterSetup
            end
            upper = [...
                obj.getUpperBound("omega"),...
                obj.getUpperBound("mu"),...
                obj.getUpperBound("sigma"),...
                obj.getUpperBound("nu")...
                ];
        end
        function lower = getLowerBound(obj, name)
        %GETLOWERBOUND Computes the lower bound for a single parameter.
        %
        % Input:
        %   obj     The StudentParameterSetup object.
        %   name    The name of the parameter.
        %
        % Output:
        %   lower   The lower bound.

            arguments
                obj StudentParameterSetup
                name (1, 1) string
            end
            %takes name of par and returns its static lower bound
            switch name
                case "omega"
                    %last dimension of omega is known
                    lower = zeros(1, obj.dimension - 1);
                case "mu"
                    lower = -1e4 * ones(1, obj.dimension);
                case "sigma"
                    lower = 1e-6 * ones(1, obj.dimension);
                case "nu"
                    lower = (2 + 1e-6) * ones(1, obj.dimension);
                otherwise
                    error('Invalid parameter value');
            end
        end
        function upper = getUpperBound(obj, name)
        %GETUPPERBOUND Computes the upper bound for a single parameter.
        %
        % Input:
        %   obj     The StudentParameterSetup object.
        %   name    The name of the parameter.
        %
        % Output:
        %   upper   The upper bound.

            arguments
                obj StudentParameterSetup
                name (1, 1) string
            end
            switch name
                case "omega"
                    upper = ones(1, obj.dimension - 1);
                case "mu"
                    upper = 1e4 * ones(1, obj.dimension);
                case "sigma"
                    upper = 4000 * ones(1, obj.dimension);
                case "nu"
                    %bound for the single fraction method
                    upper = 42 * ones(1, obj.dimension);
                otherwise
                    error('Invalid parameter value');
            end
        end
        function initialValue = initializeParameter(obj, name, data)
        %INITIALIZEPARAMETER Computes initial value for the optimization for a single parameter.
        %
        % Input:
        %   obj             The StudentParameterSetup object.
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
            switch name
                case "omega"
                    initialValue = 1 / obj.dimension * ones(1,...
                        obj.dimension - 1);
                case "mu"
                    [lowerBound, upperBound] = deal(obj.getLowerBound(name)...
                        ,obj.getUpperBound(name));
                    forwardPrice             = data.F(1);
                    if any(forwardPrice < lowerBound) ||...
                            any(forwardPrice > upperBound)
                        error('mu initializer not within static bounds');
                    end
                    initialValue = forwardPrice * ones(1, obj.dimension);
                case "sigma"
                    [lowerBound, upperBound] = deal(obj.getLowerBound(name)...
                        ,obj.getUpperBound(name));
                    idxAtTheMoney            = abs(...
                        data.K - data.under_mid(1))...
                        == min(abs((data.K - data.under_mid(1))));
                    impliedVolatility        = data.IV(find(idxAtTheMoney == 1, 1)...
                        ) * data.under_mid(1);
                    initialValue             = impliedVolatility * ones(...
                        1, obj.dimension);
                    if any(initialValue < lowerBound) ||...
                            any(initialValue > upperBound)
                        error('sigma initializer not within static bounds');
                    end
                case "nu"
                    [lowerBound, upperBound] = deal(obj.getLowerBound(name)...
                        ,obj.getUpperBound(name));
                    degreesOfLiberty         = 15; 
                    if any(degreesOfLiberty < lowerBound) ||...
                            any(degreesOfLiberty > upperBound)
                        error('nu initializer not within static bounds');
                    end
                    initialValue = degreesOfLiberty * ones(1, obj.dimension);
                otherwise
                    error(...
                        'Invalid parameter. Valid parameters: omega, mu, sigma, nu'...
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
        
            names = {'omega', 'mu', 'sigma', 'nu'};
        end
    end
end