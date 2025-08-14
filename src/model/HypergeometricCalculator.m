classdef HypergeometricCalculator < handle
    properties
        a
        b
        c
        z
        id string
    end
    properties (Access = private)
        logger Logger
    end
    methods
        function obj = HypergeometricCalculator(a, b, c, z, logger)
            arguments
                a
                b
                c
                z
                logger Logger
            end
            obj.a = a;
            obj.b = b;
            obj.c = c;
            obj.z = z;
            % Set id for the numerical procedure according to 'Numerical methods for the computation of the confluent
            % and Gauss hypergeometric functions' by John Pearson et al. (table 6).
            if (obj.a > 0) && (obj.b > 0) && (obj.c >= 0) && (obj.z >= 0)
                obj.id = "I(A)";
            elseif (obj.a > 0) && (obj.b > 0) && (obj.c >= 0) && (obj.z < 0)
                obj.id = "I(B)";
            elseif (obj.a < 0) && (obj.b < 0) && (obj.c >= 0)
                obj.id = "II";
            elseif (obj.a >= 0) && (obj.b >= 0) && (obj.c < 0)
                obj.id = "III";
            elseif (obj.a < 0) && (obj.b < 0) && (obj.c < 0)
                obj.id = "IV";
            elseif (obj.a < 0 || obj.b < 0) && (obj.c >= 0)
                obj.id = "V";
            elseif (obj.a < 0 || obj.b < 0) && (obj.c < 0)
                obj.id = "VI";
            else
                error('Unexpected parameter combination for the Hypergeometric calculator.')
            end
            % 
            obj.logger = logger;
        end
        function approximation = computeHypergeometric(obj)
        %COMPUTEHYPERGEOMETRIC Approximates the Gauss hypergeometric function, assumes |z| < 1 / 2
        %
        % Input:
        %   obj              The HypergeometricCalculator object.
        %
        % Output:
        %   approximation    The approximated value.

            % The computational procedures depend on the parameter case.
            switch obj.id

                % Parameter case I(A).
                case "I(A)"
                    approximation = obj.computeCaseIA();

                % Parameter case I(B).
                case "I(B)"
                    approximation = obj.computeCaseIB();
                
                % Parameter case II.
                case "II"
                    approximation = obj.computeCaseII();

                % Parameter case III.
                case "III"
                    approximation = obj.computeCaseIII();

                otherwise
                % Should not get here.
                error('Invalid object id.')
            end
        end
    end
    methods (Access = protected)

        % Computational procedures for parameter case III.
        function approximation = computeCaseIII(obj)

            % Check if c is too big to apply direct method.
            if obj.c < -20


            else

            end
        end

        function approximation = computeByRecurrence00Plus(obj, type)

            if type = "forwards"
                approximation = obj.computeByRecurrence00PlusForwards();
            elseif

            else

            end
        end

        % Forwards computation to the Gaussian Hypergeometric function
        function approximation = computeByRecurrence00PlusForwards(obj)

            
            % function [rr] = hypfun_F_rec00plus_backward(a,b,c,z,n)
            % 
            % Computes the hypergeometric function \mathbf{F}(a,b;c-n;z), for n a large
            % positive integer, using \mathbf{F}(a,b;c;z), \mathbf{F}(a,b;c-1;z) and a
            % recurrence relation.
            % 
            % Copyright John W. Pearson 2014

            % Use initial data
            a1 = zeros(2,1);
            a1(1) = hypergeom([a,b],c,z);
            a1(2) = hypergeom([a,b],c-1,z);

            % Apply recurrence relation
            for j = 2:n
                a1(j+1)=(-(c+1-j)*(c-j-(2*c+1-2*j-a-b)*z)*a1(j)- ...
                    (c-a+1-j)*(c-b+1-j)*z*a1(j-1))/(c+1-j)/(c-j)/(z-1);
            end

            % Return solution
            rr = GammaCalculator.computeGammaFunction(obj.c) * a1(end)/GammaCalculator.computeGammaFunction(c-n);

        end
        % Computational procedures for parameter case II.
        function approximation = computeCaseII(obj)
        %COMPUTECASEII Computes the Gaussian Hypergeometric function for parameter case II.
        %
        % Input:
        %   obj    The HypergeometricCalculator object.
        %
        % Output:
        %   approximation    An approximation to the Gaussian Hypergeometric function.

            % Apply a transformation formula to reduce to case I.
            lambda            = (1 - obj.z) ^ (obj.c - obj.a - obj.b);
            aTransformed      = obj.c - obj.a;
            bTransformed      = obj.c - obj.b;

            % Create a new Hypergeometric object with the transformed parameters.
            hypergeometric = Hypergeometric(lambda, aTransformed, bTransformed, obj.c, obj.z, obj.logger);
            
            % Compute approximation with transformed parameters.
            approximation = hypergeometric.computeApproximation();
        end

        % Computational procedures for parameter case I(B).
        function approximation = computeCaseIB(obj)
            
            % Are b - a or c - a - b close to an integer?
            isCancellation = (abs(obj.b - obj.a) < 1e-12) || (abs(obj.c - obj.a - obj.b) < 1e-12);
            if isCancellation
                
                % Just log for now, no method is implemented to solve this problem as of yet.
                obj.logger.writeWarning("Cancelation problem. a: %d, b: %d, c: %d", obj.a, obj.b, obj.c);
            
            else
                % No need to log.
            end
            
            % Apply Taylor serie's method A.
            approximation = obj.computeByTaylorA();

            % No convergence.
            if isnan(approximation)
                            
                % Apply Single Fraction method.
                approximation = obj.computeBySingleFraction();

                % No convergence.
                if isnan(approximation)
                                
                    % Just log for now, no method is implemented to deal with this.
                    obj.logger.writeError("Did not expect no convergence.");
                            
                else
                    % Convergence.
                    return
                end
            
            else
                % Convergence.
                return

            end
        end

        % Computational procedures for parameter case I(A).
        function approximation = computeCaseIA(obj)
        %COMPUTECASEIA Computes the Gaussian Hypergeometric function for the parameter case I(A).
        %
        % Input:
        %   obj    The HypergeometricCalculator object.
        %
        % Output:
        %   approximation    An approximation to the Gaussian Hypergeometric function.

            % Apply Taylor serie's method A.
            approximation = obj.computeByTaylorA();

            % No convergence.
            if isnan(approximation)

                % Apply Single Fraction method.
                approximation = obj.computeBySingleFraction();

                % No convergence.
                if isnan(approximation)

                    % Apply Gauss Jacobi quadrature.
                    approximation = obj.computeByGaussJacobiQuadrature();
                else
                    % Convergence.
                    return
                end
            else
                % Convergence.
                return
            end
        end
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
            MAX_ITER = 500;

            % Log the method.
            obj.logger.writeInfo("About to initiate Taylor series method B")

            % Initialise vector r, which stores multipliers.
            r    = zeros(2 , 1);
            r(1) = (obj.a * obj.b) / obj.c;
            r(2) = ((obj.a + 1) * (obj.b + 1)) / 2 / (obj.c + 1);

            % Initialise vector A, which stores sum of first i + 1 terms.
            A    = zeros(2 , 1);
            A(1) = 1 + (obj.z * r(1));
            A(2) = A(1) + ((((obj.z ^ 2) * obj.a * obj.b) * r(2)) / obj.c);

            for iIdx = 3 : MAX_ITER
                % Compute current r(iIdx).
                r(iIdx) = ((obj.a + iIdx - 1) * (obj.b + iIdx - 1)) / iIdx / (obj.c + iIdx - 1);
                
                % Compute A(jTerm) recursively.
                A(iIdx) = A(iIdx - 1) + ((A(iIdx - 1) - A(iIdx - 2)) * r(iIdx) * obj.z);
                
                % If stopping criterion is satisfied, terminate summation.
                stoppingCriterion = (abs(A(iIdx) - A(iIdx - 1)) / abs(A(iIdx - 1)) < Constants.tolTaylorB) &&...
                    (abs(A(iIdx - 1) - A(iIdx - 2)) / abs(A(iIdx - 2)) < Constants.tolTaylorB);
                if stoppingCriterion
                    break
                
                % No convergence.
                elseif (iIdx == MAX_ITER)
                    approximation = NaN;
                    obj.logger.writeWarning("No convergence achieved for parameter case %s with Taylor series method B",...
                        obj.id);
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
            MAX_ITER = 500;

            % Log the method.
            obj.logger.writeInfo("About to start Taylor series method A.")

            % Assign alias for GammaCalculator.
            gc = GammaCalculator();

            % Care if c is a non-positive integer.
            isNonPositiveInteger = (abs(obj.c - fix(obj.c)) < 1e-12) && (obj.c <= 0);
            if isNonPositiveInteger
                taylorTerm = (gc.computeGammaFunction(obj.a - obj.c + 1) * gc.computeGammaFunction(obj.b - obj.c + 1) *...
                (obj.z ^ (-obj.c + 1))) / gc.computeGammaFunction(obj.a)  / gc.computeGammaFunction(obj.b) /...
                gc.computeGammaFunction(-obj.c + 2);
                taylorSum  = taylorTerm;
                
                for iIdx = 1 : MAX_ITER
                    taylorTerm = ((obj.a - obj.c + iIdx) * (obj.b - obj.c + iIdx) * obj.z * a1) / iIdx /...
                    (iIdx - obj.c + 1) ;
                    taylorSum  = taylorSum + taylorTerm;
                    
                    % Check if stopping criterion is satisfied.
                    stoppingCriterion = (abs(taylorTerm) / abs(taylorSum)) < Constants.tolTaylorA;
                    if stoppingCriterion
                        break
                    
                    % No convergence
                    elseif iIdx == MAX_ITER
                        approximation = NaN;
                        obj.logger.writeWarning(...
                        "No convergence achieved for parameter case %s with Taylor series method A", obj.id);
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
                        approximation = NaN;
                        obj.logger.writeWarning(...
                        "No convergence achieved for parameter case %s, with Taylor series method A", obj.id);
                        return
                    else
                        % Keep computing.
                    end
                end
                % If convergence achieved, return sum of terms computed
                approximation = taylorSum;
            end
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
            
            % Log the method.
            obj.logger.writeInfo("About to start Single Fraction method.")

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
                    approximation = NaN;
                    obj.logger.writeWarning(...
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
                    obj.logger.writeWarning(...
                    "No convergence achieved for parameter case %s with Single Fraction method.", obj.id);
                    return
                end
            end

            % If convergence achieved, return sum of terms computed
            approximation = SSequence(end);
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
            approximation = GammaCalculator.computeGammaFunction(obj.c) *...
            (sum(weights .* ((1 - ((obj.z  * (nodes + 1)) / 2)) .^ (-obj.a))) /...
            GammaCalculator.computeGammaFunction(obj.b) /...
            GammaCalculator.computeGammaFunction(obj.c - obj.b) /...
            (2 ^ (obj.c - 1)));
        end
    end
end