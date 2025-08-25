% Inherit performance testing functionality
classdef HypergeometricMixtureTests < matlab.perftest.TestCase
    
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
    
    % Tests
    methods (Test)
        function betweenLargeAndMinusOne(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (-1 + 20) * tc.zData;

            for iIn = 1 : size(a, 1)
                truthValues = zeros(size(a(iIn)));
                approximationValues = zeros(size(a(iIn)));
                for jComponent = 1 : numel(a(iIn))
                    truthValues(jComponent) = lambda(iIn, jComponent) * hypergeom(...
                        [a(iIn, jComponent), b(iIn, jComponent)],...
                        c(iIn, jComponent),...
                        z(iIn, jComponent));
                    
                    hypergeometric = Hypergeometric(...
                    lambda(iIn, jComponent),...
                    a(iIn, jComponent),...
                    b(iIn, jComponent),...
                    c(iIn, jComponent),...
                    z(iIn, jComponent));
                    
                    approximationValues(jComponent) = hypergeometric.computeApproximation();
                end
                truth = sum(truthValues);
                approximation = sum(approximationValues);
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenMinusOneAndZero(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -1 + (0 + 1) * tc.zData;

            for iIn = 1 : size(a, 1)
                truthValues = zeros(size(a(iIn)));
                approximationValues = zeros(size(a(iIn)));
                for jComponent = 1 : numel(a(iIn))
                    truthValues(jComponent) = lambda(iIn, jComponent) * hypergeom(...
                        [a(iIn, jComponent), b(iIn, jComponent)],...
                        c(iIn, jComponent),...
                        z(iIn, jComponent));
                    
                    hypergeometric = Hypergeometric(...
                    lambda(iIn, jComponent),...
                    a(iIn, jComponent),...
                    b(iIn, jComponent),...
                    c(iIn, jComponent),...
                    z(iIn, jComponent));
                    
                    approximationValues(jComponent) = hypergeometric.computeApproximation();
                end
                truth = sum(truthValues);
                approximation = sum(approximationValues);
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenZeroAndOneHalf(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = 0 + (0.5 - 0) * tc.zData;

            for iIn = 1 : size(a, 1)
                truthValues = zeros(size(a(iIn)));
                approximationValues = zeros(size(a(iIn)));
                for jComponent = 1 : numel(a(iIn))
                    truthValues(jComponent) = lambda(iIn, jComponent) * hypergeom(...
                        [a(iIn, jComponent), b(iIn, jComponent)],...
                        c(iIn, jComponent),...
                        z(iIn, jComponent));
                    
                    hypergeometric = Hypergeometric(...
                    lambda(iIn, jComponent),...
                    a(iIn, jComponent),...
                    b(iIn, jComponent),...
                    c(iIn, jComponent),...
                    z(iIn, jComponent));
                    
                    approximationValues(jComponent) = hypergeometric.computeApproximation();
                end
                truth = sum(truthValues);
                approximation = sum(approximationValues);
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenOneHalfAndOne(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = 0.5 + (1 - 0.5) * tc.zData;

            for iIn = 1 : size(a, 1)
                truthValues = zeros(size(a(iIn)));
                approximationValues = zeros(size(a(iIn)));
                for jComponent = 1 : numel(a(iIn))
                    truthValues(jComponent) = lambda(iIn, jComponent) * hypergeom(...
                        [a(iIn, jComponent), b(iIn, jComponent)],...
                        c(iIn, jComponent),...
                        z(iIn, jComponent));
                    
                    hypergeometric = Hypergeometric(...
                    lambda(iIn, jComponent),...
                    a(iIn, jComponent),...
                    b(iIn, jComponent),...
                    c(iIn, jComponent),...
                    z(iIn, jComponent));
                    
                    approximationValues(jComponent) = hypergeometric.computeApproximation();
                end
                truth = sum(truthValues);
                approximation = sum(approximationValues);
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenOneAndTwo(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = 1 + (2 - 1) * tc.zData;

            for iIn = 1 : size(a, 1)
                truthValues = zeros(size(a(iIn)));
                approximationValues = zeros(size(a(iIn)));
                for jComponent = 1 : numel(a(iIn))
                    truthValues(jComponent) = lambda(iIn, jComponent) * hypergeom(...
                        [a(iIn, jComponent), b(iIn, jComponent)],...
                        c(iIn, jComponent),...
                        z(iIn, jComponent));
                    
                    hypergeometric = Hypergeometric(...
                    lambda(iIn, jComponent),...
                    a(iIn, jComponent),...
                    b(iIn, jComponent),...
                    c(iIn, jComponent),...
                    z(iIn, jComponent));
                    
                    approximationValues(jComponent) = hypergeometric.computeApproximation();
                end
                truth = sum(truthValues);
                approximation = sum(approximationValues);
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        function betweenTwoAndLarge(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = 2 + (20 - 2) * tc.zData;

            for iIn = 1 : size(a, 1)
                truthValues = zeros(size(a(iIn)));
                approximationValues = zeros(size(a(iIn)));
                for jComponent = 1 : numel(a(iIn))
                    truthValues(jComponent) = lambda(iIn, jComponent) * hypergeom(...
                        [a(iIn, jComponent), b(iIn, jComponent)],...
                        c(iIn, jComponent),...
                        z(iIn, jComponent));
                    
                    hypergeometric = Hypergeometric(...
                    lambda(iIn, jComponent),...
                    a(iIn, jComponent),...
                    b(iIn, jComponent),...
                    c(iIn, jComponent),...
                    z(iIn, jComponent));
                    
                    approximationValues(jComponent) = hypergeometric.computeApproximation();
                end
                truth = sum(truthValues);
                approximation = sum(approximationValues);
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-6);
            end
        end
        % Performance tests
        function generalPerformance(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (20 + 20) * tc.zData;

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
        function truthGeneralPerformance(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (20 + 20) * tc.zData;

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