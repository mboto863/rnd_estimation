% Inherit performance testing functionality
classdef HypergeometricMixtureTests < matlab.perftest.TestCase
    
    properties
        
        % The inputs for the special function.
        aData
        bData
        cData
        zData
    end
    
    % Class based setup
    methods (TestClassSetup)
        
        % Prepare the data.
        function prepareData(tc)
            
            % Data is randomly initiated.
            tc.aData = -0.5 * ones(1, 5);
            tc.bData = -100 + (200 * rand(1, 5));
            tc.cData = 0.5 * ones(1, 5);
            tc.zData = -10 + (20 * rand(1, 5));
            
        end
    end
    
    % Tests
    methods (Test)
        % Extensive accuracy test.
        function testAccuracy(tc)
            % Import test diagnostics functionality.
            import matlab.unittest.diagnostics.StringDiagnostics.*

            % % Reference computation.
            truth = nan(size(tc.aData, 1), 1);

            % Calculator's outputs.
            calculatorOutputs = nan(size(tc.aData, 1), 1);

            lambda = ones(1, size(tc.aData, 2));

            for iIn = 1 : size(tc.aData, 1)
                % Create a Hypergeometric object.
                hypergeometricMixture =...
                    HypergeometricMixture(lambda,...
                        tc.aData(iIn, :),...
                        tc.bData(iIn, :),...
                        tc.cData(iIn, :),...
                        tc.zData(iIn, :));
        
                % Compute approximation.
                calculatorOutputs(iIn) = hypergeometricMixture.computeApproximation();
                
                
                truth(iIn) = sum(hypergeom([tc.aData(iIn, :), tc.bData(iIn, :)], tc.cData(iIn, :), tc.zData(iIn, :)));
            end
            tc.verifyEqual(truth, calculatorOutputs, 'RelTol', 1e-6)
        end
        % Performance tests
        function testCalculator(tc)
            
            % Calculator's outputs.
            calculatorOutputs = nan(size(tc.aData, 1), 1);

            % lambdas should be 1.
            lambda = ones(1, size(tc.aData, 2));

            % Measure.
            while tc.keepMeasuring
                for iIn = 1 : size(tc.aData, 1)
                    
                    % Create a Hypergeometric object.
                    hypergeometricMixture =...
                        HypergeometricMixture(lambda,...
                            tc.aData(iIn, :),...
                            tc.bData(iIn, :),...
                            tc.cData(iIn, :),...
                            tc.zData(iIn, :));
                    
                    % Calculate calculator's output at ith input.
                    calculatorOutputs(iIn) = hypergeometricMixture.computeApproximation();
                    
                end
            end
        end
        function testReference(tc)
            % Built-in outputs
            referenceOutputs = nan(size(tc.aData, 1), 1);
            
            % Measure
            while tc.keepMeasuring
                for iIn = 1 : size(tc.aData, 1)
                    % Calculate reference output at ith input.
                    referenceOutputs(iIn) =...
                        sum(hypergeom(...
                            [tc.aData(iIn, :), tc.bData(iIn, :)],...
                            tc.cData(iIn, :),...
                            tc.zData(iIn, :)...
                            ));
                end
            end
        end
    end
end