classdef EstimationTests < matlab.unittest.TestCase
    properties
        model
        fileReader
        parameterSetup
    end
    methods (TestClassSetup)
        function classSetup(tc)
            tc.model          = "Student";
            tc.fileReader     = FileReader();
            tc.parameterSetup = StudentParameterSetup(2);
        end
    end
    methods (Test)
        function estimateDayTest(tc)
            estimation = Estimation(tc.model, tc.fileReader, tc.parameterSetup);

            % initialize parameter values.
            firstDataset = tc.fileReader.readDay(1);            
            names        = tc.parameterSetup.getNames();            
            values       = tc.parameterSetup.initializeAll(firstDataset);
            
            % Create a ValueHandler instance.
            valueHandler = ValueHandler(tc.parameterSetup.dimension, names, values);
            
            tic
            % Test method estimateDay.
            estimation.estimateDay(1, valueHandler);
            toc
        end
    end
end