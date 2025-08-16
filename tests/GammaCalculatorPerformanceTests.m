% Inherit performance testing functionality.
classdef GammaCalculatorPerformanceTests < matlab.perftest.TestCase
    
    properties
        
        % The inputs for the gamma function.
        data
        
    end
    
    % Class based setup.
    methods (TestClassSetup)
        function prepareData(tc)
            
            % Data is random.
            tc.data =  -100 + (200 * rand(1, 1e4));
            
        end
    end
    
    % Performance tests.
    methods (Test)
        
        % Test computeGamma method's performance.
        function testGammaCalculator(tc)
            
            % Reference outputs.
            referenceOutput = gamma(tc.data);
            
            % Preallocate outputs.
            gammaCalculatorOut = nan(size(tc.data));
            
            % Measure accuracy.
            for iIn = 1 : numel(tc.data)
                
                % Calculator's output.
                output = GammaCalculator.computeGammaFunction(tc.data(iIn));
                
                % Verify accuracy.
                tc.verifyEqual(output, referenceOutput(iIn), 'RelTol', 1e-9);
                
            end
            
            % Measure performance
            while tc.keepMeasuring
                for iIn = 1 : numel(tc.data)
                    
                    % Compute Gamma of ith input.
                    gammaCalculatorOut(iIn) = GammaCalculator.computeGammaFunction(tc.data(iIn));
                    
                end
            end
        end
        
        % Test built-in gamma function's performance.
        function testGamma(tc)
            
            % Preallocate ouputs.
            outputs = nan(size(tc.data));
            
            % Measure performance.
            while tc.keepMeasuring
                for iIn = 1 : numel(tc.data)
                    
                    % Compute Gamma of ith input.
                    outputs(iIn) = gamma(tc.data(iIn));
                end
            end
        end
    end
end