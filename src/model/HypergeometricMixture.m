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
        function approximation = computeApproximation(obj)
            %COMPUTEMIXTURE Approximate the Gaussian Hypergeometric mixture.
            %
            % Input:
            %   obj              The HypergeometricMixture object.
            %
            % Output:
            %   approximation    The approximation value.
            
            % Value of the mixture.
            mixture = zeros(size(obj.a));
            % Compute for every component.
            for iComponent = 1 : numel(obj.a)
                if obj.lambda(iComponent) == 0
                    mixture(iComponent) = 0;
                else
                    % The Hypergeometric object.
                    hypergeometric = Hypergeometric(...
                        obj.lambda(iComponent),...
                        obj.a(iComponent),...
                        obj.b(iComponent),...
                        obj.c(iComponent),...
                        obj.z(iComponent)...
                        );
                    
                    % Approximate the hypergeometric.
                    singleValue = hypergeometric.computeApproximation();

                    mixture(iComponent) = singleValue;

                end


            end
            approximation = sum(mixture);
        end
        function approximation = computeApproximationKahan(obj)
            % Value of the mixture.
            mixtureValue = zeros(size(obj.a));

            % Compute for every component.
            for iComponent = 1 : numel(obj.a)
                if obj.lambda(iComponent) == 0
                    mixtureValue(iComponent) = 0;
                else
                    
                    % The Hypergeometric object.
                    hypergeometric = Hypergeometric(...
                        obj.lambda(iComponent),...
                        obj.a(iComponent),...
                        obj.b(iComponent),...
                        obj.c(iComponent),...
                        obj.z(iComponent)...
                        );

                    % Approximate the hypergeometric.
                    mixtureValue(iComponent) = hypergeometric.computeApproximation();

                end
            end
            approximation = HypergeometricMixture.computeKahanSum(mixtureValue);
        end
        function approximation = computeApproximationBuiltinSum(obj)
            % Value of the mixture.
            mixtureValue = zeros(size(obj.a));

            % Compute for every component.
            for iComponent = 1 : numel(obj.a)
                if obj.lambda(iComponent) == 0
                    mixtureValue(iComponent) = 0;
                else
                    
                    % The Hypergeometric object.
                    hypergeometric = Hypergeometric(...
                        obj.lambda(iComponent),...
                        obj.a(iComponent),...
                        obj.b(iComponent),...
                        obj.c(iComponent),...
                        obj.z(iComponent)...
                        );

                    % Approximate the hypergeometric.
                    mixtureValue(iComponent) = hypergeometric.computeApproximation();

                end
            end
            approximation = sum(mixtureValue);
        end
        function approximation = computeApproximationSymToolbox(obj)
            % Value of the mixture.
            mixtureValue = sym(zeros(size(obj.a)));

            % Compute for every component.
            for iComponent = 1 : numel(obj.a)
                if obj.lambda(iComponent) == 0
                    mixtureValue(iComponent) = sym(0);
                else
                    
                    % The Hypergeometric object.
                    hypergeometric = Hypergeometric(...
                        obj.lambda(iComponent),...
                        obj.a(iComponent),...
                        obj.b(iComponent),...
                        obj.c(iComponent),...
                        obj.z(iComponent)...
                        );

                    % Approximate the hypergeometric.
                    mixtureValue(iComponent) = sym(hypergeometric.computeApproximation());

                end
            end
            approximation = double(sum(mixtureValue));
        end
        function approximation = computeApproximationVpa(obj)
            % Set high precision (adjust as needed; 100 digits for ~80 order magnitude differences).
            digitsOld = digits(100); % Save original and set to 100 digits.
            
            % Value of the mixture.
            mixture = sym(zeros(size(obj.a)));

            % Compute for every component.
            for iComponent = 1 : numel(obj.a)
                if obj.lambda(iComponent) == 0
                    mixture(iComponent) = sym(0);
                else
                    
                    % The Hypergeometric object.
                    hypergeometric = Hypergeometric(...
                        obj.lambda(iComponent),...
                        obj.a(iComponent),...
                        obj.b(iComponent),...
                        obj.c(iComponent),...
                        obj.z(iComponent)...
                        );

                    % Approximate the hypergeometric.
                    mixture(iComponent) = sym(hypergeometric.computeApproximation());

                end
            end
            mixtureValueSym = sum(mixture);
            mixtureValue    = vpa(mixtureValueSym);
            approximation   = double(mixtureValue);

            % Restore original digits setting.
            digits(digitsOld);
        end
    end
    methods (Static, Access = private)
        function sum = computeKahanSum(values)
            
            % Sort the values to be summed.
            sortedValues = sort(abs(values));

            % Initialize sum variable.
            sum = 0;

            % Initialize compensation term.
            correction = 0;

            for iValue = 1 : numel(sortedValues)
                % Subtract correction.
                adjustment = sortedValues(iValue) - correction;

                % Add adjusted value.
                adjusted = sum + adjustment;

                % Update correction.
                correction = (adjusted - sum) - adjustment;

                % Update sum.
                sum = adjusted;
            end
        end

    end
end