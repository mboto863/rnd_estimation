classdef ComputeByTaylorATests < matlab.unittest.TestCase
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
            tc.bData = -5 + (5 * rand(1, 100));
            tc.cData = 0.5 * ones(1, 100);
            tc.zData = -0.25 + (0.5 * rand(1, 100));
            
        end
    end
    
    % Tests
    methods (Test)
        % Accuracy tests.
        % Test an easy parameter case.
        function easyCase(tc)
            
            % Create a calculator
            hypergeometric = Hypergeometric(1, 0.1, 0.2, 0.3, 0.4);
            
            % Calculate.
            approximation = hypergeometric.computeByTaylorA();
            
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
                hypergeometric = Hypergeometric(1, tc.aData(iIn), tc.bData(iIn), tc.cData(iIn), tc.zData(iIn));
        
                % Compute approximation.
                calculatorOutputs(iIn) = hypergeometric.computeByTaylorA();
                
                
                truth(iIn) = hypergeom([tc.aData(iIn), tc.bData(iIn)], tc.cData(iIn), tc.zData(iIn));
            end
            tc.verifyEqual(truth, calculatorOutputs, 'RelTol', 1e-6)
        end
    end
end
