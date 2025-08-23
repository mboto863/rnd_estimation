classdef HypergeometricMixture < handle
    properties
        lambda (1, :) double
        a (1, :) double
        b (1, :) double
        c (1, :) double
        z (1, :) double
    end
    methods
        function obj = HypergeometricMixture(lambda, a, b, c, z)
            arguments
                lambda (1, :) double
                a (1, :) double
                b (1, :) double
                c (1, :) double
                z (1, :) double
            end
            obj.lambda = lambda;
            obj.a      = a;
            obj.b      = b;
            obj.c      = c;
            obj.z      = z;
        end
        function approximation = ComputeMixture(obj)
            %COMPUTEMIXTURE Approximate the Gaussian Hypergeometric mixture.
            %
            % Input:
            %   obj              The HypergeometricMixture object.
            %
            % Output:
            %   approximation    The approximation value.
            
            % Value of the mixture.
            mixtureValue = 0;
            
            % Compute for every component.
            for iComponent = 1 : size(obj.a, 2)
                
                % The Hypergeometric object.
                hypergeometric = Hypergeometric(obj.lambda(iComponent), obj.a(iComponent), obj.b(iComponent),...
                    obj.c(iComponent), obj.z(iComponent));
                
                % Approximate the hypergeometric.
                hypergeometricValue = hypergeometric.computeApproximation();
                
                % Add to the mixture value.
                mixtureValue = mixtureValue + hypergeometricValue;
                
            end
            
            % Return
            approximation = mixtureValue;
            
        end
    end
end