classdef computeByRecurrence00PlusBackwardsTests < matlab.unittest.TestCase
    properties
        % a argument.
        aData
        
        % b argument.
        bData
        
        % c argument.
        cData
        
        % z argument.
        zData
        
        % The calculator we are testing.
        hypergeometricCalculator
        
    end
    
    % Prepare data
    methods (TestClassSetup)
        function prepareData(tc)
            
            % Get a parameter case V with c > 20
            tc.aData = 0.1;
            tc.bData = -1;
            tc.cData = -30;
            tc.zData = 0.4;
            tc.hypergeometricCalculator = HypergeometricCalculator(tc.aData, tc.bData, tc.cData, tc.zData);
        end
    end
    
    % Tests.
    methods (Test)
        
        % Main functionality test.
        function computeTest(tc)
            
            % Get logger.
            logger = PersistentLogger.getInstance();
            
            % Test algorithm.
            approximation = tc.hypergeometricCalculator.publicComputeByRecurrence00PlusBackwards();
            
            % Reference value.
            truth = hypergeom([tc.aData, tc.bData], tc.cData, tc.zData);
            
            % Log the outputs.
            logger.writeInfo("calculator's output: %d, built-in output: %d", approximation, truth);
            
            % Verify
            tc.verifyEqual(approximation, truth, 'AbsTol', 1e-6);
            
        end
    end
end