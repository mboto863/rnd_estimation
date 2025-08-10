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

            switch obj.id
                case "I(A)"
                    approximation = obj.computeByTaylorA();
                    if isnan(approximation)
                        
                    end
            end
        end
    end
    methods (Access = protected)
        function approximation = computeByTaylorB(obj)
        %COMPUTEBYTAYLORB Computes the hypergeometric function using Taylor series method B up to a tolerance. The
        % nomenclature is as in Pearson.
        %
        % Input:
        %   obj              The HypergeometricCalculator object.
        %
        % Output:
        %   approximation    The approximation.

            % Compute only 500 terms.
            N_TERMS = 500;

            % Initialise vector r, which stores multipliers.
            r    = zeros(2 , 1);
            r(1) = obj.a * obj.b / obj.c;
            r(2) = (obj.a + 1) * (obj.b + 1) / 2 / (obj.c + 1);

            % Initialise vector A, which stores sum of first i + 1 terms.
            A    = zeros(2 , 1);
            A(1) = 1 + obj.z * r(1);
            A(2) = A(1) + obj.z ^ 2 * obj.a * obj.b / obj.c * r(2);

            for iIdx = 3 : N_TERMS
                % Compute current r(iIdx).
                r(iIdx) = (obj.a + iIdx - 1) * (obj.b + iIdx - 1) / iIdx / (obj.c + iIdx - 1);
                
                % Compute A(jTerm) recursively.
                A(iIdx) = A(iIdx - 1) + (A(iIdx - 1) - A(iIdx - 2)) * r(iIdx) * obj.z;
                
                % If stopping criterion is satisfied, terminate summation.
                if abs(A(iIdx) - A(iIdx - 1)) / abs(A(iIdx - 1)) < Constants.tolTaylorB &&...
                    abs(A(iIdx - 1) - A(iIdx - 2)) / abs(A(iIdx - 2)) < Constants.tolTaylorB
                    break
                % No convergence.
                elseif (iIdx == N_TERMS)
                    [' ' num2str(iIdx) ' terms computed']
                    approximation = NaN;
                    return
                else
                    % Keep computing.
                end
            end
            % If convergence is achieved, return sum of terms computed.
            approximation = A(end) / GammaCalculator.computeGammaFunction(obj.z);
        end
        function approximation = computeByTaylorA(obj)
            %COMPUTEBYTAYLORA Computes the hypergeometric function using Taylor series method A up to a tolerance.
            %
            % Input:
            %   obj              The HypergeometricCalculator object.
            %
            % Output:
            %   approximation    An approximation to the hypergeometric function.

            % Compute only 500 terms.
            N_TERMS = 500;

            % Assign alias for GammaCalculator.
            gc = GammaCalculator();

            % Care if c is a non-positive integer.
            if (obj.c == fix(obj.c) && obj.c <= 0)
                taylorTerm = gc.computeGammaFunction(obj.a - obj.c + 1) / gc.computeGammaFunction(obj.a) *...
                gc.computeGammaFunction(obj.b - obj.c + 1) / gc.computeGammaFunction(obj.b) /...
                gc.computeGammaFunction(-obj.c + 2) * obj.z ^ (-obj.c + 1);
                taylorSum  = taylorTerm;
                
                for iIdx = 1 : N_TERMS
                    taylorTerm = (obj.a - obj.c + iIdx) * (obj.b - obj.c + iIdx) / iIdx * obj.z / (iIdx - obj.c + 1) * a1;
                    taylorSum  = taylorSum + taylorTerm;
                    
                    % Apply stopping criterion
                    if abs(taylorTerm) / abs(taylorSum) < Constants.tolTaylorA
                        break
                    % No convergence
                    elseif (iIdx == N_TERMS)
                        [' ' num2str(iIdx) ' terms computed']
                        return
                    else
                        % Keep computing.
                    end
                end
                
                approximation = taylorSum;
            else
                % Initialise relevant quantities
                taylorTerm = 1;
                taylorSum  = 1;

                for iIdx = 1 : N_TERMS
                    % Compute next term
                    taylorTerm = (obj.a + iIdx - 1) * (obj.b + iIdx - 1) / (obj.c + iIdx - 1) * obj.z / iIdx *...
                    taylorTerm;
                    taylorSum  = taylorSum + taylorTerm;
                    % Update the sum of computed terms
                    if abs(taylorTerm) / abs(taylorSum) < Constants.tolTaylorA
                        break
                    % Apply stopping criterion
                    elseif (iIdx == N_TERMS)
                        [' ' num2str(iIdx) ' terms computed']
                        return
                    else
                        % Keep computing.
                    end
                end
                % If convergence achieved, return sum of terms computed
                approximation = taylorSum / gc.computeGammaFunction(obj.c);
            end 
        end
    end
end