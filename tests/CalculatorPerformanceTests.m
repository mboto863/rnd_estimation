% Inherit performance testing functionality
classdef CalculatorPerformanceTests < matlab.perftest.TestCase
    properties
        
        % The inputs for the special function.
        lambdaData
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
            tc.lambdaData = ones(1000, 2);
            tc.aData = -0.5 * ones(1000, 2);
            tc.bData = rand(1000, 2);
            tc.cData = 0.5 * ones(1000, 2);
            tc.zData = rand(1000, 2);
            
        end
    end

    % Performance tests.
    methods (Test)
        function calculatorBetweenLargeAndMinusOne(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (-1 + 20) * tc.zData;

            % Preallocate variable.
            approximationValues = zeros(size(a));
            while tc.keepMeasuring
                for iIn = 1 : size(a, 1)
                    for jComponent = 1 : numel(a(iIn))

                        hypergeometric = Hypergeometric(...
                        lambda(iIn, jComponent),...
                        a(iIn, jComponent),...
                        b(iIn, jComponent),...
                        c(iIn, jComponent),...
                        z(iIn, jComponent));
                        
                        approximationValues(iIn, jComponent) = hypergeometric.computeApproximation();
                        approximation = sum(approximationValues(iIn, :));
                    end
                end
            end
        end
        function builtinBetweenLargeAndMinusOne(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (-1 + 20) * tc.zData;
            % Preallocate variable.
            truthValues = zeros(size(a));
            while tc.keepMeasuring
                for iIn = 1 : size(a, 1)
                    for jComponent = 1 : numel(a(iIn))

                        truthValues(iIn, jComponent) = lambda(iIn, jComponent) * hypergeom(...
                        [a(iIn, jComponent), b(iIn, jComponent)],...
                        c(iIn, jComponent),...
                        z(iIn, jComponent)...
                        );
                        
                        approximation = sum(truthValues(iIn, :));
                    end
                end
            end

        end
    end
end