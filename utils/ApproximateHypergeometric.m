classdef ApproximateHypergeometric
    properties
        lambda (1, 1) double
        a (1, 1) double
        b (1, 1) double
        c (1, 1) double
        z (1, 1) double
    end
    methods
        function obj = ApproximateHypergeometric(lambda, a, b, c, z)
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
    end
    methods (Access = private)
        function obj = normalizez(obj)
            if (0 <= obj.z) && (obj.z <= 1 / 2)
                % check if this is correct syntax
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
                obj.lambda = [...
                    ((-temp.z) ^ -temp.a) *...
                    gamma(temp.c) * gamma(temp.b - temp.a)/...
                    gamma(temp.b) / gamma(temp.c - temp.a)...
                    ,...
                    ((-temp.z) ^ -temp.b) *...
                    gamma(temp.c) * gamma(temp.a - temp.b)/...
                    gamma(temp.a) / gamma(temp.c - temp.b)...
                    ];

            end
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