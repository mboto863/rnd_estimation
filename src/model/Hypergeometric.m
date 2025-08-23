classdef Hypergeometric < handle
    properties
        lambda (1, :) double
        a (1, :) double
        b (1, :) double
        c (1, :) double
        z (1, :) double
    end
    methods
        function obj = Hypergeometric(lambda, a, b, c, z)
            arguments
                lambda (1, 1) double
                a (1, 1) double
                b (1, 1) double
                c (1, 1) double
                z (1, 1) double
            end
            obj.lambda = lambda;
            obj.a      = a;
            obj.b      = b;
            obj.c      = c;
            obj.z      = z;
        end
        function approximation = computeApproximation(obj)
            %APPROXIMATE Approximate the Gaussian Hypergeometric.
            %
            % Input:
            %   obj              The Hypergeometric object.
            %
            % Output:
            %   approximation    The approximation value.
            
            % Get z to (0, 1/2).
            obj.normalizez();

            % Is a mixture.
            if size(obj.a, 2) > 1
                mixture = HypergeometricMixture(obj.lambda, obj.a, obj.b, obj.c, obj.z);
                approximation = mixture.computeApproximation();
                
            else
                % Is a single hypergeometric.
                if obj.lambda == 0
                    approximation = 0;
                else
                    hypergeometricCalculator = HypergeometricCalculator(obj.a, obj.b, obj.c, obj.z);
                    approximation = obj.lambda * hypergeometricCalculator.computeApproximation();
                end
            end
        end
    end
    methods (Access = private)
        % Transformation formulae
        function normalizez(obj)
            %NORMALIZEZ Applies a transformation formula to get the z argument inside the interval (0 , 1/2).
            %
            % Input:
            %   obj    The Hypergeometric object.
            %
            % Output:
            %   obj    The Hypergeometric object.
            
            if (0 <= obj.z) && (obj.z <= (1 / 2))
                return
            else
                temp = obj.getArguments();
                if temp.z < -1
                    obj.lambda = [...
                        (1 - temp.z) ^ -temp.a *...
                        gamma(temp.c) * gamma(temp.b - temp.a) /...
                        gamma(temp.b) / gamma(temp.c - temp.a)...
                        ,...
                        (1 - temp.z) ^ -temp.b *...
                        gamma(temp.c) * gamma(temp.a - temp.b) /...
                        gamma(temp.a) / gamma(temp.c - temp.b)...
                        ];
                    obj.a      = [temp.a, temp.b];
                    obj.b      = [temp.c - temp.b, temp.c - temp.a];
                    obj.c      = [temp.a - temp.b + 1, temp.b - temp.a + 1];
                    obj.z      = [1 / (1 - temp.z), 1 / (1 - temp.z)];
                elseif temp.z < 0
                    obj.lambda = (1 - temp.z) ^ (-temp.a);
                    % a stays the same
                    obj.b = temp.c - temp.b;
                    % c stays the same
                    obj.z = temp.z / (temp.z - 1);
                elseif temp.z > 2
                    obj.lambda = [((-temp.z) ^ -temp.a) *...
                        gamma(temp.c) * gamma(temp.b - temp.a)/...
                        gamma(temp.b) / gamma(temp.c - temp.a)...
                        ,...
                        ((-temp.z) ^ -temp.b) *...
                        gamma(temp.c) * gamma(temp.a - temp.b)/...
                        gamma(temp.a) / gamma(temp.c - temp.b)];
                    obj.a      = [temp.a, temp.b - temp.c + 1];
                    obj.b      = [temp.a - temp.c + 1, temp.b];
                    obj.c      = [temp.a - temp.b + 1, temp.b - temp.a + 1];
                    obj.z      = [1 / temp.z, 1 / temp.z];
                elseif temp.z > 1
                    obj.lambda = [((temp.z ^ (-temp.a)) *...
                        (gamma(temp.c) * gamma(temp.c - temp.a - temp.b))) /...
                        (gamma(temp.c - temp.a) * gamma(temp.c - temp.b))...
                        ,...
                        ((temp.z ^ (temp.a - temp.c)) *...
                        ((1 - temp.z) ^ (temp.c - temp.a - temp.b)) *...
                        gamma(temp.c) * gamma(temp.a + temp.b - temp.c)) /...
                        (gamma(temp.a) * gamma(temp.b))];
                    obj.a      = [temp.a, temp.c - temp.a];
                    obj.b      = [temp.a - temp.c + 1, 1 - temp.a];
                    obj.c      = [temp.a + temp.b - temp.c + 1, temp.c - temp.a - temp.b + 1];
                    obj.z     = [1 - 1 / temp.z, 1 - 1 / temp.z];
                elseif temp.z > 1 / 2
                    obj.lambda = [gamma(temp.c) * gamma(temp.c - temp.a - temp.b) /...
                        gamma(temp.c - temp.a) / gamma(temp.c - temp.b)...
                        ,...
                        (1 - temp.z) ^ (temp.c - temp.a - temp.b) *...
                        gamma(temp.c) * gamma(temp.a + temp.b - temp.c) /...
                        gamma(temp.a) * gamma(temp.b)];
                    obj.a      = [temp.a, temp.c - temp.a];
                    obj.b      = [temp.b, temp.c - temp.b];
                    obj.c      = [temp.a + temp.b - temp.c + 1, temp.c - temp.a - temp.b + 1];
                    obj.z      = [1 - temp.z, 1 - temp.z];
                else
                    % Should not get here.
                    error('Something in the control flow went wrong.');
                end
            end
        end
        % Numerical methods for approximating hypergeometric value
        function value = SingleFraction(obj)
            %SINGLEFRACTION Computes an approximation to the Gaussian Hypergeometric function by the Single
            % Fraction method
            %
            % Input:
            %   obj     The Hypergeometric object.
            %
            % Output:
            %   value   An approximation the the Gaussian Hypergeometric function.
            
            tolerance  = 10 ^ -15; % Stop iterative proccess when tolerance is reached.
            alphaValue = 0; % Initial alpha value.
            betaValue  = 1; % Initial beta value.
            gammaValue = 1; % Initial gamma value.
            zetaValue  = [1, 0, 0, 0]; % Initial zeta value.
            for iIteration = 1 : 3
                alphaValue                = (alphaValue + betaValue) * iIteration * (obj.c +...
                    iIteration - 1);
                betaValue                 = betaValue * (obj.a + iIteration - 1) * (...
                    obj.b + iIteration - 1) * obj.z;
                gammaValue                = gammaValue * iIteration * (obj.c +...
                    iIteration - 1);
                zetaValue(iIteration + 1) = (alphaValue + betaValue) / gammaValue;
            end
            iIteration = 4; % Already computed 3 iterations.
            while abs(zetaValue(4) - zetaValue(3)) / abs(zetaValue(3)) > tolerance ||...
                    abs(zetaValue(3) - zetaValue(2))/abs(zetaValue(2)) > tolerance ||...
                    abs(zetaValue(2) - zetaValue(1)) / abs(zetaValue(1)) > tolerance
                alphaValue   = (alphaValue + betaValue) * iIteration * (...
                    obj.c + iIteration - 1);
                betaValue    = betaValue * (obj.a + iIteration - 1) * (...
                    obj.b + iIteration - 1) * obj.z;
                gammaValue   = gammaValue * iIteration * (obj.c +...
                    iIteration - 1);
                zetaValue(1) = zetaValue(2);
                zetaValue(2) = zetaValue(3);
                zetaValue(3) = zetaValue(4);
                zetaValue(4) = (alphaValue + betaValue) / gammaValue;
                
                iIteration = iIteration + 1;
            end
            value = zetaValue(4);
        end
        
        
        function argumentValues = getArguments(obj)
            %GETARGUMENTS Retrieves the arguments of the Gaussian Hypergeometric (along with the multiplication scalar).
            %
            % Input:
            %   obj               The Hypergeometric object.
            %
            % Output:
            %   argumentValues    The arguments.
            argumentValues = struct(...
                "lambda", obj.lambda,...
                "a", obj.a,...
                "b", obj.b,...
                "c", obj.c,...
                "z", obj.z...
                );
        end
    end
end