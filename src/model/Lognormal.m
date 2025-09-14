classdef Lognormal < Model
    properties
        dimension
    end
    methods
        function obj = Lognormal(dimension)
            obj.dimension = dimension;
        end

        function parameterSetup = getParameterSetup(obj)
            parameterSetup = LognormalParameterSetup(obj.dimension);
        end
    end
    methods (Static)
        function [inequality, equality] = getNonLinearConstraint(theta, valueHandler, futuresPrice)
        %GETNONLINEARCONSTRAINT Computes the non linear constraints.
        %
        % Input:
        %   theta           The RND parameters.
        %   valueHandler    A ValueHandler object.
        %   data            Smoothed option data.
        %
        % Output:
        %   inequality      Non linear constraint inequality.
        %   equality        Non linear constraint equality.

            arguments
                theta (1, :)
                valueHandler ValueHandler
                futuresPrice
            end

            % constraints
            equality   = [];
            inequality = [];
        end
        function price = getPrice(parameters, contractData)
        %GETPRICE Computes option model price.
        %
        % Input:
        %   parameters  The RND parameters.
        %   contractData        Smoothed option contract data.
        %
        % Output:
        %   price       Option model price.
        %
            arguments
                parameters struct
                contractData struct 
            end
            % set parameters
            omega = parameters.omega;
            mu    = parameters.mu;
            sigma = parameters.sigma;

            % Complete last omega.
            omega = [omega, 1 - sum(omega)];

            
            % Pricing formula variables.
            d1 = (-log(contractData.strike) + mu + (sigma .^ 2)) ./ sigma;

            
            d2 = d1 - sigma;

            % Compute the option model price.
            priceValues = omega .* (-exp(mu + (sigma .^ 2)/2) .* normcdf(-d1) + contractData.strike .* normcdf(-d2));
            price       = exp(-(contractData.riskFreeRate * contractData.timeToMaturity)) * sum(priceValues);
        end
        function price = getForwardPrice(parameters)
        %GETFORWARDPRICE Computes underlying model forward price.
        %
        % Input:
        %   parameters  The RND parameters.
        %
        % Output:
        %   price       The underlying model forward price.
        %
            arguments
                parameters struct
            end
            % Complete last omega.
            omega = [parameters.omega, 1 - sum(parameters.omega)];
            
            % Compute the forward model price.
            priceValues = omega .* parameters.mu;
            price       = sum(priceValues);
        end
    end
end