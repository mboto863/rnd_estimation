classdef HypergeometricCalculator < handle
    properties
        a
        b
        c
        z
        id string
    end
    methods
        %%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%
        % function approximation = publicOlver(obj)
        %     approximation = obj.computeByRecurrenceByOlver();
        % end
        % function approximation = publicRecurrence(obj)
        %     approximation = obj.computeByRecurrence();
        % end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = HypergeometricCalculator(a, b, c, z)
            arguments
                a
                b
                c
                z
            end
            if z >= (1 / 2)
                error('z is not normalized');
            else
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
            end
        end
        function approximation = computeApproximation(obj)
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
                    
                    % Parameter case IV.
                case "IV"
                    approximation = obj.computeCaseIV();
                    
                    % Parameter case V
                case "V"
                    approximation = obj.computeCaseV();
                    
                    % Parameter case VI
                case "VI"
                    approximation = obj.computeCaseVITest();
                otherwise
                    % Should not get here.
                    error('Invalid object id.')
            end
        end
    end
    methods (Access = protected)
        function approximation = computeCaseIV(obj)
            % Apply a transformation formula to reduce to another parameter case.
            aTransformed      = obj.c - obj.a;
            bTransformed      = obj.c - obj.b;

            approximation = ((1 - obj.z) ^ (obj.c - obj.a - obj.b)) *...
                hypergeom([aTransformed, bTransformed], obj.c, obj.z);

        end
        % function approximation = computeByRecurrenceRelation00PlusByMiller(obj, N)
        %     % function [r] = hypfun_F_rec00plus_miller(a,b,c,z,n,k)
        %     % 
        %     % Computes the hypergeometric function \mathbf{F}(a,b;c+k;z), for k a large
        %     % positive integer, using \mathbf{F}(a,b;c;z) and Miller's algorithm, with
        %     % n a number much larger than k. Note that Re(z) must be < 1/2.
        %     % 
        %     % Copyright John W. Pearson 2014

        %     % We try to get c close to 0.3, which seems to provide the best results according to Pearson et al.(2017).
        %     OPTIMUM_C = 0.3;
            
        %     % Number of terms to be involved in the forwards computation.
        %     nTerms = int32(fix(obj.c - OPTIMUM_C));
            
        %     % The reduced c parameter.
        %     reducedc = double(obj.c - nTerms);

        %     % Initialise vectors in Miller's algorithm.
        %     fVector             = zeros(nTerms + 1, 1);
        %     yVector = zeros(N + 1, 1);
        %     aVector             = zeros(N - 1, 1);
        %     bVector             = zeros(N - 1, 1);

        %     % Define coefficients in recurrence relation
        %     for iIdx = 1 : (N - 1)
        %         aVector(iIdx) = ((reducedc + iIdx) * (reducedc + iIdx - 1) * (obj.z - 1)) /...
        %         (reducedc + iIdx - obj.a) / (reducedc + iIdx - obj.b)/ obj.z;
        %         bVector(iIdx) = (reducedc + iIdx) *...
        %         (reducedc + iIdx - 1 - ((2 * (reducedc + iIdx)) - obj.a - obj.b - 1) * obj.z) /...
        %         (reducedc + iIdx - obj.a) / (reducedc + iIdx - obj.b) / obj.z;
        %     end

        %     % Input minimal solution with k=0
        %     fReducedSolutionHypergeometric = Hypergeometric(obj.a, obj.b, reducedc, obj.z);
        %     fReducedSolution = fReducedSolutionHypergeometric.computeApproximation();

        %     yVector(end) = 0;
        %     yVector(end-1) = 1;

        %     % Compute recurrence backwards
        %     for i2 = 2:n
        %         rightHandSideVector(n+1-i2) = -(rightHandSideVector(n+3-i2)+b1(n+1-i2)*rightHandSideVector(n+2-i2))/a1(n+1-i2);
        %     end

        %     % Apply last line of Miller's algorithm
        %     for i3 = 1:k+1
        %         f(i3) = f1/rightHandSideVector(1)*rightHandSideVector(i3);
        %     end

        %     % Return solution
        %     r = f(end);

        % end
        % Computational procedures for parameter case VI.
        function approximation = computeCaseVITest(obj)
            approximation = hypergeom([obj.a, obj.b], obj.c, obj.z);
        end
        function approximation = computeCaseVI(obj)
            
            % Check if c is too big to apply direct method.
            if obj.c < -20
                
                approximation = hypergeom([obj.a, obj.b], obj.c, obj.z);
            else
                
                % Apply taylor series method.
                approximation = obj.computeByTaylorA();
                
                % No convergence from taylor series method.
                if isnan(approximation)
                    
                    % Apply single fraction method.
                    approximation = obj.computeBySingleFraction();
                    
                    % No convergence from single fraction method.
                    if isnan(approximation)
                        
                        % Get logger
                        logger = PersistentLogger.getInstance();
                        
                        % Log this failure.
                        logger.writeError("Case VI: Did not expect lack of convergence.")
                        
                        % Convergence from single fraction method.
                    else
                        return
                        
                    end
                else
                    % Convergence from taylor series method.
                    return
                    
                end
            end
        end
        % Computational procedures for parameter case V.
        function approximation = computeCaseV(obj)
            
            % Check if c is too big to apply direct method.
            if obj.c >= 30
                approximation = hypergeom([obj.a, obj.b], obj.c, obj.z);
                % % Reduce to another parameter case through recurrence relation.
                % approximation = obj.computeByRecurrenceInterface("forwards");
                
            else
                
                % Apply Taylor series method A.
                approximation = obj.computeByTaylorA();
                
                % No convergence from Taylor series method A.
                if isnan(approximation)
                    
                    % Apply Single Fraction method.
                    approximation = obj.computeBySingleFraction();
                    
                    % No convergence from the Single Fraction method.
                    if isnan(approximation)
                        
                        % Get logger.
                        logger = PersistentLogger.getInstance();
                        
                        % Log this failure.
                        logger.writeWarning("Case V: lack of convergence. Using built-in functionality")


                        % Use built-in hypergeom.
                        approximation = hypergeom([obj.a, obj.b], obj.c, obj.z);
                    else
                        % Convergence from single fraction method.
                        return
                        
                    end
                    
                else
                    % Convergence from taylor series method
                    return
                    
                end
            end
        end
        
        % Computational procedures for parameter case III.
        function approximation = computeCaseIII(obj)
            
            % Check if c is too big to apply direct method.
            % if obj.c < -20
                
            %     % Reduce to another parameter case through recurrence relation.
            %     approximation = obj.computeByRecurrenceInterface("backwards");
                
            % else
                
            %     % Apply Taylor series method A.
            %     approximation = obj.computeByTaylorA();
                
            %     % No convergence from Taylor series method A.
            %     if isnan(approximation)
                    
            %         % Apply Single Fraction method.
            %         approximation = obj.computeBySingleFraction();
                    
            %         % No convergence from Single Fraction method.
            %         if isnan(approximation)
            %             % Get the logger instance.
            %             logger = PersistentLogger.getInstance();
                        
            %             % Log the error.
            %             logger.writeError("Case III: Did not expect lack of convergence.");
                        
            %         else
            %             % Convergence.
            %             return
                        
            %         end
            %     else
            %         % Convergence.
            %         return
                    
            %     end
            % end
            approximation = hypergeom([obj.a, obj.b], obj.c, obj.z);
        end
        function approximation = computeByRecurrenceInterface(obj, shift)
            
            % Reduce to a c positively shifted.
            if shift == "backwards"
                
                % Compute the solution to the recurrence relation by backwards computation.
                approximation = obj.computeByRecurrence();
                
                % Reduce to a c negatively shifted.
            elseif shift == "forwards"
                
                % Compute the solution to the recurrence relation by forwards computation.
                approximation = obj.computeByRecurrenceByOlver();
                
            else
                % Should not get here.
                
            end
        end
        
        % Forwards computation of the Hypergeometric function.
        function approximation = computeByRecurrenceByOlver(obj)
            %COMPUTEBYRECURRENCE00PLUSFORWARDSBYOLVER Reduces the computation of the Hypergeometric function to a parameter
            % case with c close to 0.3, by applying the recurrence 00plus, propagating it forwards with Olver's algorithm.
            %
            % Input:
            %   obj              The HypergeometricCalculator object.
            %
            % Output:
            %   approximation    An approximation to the Hypergeometric function.
            
            %function [h] = hypfun_F_rec00plus_olver(a,b,c,z,k)
            %
            % Computes the hypergeometric function \mathbf{F}(a,b;c+k;z), for k a large
            % positive integer, using \mathbf{F}(a,b;c;z) and Olver's algorithm. Note
            % that Re(z) must be < 1/2.
            
            % Set tolerance
            TOL = eps;
            
            % Set maximum number of iterations.
            MAX_ITER = 1000;
            
            % We try to get c close to 0.3, which seems to provide the best results according to Pearson et al.(2017).
            OPTIMUM_C = 0.3;
            
            % Number of terms to shift.
            nTerms = int32(fix(obj.c - OPTIMUM_C));
            
            % The reduced c parameter.
            reducedc = double(obj.c - nTerms);
            
            
            % Preallocate p.
            p = zeros(1, MAX_ITER + 1);
            
            % p is a variable used to determine the optimum value of N.
            p(1) = 1;
            p(2) = -(reducedc + 1) *...
                (reducedc + (((-2 * (reducedc + 1)) + obj.a + obj.b + 1) * obj.z)) /...
                ((reducedc - obj.a + 1) *...
                (reducedc - obj.b + 1) *...
                obj.z);
            
            % Reduced parameter case.
            fZeroHypergeometric = Hypergeometric(1, obj.a, obj.b, reducedc, obj.z);
            
            % Compute hypergeometric.
            fZero = fZeroHypergeometric.computeApproximation();
            
            % r is a variable used to determine the optimum value of N.
            r = [reducedc * (reducedc + 1) * (obj.z - 1) * fZero /...
                ((reducedc - obj.a + 1) * (reducedc - obj.b + 1) * obj.z),...
                reducedc * ((reducedc + 1) ^ 2) * (reducedc + 2) * ((obj.z - 1) ^ 2) * fZero /...
                ((reducedc - obj.a + 1) * (reducedc - obj.a + 2) * (reducedc - obj.b + 1) * (reducedc - obj.b + 2) *...
                (obj.z ^ 2))];
            
            % Maximum value of the p sequence so far. Initiate with some temporary value.
            maximump = 0;
            
            for iTerm = 2 : MAX_ITER
                
                % Compute next p term.
                p(iTerm + 1) =...
                    (-(reducedc + iTerm) *...
                    (reducedc + iTerm - 1) *...
                    (obj.z - 1) *...
                    p(iTerm - 1) /...
                    ((reducedc - obj.a + iTerm) * (reducedc - obj.b + iTerm) * obj.z)) -...
                    ((reducedc + iTerm) *...
                    (reducedc + iTerm - 1 - (((2 * (reducedc + iTerm)) - obj.a - obj.b - 1) * obj.z)) *...
                    p(iTerm) /...
                    ((reducedc - obj.a + iTerm) * (reducedc - obj.b + iTerm) * obj.z));
                
                % Compute next r term.
                r(iTerm + 1) =...
                    (reducedc + iTerm) *...
                    (reducedc + iTerm + 1) *...
                    (obj.z - 1) *...
                    r(iTerm) /...
                    ((reducedc - obj.a + iTerm + 1) * (reducedc - obj.b + iTerm + 1) * obj.z);
                
                % Update maximump.
                maximump = max(maximump, abs(p(iTerm - 1)));
                
                % Condition tells if it is to break early.
                stoppingCondition = (abs(r(iTerm) / (p(iTerm) * p(iTerm + 1))) * maximump) < TOL;
                if stoppingCondition
                    % Break for loop.
                    break
                    
                else
                    % Keep iterating.
                    
                end
            end
            
            % The term at which convergence took place.
            N = iTerm;
            
            % Method cannot be applied
            if nTerms >= N
                
                % Get a logger instance.
                logger = PersistentLogger.getInstance();
                
                % Log this failure.
                logger.writeWarning("Recurrence 00plus forward propagation by Olver's algorithm will not work because %d is greater than or equal to %d",...
                    nTerms, N);
                %%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                logger.writeDebug("Olver failure with parameters a: %d, b: %d, c: %d, z: %d",...
                    obj.a, obj.b, obj.c, obj.z);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Return NaN to let the interface know the method cannot be applied.
                approximation = hypergeom([obj.a, obj.b], obj.c, obj.z);
                return
                
            end
            %%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%
            logger = PersistentLogger.getInstance();
            logger.writeDebug("inspect N: %d class %s, nTerms: %d class %s", N, class(N), nTerms, class(nTerms));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Apply back substitution
            f = zeros(N - 1, 1);
            f(N - 1) = r(N - 1) / p(N);
            for iTerm = (N - 2) : -1 : nTerms
                f(iTerm) = (r(iTerm) + (p(iTerm) * f(iTerm + 1))) / p(iTerm + 1);
            end
            
            % Return solution
            approximation = f(nTerms);
        end
        % Backwards computation to the Gaussian Hypergeometric function
        function approximation = computeByRecurrence(obj)
            %COMPUTEBYRECURRENCE00PLUSBACKWARDS Reduces the computation of the Hypergeometric function to a parameter case
            % with c close to 0.3.
            %
            % Input:
            %   obj    The HypergeometricCalculator object.
            %
            % Output:
            %   approximation    An approximation to the Hypergeometric function.
            
            % function [rr] = hypfun_F_rec00plus_backward(a,b,c,z,n)
            %
            % Computes the hypergeometric function \mathbf{F}(a,b;c-n;z), for n a large
            % positive integer, using \mathbf{F}(a,b;c;z), \mathbf{F}(a,b;c-1;z) and a
            % recurrence relation.
            
            % Number of terms to shift.
            % We try to get c close to 0.3, which seems to provide the best results according to Pearson et al. (2017).
            
            % Reduce to a nice parameter case.
            % When b is positive, c > b > 0 is a good parameter case.
            % if obj.b > 0
                
            %     if obj.b - obj.c > 1
            %         % The number of terms to shift.
            %         nTerms = fix(obj.b - obj.c) + 1;

            %     else
            %         nTerms = fix(obj.b - obj.c) + 2
            %     end
            
            % elseif obj.a + obj.b > 0

            % end
            % nTerms = fix(1 - obj.c) + 1;
            if (fix(0.3 - obj.c)) == (-obj.c)
                nTerms = fix(0.3 - obj.c) + 1;
            else
                nTerms = fix(0.3 - obj.c);
            end

            % The reduced c parameter.
            reducedc = obj.c + nTerms;
            
            %%%%%%%%%%%%%% DEBUG %%%%%%%%%%%
            logger = PersistentLogger.getInstance();
            logger.writeDebug("At computeByRecurrence parameter case %s", obj.id);
            logger.writeDebug("At computeByRecurrence nTerms: %d", nTerms);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Preallocate recurrence relation's solution.
            recurrenceSolution = nan(nTerms + 1, 1);
            
            % First terms Hypergeometric objects.
            firstTermHypergeometric   = Hypergeometric(1, obj.a, obj.b, reducedc, obj.z);
            secondTermHypergeometric  = Hypergeometric(1, obj.a, obj.b, reducedc - 1, obj.z);
            
            % Fill in first 2 solutions.
            recurrenceSolution(1) = firstTermHypergeometric.computeApproximation();
            recurrenceSolution(2) = secondTermHypergeometric.computeApproximation();
            
            % Propagate the recurrence relation forward.
            for iTerm = 2 : nTerms
                
                % Apply recurrence relation.
                recurrenceSolution(iTerm + 1) =...
                    (-(reducedc + 1 - iTerm) *...
                    (reducedc - iTerm - ((2 * reducedc) + 1 - (2 * iTerm) - obj.a - obj.b) * obj.z) *...
                    recurrenceSolution(iTerm) -...
                    (reducedc - obj.a + 1 - iTerm) *...
                    (reducedc - obj.b + 1 - iTerm) *...
                    obj.z * recurrenceSolution(iTerm - 1)) /...
                    (reducedc + 1 - iTerm) /...
                    (reducedc - iTerm) /...
                    (obj.z - 1);
                
            end
            
            % Return solution
            approximation = recurrenceSolution(end);
            
        end
        
        % Computational procedures for parameter cases II and IV.
        function approximation = computeCaseII(obj)
            %COMPUTECASEII Computes the Gaussian Hypergeometric function for parameter cases II and IV.
            %
            % Input:
            %   obj    The HypergeometricCalculator object.
            %
            % Output:
            %   approximation    An approximation to the Gaussian Hypergeometric function.
            
            % Apply a transformation formula to reduce to another parameter case.
            aTransformed      = obj.c - obj.a;
            bTransformed      = obj.c - obj.b;
            
            % Transformation is not able to switch parameter regime.
            if aTransformed < 0 && bTransformed < 0
                
                approximation = hypergeom([aTransformed, bTransformed], obj.c, obj.z);
            else
                % Transformation formula can switch parameter regime.
                lambda = (1 - obj.z) ^ (obj.c - obj.a - obj.b);
                
                % Create a new Hypergeometric object with the transformed parameters.
                hypergeometric = Hypergeometric(lambda, aTransformed, bTransformed, obj.c, obj.z);
                
                % Compute approximation with transformed parameters.
                approximation = hypergeometric.computeApproximation();
            end
        end
        
        % Computational procedures for parameter case I(B).
        function approximation = computeCaseIB(obj)
            
            % Get logger
            logger = PersistentLogger.getInstance();
            
            % Are b - a or c - a - b close to an integer?
            isCancellation = (abs(obj.b - obj.a) < 1e-12) || (abs(obj.c - obj.a - obj.b) < 1e-12);
            if isCancellation
                
                % Just log for now, no method is implemented to solve this problem as of yet.
                logger.writeWarning("Cancelation problem. a: %d, b: %d, c: %d", obj.a, obj.b, obj.c);
                
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
                    logger.writeError("Did not expect no convergence.");
                    
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
                    logger.writeWarning("No convergence achieved for parameter case %s with Taylor series method B",...
                        obj.id);
                    return
                else
                    % Keep computing.
                end
            end
            % If convergence is achieved, return sum of terms computed.
            approximation = A(end);
        end
        function approximation = computeByTaylorA(obj)
            %COMPUTEBYTAYLORA Computes the hypergeometric function using Taylor series method A up to a tolerance.
            %
            % Input:
            %   obj              The HypergeometricCalculator object.
            %
            % Output:
            %   approximation    An approximation to the hypergeometric function.
            
            %%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%
            logger = PersistentLogger.getInstance();
            
            logger.writeInfo("About to start TaylorA");
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
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
                        
                        % Get logger instance.
                        logger = PersistentLogger.getInstance();
                        
                        % Log warning.
                        logger.writeWarning(...
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
    end
end