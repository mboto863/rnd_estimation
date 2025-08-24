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
            tc.aData = -0.5 * ones(100, 1);
            tc.bData = rand(100, 1);
            tc.cData = 0.5 * ones(100, 1);
            tc.zData = rand(100, 1);
            
        end
    end
    
    % Tests
    methods (Test)
        % Accuracy tests.
        % Test an easy parameter case.
        function betweenLargeAndMinusOne(tc)
            
            a = tc.aData;
            b = -5 + (0 - 5) * tc.bData;
            c = tc.cData;
            z = -20 + (-1 + 0) * tc.zData;

            for iIn = 1 : numel(a)
                hypergeometric = Hypergeometric(1, a(iIn), b(iIn), c(iIn), z(iIn));
                
                % Calculate.
                approximation = hypergeometric.computeApproximation();
                
                % Built-in functionality.
                truth = hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-12);
            end
        end
        function betweenMinusOneAndZero(tc)
            a = tc.aData;
            b = -5 + (0 - 5) * tc.bData;
            c = tc.cData;
            z = -1 + (0 + 1) * tc.zData;

            for iIn = 1 : numel(a)
                hypergeometric = Hypergeometric(1, a(iIn), b(iIn), c(iIn), z(iIn));
                
                % Calculate.
                approximation = hypergeometric.computeApproximation();
                
                % Built-in functionality.
                truth = hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenZeroAndOneHalf(tc)
            a = tc.aData;
            b = -5 + (0 - 5) * tc.bData;
            c = tc.cData;
            z = 0 + (0.5 - 0) * tc.zData;

            for iIn = 1 : numel(a)
                hypergeometric = Hypergeometric(1, a(iIn), b(iIn), c(iIn), z(iIn));
                
                % Calculate.
                approximation = hypergeometric.computeApproximation();
                
                % Built-in functionality.
                truth = hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenOneHalfAndOne(tc)
            a = tc.aData;
            b = -5 + (0 - 5) * tc.bData;
            c = tc.cData;
            z = 0.5 + (1 - 0.5) * tc.zData;

            for iIn = 1 : numel(a)
                hypergeometric = Hypergeometric(1, a(iIn), b(iIn), c(iIn), z(iIn));
                
                % Calculate.
                approximation = hypergeometric.computeApproximation();
                
                % Built-in functionality.
                truth = hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-3);
            end
        end
        function betweenOneAndTwo(tc)
            a = tc.aData;
            b = -5 + (0 - 5) * tc.bData;
            c = tc.cData;
            z = 1 + (2 - 1) * tc.zData;

            for iIn = 1 : numel(a)
                hypergeometric = Hypergeometric(1, a(iIn), b(iIn), c(iIn), z(iIn));
                
                % Calculate.
                approximation = hypergeometric.computeApproximation();
                
                % Built-in functionality.
                truth = hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenTwoAndLarge(tc)
            a = tc.aData;
            b = -5 + (0 - 5) * tc.bData;
            c = tc.cData;
            z = 2 + (20 - 2) * tc.zData;

            for iIn = 1 : numel(a)
                hypergeometric = Hypergeometric(1, a(iIn), b(iIn), c(iIn), z(iIn));
                
                % Calculate.
                approximation = hypergeometric.computeApproximation();
                
                % Built-in functionality.
                truth = hypergeom([a(iIn), b(iIn)], c(iIn), z(iIn));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
    end
end