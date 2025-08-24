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
            tc.lambdaData = ones(100, 2);
            tc.aData = -0.5 * ones(100, 2);
            tc.bData = rand(100, 2);
            tc.cData = 0.5 * ones(100, 2);
            tc.zData = rand(100, 2);
            
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
        function betweenLargeAndMinusOneKahan(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (-1 + 20) * tc.zData;

            for iIn = 1 : size(a, 1)
                hypergeometricMixture = HypergeometricMixture(...
                    lambda(iIn, :),...
                    a(iIn, :),...
                    b(iIn, :),...
                    c(iIn, :),...
                    z(iIn, :)...
                    );
                
                % Calculate.
                approximation = hypergeometricMixture.computeApproximationKahan();
                
                % Built-in functionality.
                truth = sum(lambda(iIn, :) .* hypergeom([a(iIn, :), b(iIn, :)], c(iIn, :), z(iIn, :)));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-5);
            end
        end
        function betweenLargeAndMinusOneBuiltinSum(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (-1 + 20) * tc.zData;

            for iIn = 1 : size(a, 1)
                hypergeometricMixture = HypergeometricMixture(...
                    lambda(iIn, :),...
                    a(iIn, :),...
                    b(iIn, :),...
                    c(iIn, :),...
                    z(iIn, :)...
                    );
                
                % Calculate.
                approximation = hypergeometricMixture.computeApproximationBuiltinSum();
                
                % Built-in functionality.
                truth = sum(lambda(iIn, :) .* hypergeom([a(iIn, :), b(iIn, :)], c(iIn, :), z(iIn, :)));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-5);
            end
        end
        function betweenLargeAndMinusOneSymToolbox(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (-1 + 20) * tc.zData;

            for iIn = 1 : size(a, 1)
                hypergeometricMixture = HypergeometricMixture(...
                    lambda(iIn, :),...
                    a(iIn, :),...
                    b(iIn, :),...
                    c(iIn, :),...
                    z(iIn, :)...
                    );
                
                % Calculate.
                approximation = hypergeometricMixture.computeApproximationSymToolbox();
                
                % Built-in functionality.
                truth = sum(lambda(iIn, :) .* hypergeom([a(iIn, :), b(iIn, :)], c(iIn, :), z(iIn, :)));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-5);
            end
        end
        function betweenLargeAndMinusOneVpa(tc)
            lambda = tc.lambdaData;
            a      = tc.aData;
            b      = -5 + (0 - 5) * tc.bData;
            c      = tc.cData;
            z      = -20 + (-1 + 20) * tc.zData;

            for iIn = 1 : size(a, 1)
                hypergeometricMixture = HypergeometricMixture(...
                    lambda(iIn, :),...
                    a(iIn, :),...
                    b(iIn, :),...
                    c(iIn, :),...
                    z(iIn, :)...
                    );
                
                % Calculate.
                approximation = hypergeometricMixture.computeApproximationVpa();
                
                % Built-in functionality.
                truth = sum(lambda(iIn, :) .* hypergeom([a(iIn, :), b(iIn, :)], c(iIn, :), z(iIn, :)));
                
                % Verify.
                tc.verifyEqual(approximation, truth, 'RelTol', 1e-5);
            end
        end
        % % Extensive accuracy test.
        % function testAccuracy(tc)
        %     % Import test diagnostics functionality.
        %     import matlab.unittest.diagnostics.StringDiagnostics.*

        %     % % Reference computation.
        %     truth = nan(size(tc.aData, 1), 1);

        %     % Calculator's outputs.
        %     calculatorOutputs = nan(size(tc.aData, 1), 1);

        %     lambda = ones(1, size(tc.aData, 2));

        %     for iIn = 1 : size(tc.aData, 1)
        %         % Create a Hypergeometric object.
        %         hypergeometricMixture =...
        %             HypergeometricMixture(lambda,...
        %                 tc.aData(iIn, :),...
        %                 tc.bData(iIn, :),...
        %                 tc.cData(iIn, :),...
        %                 tc.zData(iIn, :));
        
        %         % Compute approximation.
        %         calculatorOutputs(iIn) = hypergeometricMixture.computeApproximation();
                
                
        %         truth(iIn) = sum(hypergeom([tc.aData(iIn, :), tc.bData(iIn, :)], tc.cData(iIn, :), tc.zData(iIn, :)));
        %     end
            
        %     tc.verifyEqual(truth, calculatorOutputs, 'RelTol', 1e-6)
        % end
        % % Performance tests
        % function testCalculator(tc)
            
        %     % Calculator's outputs.
        %     calculatorOutputs = nan(size(tc.aData, 1), 1);

        %     % lambdas should be 1.
        %     lambda = ones(1, size(tc.aData, 2));

        %     % Measure.
        %     while tc.keepMeasuring
        %         for iIn = 1 : size(tc.aData, 1)
                    
        %             % Create a Hypergeometric object.
        %             hypergeometricMixture =...
        %                 HypergeometricMixture(lambda,...
        %                     tc.aData(iIn, :),...
        %                     tc.bData(iIn, :),...
        %                     tc.cData(iIn, :),...
        %                     tc.zData(iIn, :));
                    
        %             % Calculate calculator's output at ith input.
        %             calculatorOutputs(iIn) = hypergeometricMixture.computeApproximation();
                    
        %         end
        %     end
        % end
        % function testReference(tc)
        %     % Built-in outputs
        %     referenceOutputs = nan(size(tc.aData, 1), 1);
            
        %     % Measure
        %     while tc.keepMeasuring
        %         for iIn = 1 : size(tc.aData, 1)
        %             % Calculate reference output at ith input.
        %             referenceOutputs(iIn) =...
        %                 sum(hypergeom(...
        %                     [tc.aData(iIn, :), tc.bData(iIn, :)],...
        %                     tc.cData(iIn, :),...
        %                     tc.zData(iIn, :)...
        %                     ));
        %         end
        %     end
        % end
    end
end