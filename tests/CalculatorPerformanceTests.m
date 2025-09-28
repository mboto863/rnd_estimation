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

    % Method based setup
    methods (TestMethodSetup)
        
        % Prepare the data.
        function prepareData(tc)
            % Use a different seed at each iteration.
            rng('shuffle');

            % Data is randomly initiated.
            tc.lambdaData = 1 * ones(1000, 1);
            tc.aData = -0.5 * ones(1000, 1);
            tc.bData = rand(1000, 1);
            tc.cData = 0.5 * ones(1000, 1);
            tc.zData = rand(1000, 1);
            
        end
    end

    % Performance tests.
    methods (Test)
        function calculatorBetweenLargeAndMinusOne(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = 2 + (50 - 2) * tc.bData;
            c      = tc.cData;
            z      = -40 + (-1 - (-40)) * tc.zData;
                    
            for iIn = 1 : numel(a)
                % Create the Hypergeometric object.
                hypergeometric = Hypergeometric(...
                    lambda(iIn),...
                    a(iIn),...
                    b(iIn),...
                    c(iIn),...
                    z(iIn)...
                    );
                
                % Compute the approximation.
                approximation = hypergeometric.computeApproximation();
            end
        end
        function calculatorBetweenMinusOneAndZero(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = 2 + (50 - 2) * tc.bData;
            c      = tc.cData;
            z      = -1 + (0 - (-1)) * tc.zData;
                    
            for iIn = 1 : numel(a)
                % Create the Hypergeometric object.
                hypergeometric = Hypergeometric(...
                    lambda(iIn),...
                    a(iIn),...
                    b(iIn),...
                    c(iIn),...
                    z(iIn)...
                    );
                
                % Compute the approximation.
                approximation = hypergeometric.computeApproximation();
            end
        end
        function builtinBetweenLargeAndMinusOne(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = 2 + (50 - 2) * tc.bData;
            c      = tc.cData;
            z      = -40 + (-1 - (-40)) * tc.zData;
            for iIn = 1 : numel(a)
                truth = lambda(iIn) * hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
            end
        end
        function builtinBetweenMinusOneAndZero(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = 2 + (50 - 2) * tc.bData;
            c      = tc.cData;
            z      = -1 + (0 - (-1)) * tc.zData;
            for iIn = 1 : numel(a)
                truth = lambda(iIn) * hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
            end
        end
    end
end