classdef FileReaderTests < matlab.unittest.TestCase
    properties
        fileReader
    end
    methods (TestClassSetup)
        function createFileReader(testCase)
        %CREATEFILEREADER Creates an instance of a FileReader object.

            % Create a FileReader object.
            testCase.fileReader = FileReader();
        end
    end
    methods (Test)
        function testConstructor(testCase)
        %TESTCONSTRUCTOR Test the FileReader constructor.
        %
        % Input:
        %   testCase    matlab.unittest.TestCase object.
        %
        % Output:
        %

            % Expected folder path.
            expectedFolderPath = "C:\Users\utilizador\projects\rnd_estimation\data";
            
            % fileReader's folder path attribute.
            actualFolderPath = testCase.fileReader.folderPath;

            % Check if fileReader's folder path attribute matches the expected one.
            testCase.verifyEqual(actualFolderPath, expectedFolderPath)
        end
        function readAllDays(testCase)
        %READALLDAYS Test the runtime for reading all days.
            
            % Alias testCase object.
            tc = testCase;

            % Number of files.
            nFiles = size(tc.fileReader.getFiles(), 1);

            for iFile = 1 : nFiles
                [data, success] = tc.fileReader.readDay(iFile);
            end
        end
        function testFilter(testCase)
            
            % Alias testCase object.
            tc = testCase;

            [data, ~] = tc.fileReader.readDay(1);
            tc.verifyEqual(size(data, 2), 9)
        end
    end
end