classdef StudentParameterSetup
    properties
        dim (1,1)
    end
    methods
        function obj = StudentParameterSetup(dim)
            arguments
                dim (1,1)
            end
            obj.dim = dim;
        end
        function vec = initializeAll(obj,data)
            arguments
                obj StudentParameterSetup
                data table
            end
            vec = [...
                obj.initializeParameter("omega",data),...
                obj.initializeParameter("mu",data),...
                obj.initializeParameter("sigma",data),...
                obj.initializeParameter("nu",data),...
                ];
        end
        function lvec = getAllLowerBounds(obj)
            arguments
                obj StudentParameterSetup
            end
            lvec = [obj.getLowerBound("omega"),obj.getLowerBound("mu"),obj.getLowerBound("sigma"...
                ),obj.getLowerBound("nu")];
        end
        function uvec = getAllUpperBounds(obj)
            arguments
                obj StudentParameterSetup
            end
            uvec = [obj.getUpperBound("omega"),obj.getUpperBound("mu"),obj.getUpperBound("sigma"...
                ),obj.getUpperBound("nu")];
        end
        function l = getLowerBound(obj,name)
            arguments
                obj StudentParameterSetup
                name (1,1) string
            end
            %takes name of par and returns its static lower bound
            switch name
                case "omega"
                    %last dimension of omega is known
                    l = zeros(1,obj.dim-1);
                case "mu"
                    l = -1e4*ones(1,obj.dim);
                case "sigma"
                    l = 1e-6*ones(1,obj.dim);
                case "nu"
                    l = (2+1e-6)*ones(1,obj.dim);
                otherwise
                    error('Invalid parameter value');
            end
        end
        function u = getUpperBound(obj,name)
            arguments
                obj StudentParameterSetup
                name (1,1) string
            end
            switch name
                case "omega"
                    u = ones(1,obj.dim-1);
                case "mu"
                    u = 1e4*ones(1,obj.dim);
                case "sigma"
                    u = 4000*ones(1,obj.dim);
                case "nu"
                    %bound for the single fraction method
                    u = 42*ones(1,obj.dim);
                otherwise
                    error('Invalid parameter value');
            end
        end
        function v = initializeParameter(obj,name,data)
            arguments
                obj StudentParameterSetup
                name (1,1) string
                data table
            end
            switch name
                case "omega"
                    v = 1/obj.dim*ones(1,obj.dim-1);
                case "mu"
                    [lb, ub] = deal(obj.getLowerBound(name),obj.getUpperBound(name));
                    init = data.F(1);
                    if any(init < lb) || any(init > ub)
                        error('mu initializer not within static bounds');
                    end
                    v = init*ones(1,obj.dim);
                case "sigma" 
                    [lb, ub] = deal(obj.getLowerBound(name),obj.getUpperBound(name));
                    i_atm = abs(data.K-data.under_mid(1)) == min(abs((...
                        data.K-data.under_mid(1))));
                    iv = data.IV(find(i_atm == 1,1))*data.under_mid(1);
                    v = iv*ones(1,obj.dim);
                    if any(v < lb) || any(v > ub)
                        error('sigma initializer not within static bounds');
                    end
                case "nu"
                    [lb, ub] = deal(obj.getLowerBound(name),obj.getUpperBound(name));
                    init = 15; 
                    if any(init < lb) || any(init > ub)
                        error('nu initializer not within static bounds');
                    end
                    v = init*ones(1,obj.dim);
                otherwise
                    error(...
                        'Invalid parameter. Valid parameters: omega, mu, sigma, nu'...
                        );
            end
        end
    end
    methods (Static)
        function names = getNames()
            names = {'omega','mu','sigma','nu'};
        end
    end
end