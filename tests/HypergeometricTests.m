% Inherit performance testing functionality
classdef HypergeometricTests < matlab.perftest.TestCase
    
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
            tc.aData = -0.5 * ones(1, 100);
            tc.bData = -100 + (200 * rand(1, 100));
            tc.cData = 0.5 * ones(1, 100);
            tc.zData = -10 + (20 * rand(1, 100));
            
        end
    end
    
    % Tests
    methods (Test)
        % Accuracy tests.
        % Test an easy parameter case.
        function easyCase(tc)
            
            % Create a calculator
            calculator = HypergeometricCalculator(0.1, 0.2, 0.3, 0.4);
            
            % Calculate.
            approximation = calculator.computeApproximation();
            
            % Built-in functionality.
            truth = hypergeom([0.1, 0.2], 0.3, 0.4);
            
            % Verify.
            tc.verifyEqual(approximation, truth, 'RelTol', 1e-12);
            
        end
        % Extensive accuracy test.
        function testAccuracy(tc)
            % Import test diagnostics functionality.
            import matlab.unittest.diagnostics.StringDiagnostics.*

            % % Reference computation.
            truth = nan(size(tc.aData));

            % Calculator's outputs.
            calculatorOutputs = nan(size(tc.aData));

            for iIn = 1 : numel(tc.aData)
                % Create a Hypergeometric object.
                hypergeometric = HypergeometricMixture(1, tc.aData(iIn), tc.bData(iIn), tc.cData(iIn), tc.zData(iIn));
        
                % Compute approximation.
                calculatorOutputs(iIn) = hypergeometric.computeApproximation();
                
                
                truth(iIn) = hypergeom([tc.aData(iIn), tc.bData(iIn)], tc.cData(iIn), tc.zData(iIn));
            end
            tc.verifyEqual(truth, calculatorOutputs, 'RelTol', 1e-6)
        end
        % Performance tests
        function testCalculator(tc)
            
            % Calculator's outputs.
            calculatorOutputs = nan(size(tc.aData));

            
            
            % Measure.
            while tc.keepMeasuring
                for iIn = 1 : numel(tc.aData)
                    
                    % Create a Hypergeometric object.
                    hypergeometric = Hypergeometric(1, tc.aData(iIn), tc.bData(iIn), tc.cData(iIn), tc.zData(iIn));
                    
                    % Calculate calculator's output at ith input.
                    calculatorOutputs(iIn) = hypergeometric.computeApproximation();
                    
                end
            end
        end
        function testReference(tc)
            % Reference outputs.
            referenceOutputs = nan(size(tc.aData));
            
            % Measure
            while tc.keepMeasuring
                for iIn = 1 : numel(tc.aData)
                    
                    % Calculate reference output at ith input.
                    referenceOutputs(iIn) = hypergeom([tc.aData(iIn), tc.bData(iIn)], tc.cData(iIn), tc.zData(iIn));
                    
                end
            end
        end
    end
end