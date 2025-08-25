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
                    methodOutput = obj.computeByTaylorA();
                    % No convergence from the Taylor series method A.
                    if isnan(methodOutput)
                        methodOutput = obj.computeBySingleFraction();

                        % No convergence from the Single Fraction method.
                        if isnan(methodOutput)
                            approximation = obj.lambda * obj.computeByGaussJacobiQuadrature(16);
                        
                        % Convergence.
                        else
                            approximation = obj.lambda * methodOutput;
                        end

                    % Convergence
                    else
                        approximation = obj.lambda * methodOutput;
                    end
                end
            end
        end
    end
    methods
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
                    obj.lambda = temp.lambda .* [...
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
                    obj.lambda = temp.lambda * (1 - temp.z) ^ (-temp.a);
                    % a stays the same
                    obj.b = temp.c - temp.b;
                    % c stays the same
                    obj.z = temp.z / (temp.z - 1);
                elseif temp.z > 2
                    obj.lambda = temp.lambda * [((-temp.z) ^ -temp.a) *...
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
                    obj.lambda = temp.lambda * [((temp.z ^ (-temp.a)) *...
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
                elseif temp.z > 0.5
                    obj.lambda = temp.lambda * [...
                        (gamma(temp.c) * gamma(temp.c - temp.a - temp.b)) /...
                        (gamma(temp.c - temp.a) * gamma(temp.c - temp.b)),...
                        (((1 - temp.z) ^ (temp.c - temp.a - temp.b)) *...
                        gamma(temp.c) * gamma(temp.a + temp.b - temp.c)) /...
                        (gamma(temp.a) * gamma(temp.b))];
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
        function approximation = computeByGaussJacobiQuadrature(obj, nPoints)
        %COMPUTEBYGAUSSJACOBIQUADRATURE Computes the Gaussian Hypergeometric function by the Gauss Jacobi
        % Quadrature method.
        %
        % Input:
        %   obj              The HypergeometricCalculator object.
        %   nPoints          The number of points to use for the quadrature.
        %
        % Output:
        %   approximation    An approximation to the Gaussian Hypergeometric function.
            
            % Compute Gauss-Jacobi quadrature nodes and weights.
            [nodes ,weights] = GaussJacobiQuadrature.computeNodesWeights(obj.c - obj.b - 1,obj.b - 1, nPoints);
            
            % Compute the Hypergeometric function using its integral representation.
            approximation = gamma(obj.c) *...
                (sum(weights .* ((1 - ((obj.z  * (nodes + 1)) / 2)) .^ (-obj.a))) /...
                gamma(obj.b) /...
                gamma(obj.c - obj.b) /...
                (2 ^ (obj.c - 1)));
        end
        function approximation = computeBySingleFraction(obj)
        %COMPUTEBYSINGLEFRACTION Computes the Gaussian Hypergeometric function up to a tol using the Single Fraction
        % method.
        %
        % Input:
        %   obj              The HypergeometricCalculator object.
        %
        % Output:
        %   approximation    An approximation to the Gaussian Hypergeometric function.
        
        % Assign maximum number of iterations.
            MAX_ITER = 500;
            
            % Initialise sequences.
            alphaSequence = [0, obj.c];
            betaSequence  = [1, obj.a * obj.b * obj.z];
            gammaSequence = [1, obj.c];
            SSequence     = [1, (obj.c + obj.a * obj.b * obj.z) / obj.c];
            
            for iIdx = 3 : MAX_ITER
                % Compute next values of alphaSequence(iIdx), betaSequence(iIdx), gammaSequence(iIdx) recursively
                alphaSequence(iIdx) = (alphaSequence(iIdx - 1) +...
                    betaSequence(iIdx - 1)) * (iIdx - 1) * (obj.c + iIdx - 2);
                betaSequence(iIdx)  = betaSequence(iIdx - 1) * (obj.a + iIdx - 2) * (obj.b + iIdx - 2) * obj.z;
                gammaSequence(iIdx) = gammaSequence(iIdx - 1) * (iIdx - 1) * (obj.c + iIdx - 2);
                
                % Stop if any of these are infinitely large
                isSequenceInf = isinf(alphaSequence(iIdx)) || isinf(betaSequence(iIdx)) || isinf(gammaSequence(iIdx));
                if isSequenceInf

                    % Return NaN to let the interface know there was no convergence.
                    approximation = NaN;

                    % Log this failure.
                    logger = PersistentLogger.getInstance();
                    logger.writeWarning(...
                        "Infinite values reached for one of 'alphaSequence':%d, 'betaSequence: %d, gammaSequence: %d at iteration %d",...
                        alphaSequence(iIdx), betaSequence(iIdx), gammaSequence(iIdx), iIdx);
                    return
                end
                
                % Compute next term in SSequence(iIdx)
                SSequence(iIdx) = (alphaSequence(iIdx) + betaSequence(iIdx)) / gammaSequence(iIdx);
                
                % Check if stopping criterion is satisfied.
                stoppingCriterion =...
                    (abs(SSequence(iIdx) - SSequence(iIdx - 1)) / abs(SSequence(iIdx - 1)) < Constants.tolSingleFraction) &&...
                    (abs(SSequence(iIdx - 1) - SSequence(iIdx - 2)) / abs(SSequence(iIdx - 2)) <...
                    Constants.tolSingleFraction);
                if stoppingCriterion
                    break
                end
                
                % No convergence
                if (iIdx == MAX_ITER)
                    approximation = NaN;
                    logger = PersistentLogger.getInstance();
                    logger.writeWarning(...
                        "No convergence achieved for parameter case %s with Single Fraction method.", obj.id);
                    return
                end
            end
            
            % If convergence achieved, return sum of terms computed
            approximation = SSequence(end);
        end
        % Numerical methods for approximating hypergeometric value
        function approximation = computeByTaylorA(obj)
            %COMPUTEBYTAYLORA Computes the hypergeometric function using Taylor series method A up to a tolerance.
            %
            % Input:
            %   obj              The HypergeometricCalculator object.
            %
            % Output:
            %   approximation    An approximation to the hypergeometric function.
            
            % Compute only 500 terms.
            MAX_ITER = 500;
            
            % % Assign alias for GammaCalculator.
            % gc = GammaCalculator();
            
            % Care if c is a non-positive integer.
            isNonPositiveInteger = (abs(obj.c - fix(obj.c)) < 1e-12) && (obj.c <= 0);
            if isNonPositiveInteger
                taylorTerm = (gamma(obj.a - obj.c + 1) * gamma(obj.b - obj.c + 1) *...
                    (obj.z ^ (-obj.c + 1))) / gamma(obj.a)  / gamma(obj.b) /...
                    gamma(-obj.c + 2);
                taylorSum  = taylorTerm;
                
                for iIdx = 1 : MAX_ITER
                    taylorTerm = ((obj.a - obj.c + iIdx) * (obj.b - obj.c + iIdx) * obj.z * taylorTerm) / iIdx /...
                        (iIdx - obj.c + 1) ;
                    taylorSum  = taylorSum + taylorTerm;
                    
                    % Check if stopping criterion is satisfied.
                    stoppingCriterion = (abs(taylorTerm) / abs(taylorSum)) < Constants.tolTaylorA;
                    if stoppingCriterion
                        break
                        
                        % No convergence
                    elseif iIdx == MAX_ITER
                        approximation = NaN;
                        
                        % Get logger.
                        logger = PersistentLogger.getInstance();
                        
                        % Log a warning.
                        logger.writeWarning(...
                            "No convergence achieved with Taylor series method A");
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
                
                for iIdx = 1 : MAX_ITER
                    % Compute next term
                    taylorTerm = ((obj.a + iIdx - 1) * (obj.b + iIdx - 1) * obj.z * taylorTerm) / (obj.c + iIdx - 1) /...
                        iIdx;
                    
                    % Update the sum of computed terms
                    taylorSum  = taylorSum + taylorTerm;
                    
                    % Check if stopping criterion is satisfied.
                    stoppingCriterion = (abs(taylorTerm) / abs(taylorSum)) < Constants.tolTaylorA;
                    if stoppingCriterion
                        break
                        % No convergence.
                    elseif (iIdx == MAX_ITER)
                        approximation = Inf;
                        
                        % Get logger instance.
                        logger = PersistentLogger.getInstance();
                        
                        % Log warning.
                        logger.writeWarning(...
                            "No convergence achieved for parameter case %s, with Taylor series method A");
                        return
                    else
                        % Keep computing.
                    end
                end
                % If convergence achieved, return sum of terms computed
                approximation = taylorSum;
            end
        end
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