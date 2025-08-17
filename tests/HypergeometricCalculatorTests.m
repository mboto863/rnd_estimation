% Inherit performance testing functionality
classdef HypergeometricCalculatorTests < matlab.perftest.TestCase
    
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
            tc.aData = -100 + (200 * rand(1, 10));
            tc.bData = -100 + (200 * rand(1, 10));
            tc.cData = -100 + (200 * rand(1, 10));
            tc.zData = -0.25 + (0.5 * rand(1, 10));
            
        end
    end
    
    % Tests
    methods (Test)
        
        % Test an easy parameter case.
        function easyCase(tc)
            
            % Create a calculator
            calculator = HypergeometricCalculator(0.1, 0.2, 0.3, 0.4);
            
            % Calculate.
            approximation = calculator.computeApproximation();
            
            % Built-in functionality.
            truth = hypergeom([0.1, 0.2], 0.3, 0.4);
            
            % Verify.
            tc.verifyEqual(approximation, truth, 'AbsTol', 1e-12);
            
        end
        
        % Performance tests
        function testCalculator(tc)
            
            % Calculator's outputs.
            calculatorOutputs = nan(size(tc.aData));
            
            % Measure
            while tc.keepMeasuring
                for iIn = 1 : numel(tc.aData)
                    
                    % Create a calculator.
                    calculator = HypergeometricCalculator(tc.aData(iIn), tc.bData(iIn), tc.cData(iIn), tc.zData(iIn));
                    
                    % Calculate calculator's output at ith input.
                    calculatorOutputs(iIn) = calculator.computeApproximation();
                    
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