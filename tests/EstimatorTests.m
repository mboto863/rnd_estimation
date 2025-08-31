classdef EstimatorTests < matlab.unittest.TestCase
    properties
        model
        fileReader
    end
    methods (TestClassSetup)
        function classSetup(tc)
            tc.model          = Student(2);
            tc.fileReader     = FileReader();
        end
    end
    methods (Test)
        function estimateDayTest(tc)
            estimator = Estimator(tc.model, tc.fileReader);

            
            tic
            % Test method estimateDay.
            estimator.estimateDay(1);
            toc
        end
        % function runEstimationTest(tc)
        %     estimator = Estimator(tc.model, tc.fileReader, tc.parameterSetup);

        %     tic
        %     estimator.runEstimation();
        %     toc
        % end
    end
end