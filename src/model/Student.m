classdef Student < Model
    properties
        dimension
    end
    methods
        function obj = Student(dimension)
            obj.dimension = dimension;
        end

        function parameterSetup = getParameterSetup(obj)
            parameterSetup = StudentParameterSetup(obj.dimension);
        end
    end
    methods (Static)
        function [inequality, equality] = getNonLinearConstraint(theta, valueHandler, contractData)
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
                contractData
            end

            % update value handler
            valueHandler.setVector(theta);

            % set parameters
            parameters = valueHandler.getStructure();

            % constraints
            equality   = Student.getForwardPrice(parameters, contractData) - contractData.futuresPrice;
            inequality = [];
        end
        function price = getPrice(parameters, contractData)
        %GETPRICE Computes option model price.
        %
        % Input:
        %   parameters  The RND parameters.
        %   data        Smoothed option data.
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
            nu    = parameters.nu;

            % Assign hypergeometric arguments.
            normalizationFactor = sigma .* sqrt(nu .* pi) .*...
                gamma(nu ./ 2) ./ gamma((nu + 1) ./ 2);
            % The lambda scalar of d.
            dlambda             = mu ./ abs(mu) .* sigma .* nu ./ (nu - 1) ./...
                normalizationFactor .* (1 + mu .^ 2 ./ sigma .^ 2 ./ nu) .^ 0.5;
            a                   = -0.5 * ones(size(mu));
            b                   = 1 - nu ./ 2;
            c                   = 0.5 * ones(size(mu));
            z                   = {...
                1 ./ (1 + sigma .^ 2 .* nu ./ mu .^ 2),...
                (contractData.strike - mu) .^ 2 ./ ((contractData.strike - mu) .^ 2 + sigma .^ 2 .* nu)...
                };
            
            % Compute RND factors
            dValues = zeros(size(a));
            for iComponent = 1 : numel(a)
                dHypergeometric = Hypergeometric(...
                    1,...
                    a(iComponent),...
                    b(iComponent),...
                    c(iComponent),...
                    z{1}(iComponent)...
                    );
                dValues(iComponent) = dlambda(iComponent) * dHypergeometric.computeApproximation();
            end
            d = sum(dValues);

            % Complete last omega.
            omega = [omega, 1 - sum(omega)];

            % Lambda scalar of price.
            priceLambda = omega .* (d + (contractData.strike - mu) ./ abs(contractData.strike - mu) .* sigma .^ 2 .* nu ./...
            (nu - 1) ./ normalizationFactor .* (1 + (contractData.strike - mu) .^ 2 ./ sigma .^ 2 ./ nu) .^ 0.5);
            % Compute price.
            priceValues = zeros(size(a));
            for iIn = 1 : numel(a)
                priceHypergeometric = Hypergeometric(1, a(iIn), b(iIn), c(iIn), z{2}(iIn));
                priceValues(iIn)    = priceLambda(iIn) * priceHypergeometric.computeApproximation();
            end
            price = exp(-(contractData.riskFreeRate - contractData.dividendYield) * contractData.timeToMaturity) *...
            sum(priceValues);
            % priceHypergeometricMixture = HypergeometricMixture(pricelambda, a, b, c, z{2});
            % price = exp(-(data.(cn.riskFreeRate) - data.(cn.dividendYield)) * data.(cn.timeToMaturity)) *...
            % priceHypergeometricMixture.computeApproximation();
        end
        function price = getForwardPrice(parameters, contractData)
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
                contractData
            end
            price = sum(parameters.omega .* parameters.mu(1 : end - 1)) + (...
                1 - sum(parameters.omega)) * parameters.mu(end);
        end
    end
    methods (Static, Access = private)
        function value = approximateBySingleFraction(a, b, c, z)
        %APPROXIMATEBYSINGLEFRACTION Computes an approximation to the Gaussian Hypergeometric function by the Single
        % Fraction method
        %
        % Input:
        %   a       The a argument of the Gaussian Hypergeometric function.
        %   b       The b argument of the Gaussian Hypergeometric function.
        %   c       The c argument of the Gaussian Hypergeometric function.
        %   z       The z argument of the Gaussian Hypergeometric function.
        %
        % Output:
        %   value   An approximation the the Gaussian Hypergeometric function.
        %
            arguments
                a (1, :) double
                b (1, :) double
                c (1, :) double
                z (1, :) double
            end
            value     = zeros(1, size(a, 2));
            tolerance = 10 ^ -15;
            for iComponent = 1 : size(a, 2)
                alpha = 0;
                betaa = 1;
                gammaa = 1;
                %zeta = [zeta(j-2), zeta(j-1), zeta(j), zeta(j+1)]
                zeta = [1, 0, 0, 0];
                for jIteration = 1:3
                    alpha  = (alpha + betaa) * jIteration * (c(iComponent)+...
                        jIteration - 1);
                    betaa  = betaa * (a(iComponent) + jIteration - 1) * (...
                        b(iComponent) + jIteration - 1) * z(iComponent);
                    gammaa = gammaa * jIteration * (c(iComponent) +...
                        jIteration - 1);
                    zeta(jIteration + 1) = (alpha + betaa) / gammaa;
                end
                jIteration = 4;
                while abs(zeta(4) - zeta(3)) / abs(zeta(3)) > tolerance ||...
                        abs(zeta(3) - zeta(2))/abs(zeta(2)) > tolerance ||...
                        abs(zeta(2) - zeta(1)) / abs(zeta(1)) > tolerance
                    alpha   = (alpha + betaa) * jIteration * (...
                        c(iComponent) + jIteration - 1);
                    betaa   = betaa * (a(iComponent) + jIteration - 1) * (...
                        b(iComponent) + jIteration - 1) * z(iComponent);
                    gammaa  = gammaa * jIteration * (c(iComponent) +...
                        jIteration - 1);
                    zeta(1) = zeta(2);
                    zeta(2) = zeta(3);
                    zeta(3) = zeta(4);
                    zeta(4) = (alpha + betaa) / gammaa;
                    
                    jIteration = jIteration + 1;
                end
                value(iComponent) = zeta(4);
            end
        end
    end
end