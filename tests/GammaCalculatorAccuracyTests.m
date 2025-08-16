classdef GammaCalculatorAccuracyTests < matlab.unittest.TestCase
    
    % Tests.
    methods (Test)
        function testOverallAccuracy(testCase)
            
            % Arguments to test.
            zValues = linspace(0.05, 10, 100);

            % Expected values
            expected = gamma(zValues);

            % Preallocate
            actual = nan(size(expected));

            % Computed actual values.
            for iArg = 1 : numel(zValues)
                actual(iArg) = GammaCalculator.computeGammaFunction(zValues(iArg));
            end

            % Test computed values.
            testCase.verifyEqual(actual, expected, 'AbsTol', 1e-8);
        end
    end
end