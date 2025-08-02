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
            obj.a = a;
            obj.b = b;
            obj.c = c;
            obj.z = z;
        end
        function approximation = approximate(obj)
            for iComponent = 1 : size(obj.a, 2)
                approximation = Hypergeometric(...
                obj.lambda(iComponent),...
                obj.a(iComponent),...
                obj.b(iComponent),...
                obj.c(iComponent),...
                obj.z(iComponent)...
                ).approximate();
            end
        end
    end
end