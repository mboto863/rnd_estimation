classdef Hypergeometric
    properties
        lambda (1, 1) double
        a (1, 1) double
        b (1, 1) double
        c (1, 1) double
        z (1, 1) double
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
            obj.a = a;
            obj.b = b;
            obj.c = c;
            obj.z = z;
        end
        function approximate(obj)
            
        end
    end
    methods (Access = private)

        % Transformation formulae
        function obj = normalizez(obj)
            if (0 <= obj.z) && (obj.z <= 1 / 2)
                return
            elseif obj.z < -1
                temp = obj.getParameters();
                obj.lambda = [...
                    (1 - temp.z) ^ -temp.a *...
                    gamma(temp.c) * gamma(temp.b - temp.a) /...
                    gamma(temp.b) / gamma(temp.c - temp.a)...
                    ,...
                    (1 - temp.z) ^ -temp.b *...
                    gamma(temp.c) * gamma(temp.a - temp.b) /...
                    gamma(temp.a) / gamma(temp.c - temp.b)...
                    ];
                obj.a = [temp.a, temp.b];                
                obj.b = [temp.c - temp.b, temp.c - temp.a];
                obj.c = [temp.a - temp.b + 1, temp.b - temp.a + 1];
                obj.z = [1 / (1 - temp.z), 1 / (1 - temp.z)];
            elseif obj.z < 0
                temp = obj.getParameters();
                obj.lambda = (1 - temp.z) ^ -temp.a;
                % a stays the same
                obj.b = temp.c - temp.b;
                % c stays the same
                obj.z = temp.z / (temp.z - 1);
            elseif obj.z > 2
                temp = obj.getParameters();
                obj.lambda = [((-temp.z) ^ -temp.a) *...
                    gamma(temp.c) * gamma(temp.b - temp.a)/...
                    gamma(temp.b) / gamma(temp.c - temp.a)...
                    ,...
                    ((-temp.z) ^ -temp.b) *...
                    gamma(temp.c) * gamma(temp.a - temp.b)/...
                    gamma(temp.a) / gamma(temp.c - temp.b)];
                obj.a = [temp.a, temp.b - temp.c + 1];
                obj.b = [temp.a - temp.c + 1, temp.b, temp.b];
                obj.c = [temp.a - temp.b + 1, temp.b - temp.a + 1];
                obj.z = [1 / temp.z, 1 / temp.z];
            elseif obj.z > 1
                temp = obj.getParameters();
                obj.lambda = [temp.z ^ -temp.a *...
                    gamma(temp.c) * gamma(temp.c - temp.a - temp.b) /...
                    gamma(temp.c - temp.a) / gamma(temp.c - temp.b)...
                    ,...
                    temp.z ^ (temp.a - temp.c) *...
                    (1 - temp.z) ^ (temp.c - temp.a - temp.b) *...
                    gamma(temp.c) * gamma(temp.a + temp.b - temp.c) /...
                    gamma(temp.a) / gamma(temp.b)];
                obj.a = [temp.a,...
                    temp.c - temp.a];
                obj.b = [temp.a - temp.c + 1,...
                    1 - temp.a];
                obj.c = [temp.a + temp.b - temp.c + 1,...
                    temp.c - temp.a - temp.b + 1];
                temp.z = [1 - 1 / temp.z,...
                    1 - 1 / temp.z];
            elseif obj.z > 1 / 2
                temp = obj.getParameters();
                obj.lambda = [gamma(temp.c) * gamma(temp.c - temp.a - temp.b) /...
                    gamma(temp.c - temp.a) / gamma(temp.c - temp.b)...
                    ,...
                    (1 - temp.z) ^ (temp.c - temp.a - temp.b) *...
                    gamma(temp.c) * gamma(temp.a + temp.b - temp.c) /...
                    gamma(temp.a) * gamma(temp.b)];
                obj.a = [temp.a, temp.c - temp.a];
                obj.b = [temp.b, temp.c - temp.b];
                obj.c = [temp.a + temp.b - temp.c + 1, temp.c - temp.a - temp.b + 1];
                obj.z = [1 - temp.z, 1 - temp.z]; 
            end
        end

        % Numerical methods
        function value = SingleFraction(obj)
            tolerance = 10 ^ -15;
            alphaValue = 0;
            betaValue = 1;
            gammaValue = 1;
            %zetaValue = [zetaValue(j-2), zetaValue(j-1), zetaValue(j), zetaValue(j+1)]
            zetaValue = [1, 0, 0, 0];
            for iIteration = 1 : 3
                alphaValue = (alphaValue + betaValue) * iIteration * (ojb.c +...
                    iIteration - 1);
                betaValue = betaValue * (obj.a + iIteration - 1) * (...
                    obj.b + iIteration - 1) * obj.z;
                gammaValue = gammaValue * iIteration * (obj.c +...
                    iIteration - 1);
                zetaValue(iIteration + 1) = (alphaValue + betaValue) / gammaValue;
            end
            iIteration = 4;
            while abs(zetaValue(4) - zetaValue(3)) / abs(zetaValue(3)) > tolerance ||...
                    abs(zetaValue(3) - zetaValue(2))/abs(zetaValue(2)) > tolerance ||...
                    abs(zetaValue(2) - zetaValue(1)) / abs(zetaValue(1)) > tolerance
                alphaValue = (alphaValue + betaValue) * iIteration * (...
                    obj.c + iIteration - 1);
                betaValue = betaValue * (obj.a + iIteration - 1) * (...
                    obj.b + iIteration - 1) * obj.z;
                gammaValue = gammaValue * iIteration * (obj.c +...
                    iIteration - 1);
                zetaValue(1) = zetaValue(2);
                zetaValue(2) = zetaValue(3);
                zetaValue(3) = zetaValue(4);
                zetaValue(4) = (alphaValue + betaValue) / gammaValue;
                iIteration = iIteration + 1;
            end
            value = zetaValue(4);          
        end

        function parameters = getParameters(obj)
            parameters = struct(...
                "lambda", obj.lambda,...
                "a", obj.a,...
                "b", obj.b,...
                "c", obj.c,...
                "z", obj.z...
                );
        end
    end
end