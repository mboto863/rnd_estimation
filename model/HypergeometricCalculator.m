classdef HypergeometricCalculator < handle
    properties
        a
        b
        c
        z
        id string
    end
    methods
        function obj = HypergeometricCalculator(a, b, c, z)
            arguments
                a
                b
                c
                z
            end
            obj.a = a;
            obj.b = b;
            obj.c = c;
            obj.z = z;

            % Set id for the numerical procedure according to 'Numerical methods for the computation of the confluent
            % and Gauss hypergeometric functions' by John Pearson et al. (table 6).
            if obj.a > 0 && obj.b > 0 && obj.c >= 0 && obj.z >= 0
                obj.id = "I(A)";
            elseif obj.a > 0 && obj.b > 0 && obj.c >= 0 && obj.z < 0
                obj.id = "I(B)";
            elseif obj.a < 0 && obj.b < 0 && obj.c >= 0
                obj.id = "II";
            elseif obj.a >= 0 && obj.b >= 0 && obj.c < 0
                obj.id = "III";
            elseif obj.a < 0 && obj.b < 0 && obj.c < 0
                obj.id = "IV";
            elseif (obj.a < 0 || obj.b < 0) && obj.c >= 0
                obj.id = "V";
            elseif (obj.a < 0 || obj.b < 0) && ob.c < 0
                obj.id = "VI";
            end
        end
        function approximation = computeHypergeometric(obj)
        %COMPUTEHYPERGEOMETRIC Approximates the Gauss hypergeometric function, assumes |z| < 1 / 2
        %
        % Input:
        %   obj              The HypergeometricCalculator object.
        %
        % Output:
        %   approximation    The approximated value.

            switch id
                case "I(A)"
                    
            end
        end
    end
end