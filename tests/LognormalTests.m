classdef LognormalTests < matlab.unittest.TestCase
    properties
        lognormal
        parameterSetup
    end
    methods (TestClassSetup)
        function setupLognormal(tc)
            tc.lognormal = Lognormal(2);
            tc.parameterSetup = tc.lognormal.getParameterSetup();
        end
    end
    methods (Test)
        function testGetParameterSetup(tc)
            lb = tc.parameterSetup.getAllLowerBounds();
            disp(lb)
        end
        function testGetPrice(tc)
            fileReader = FileReader();
            data = fileReader.readDay(1);
            smoothData = DataSmoother.fitStrikeToImpliedVolatility(data)
        end
    end
end