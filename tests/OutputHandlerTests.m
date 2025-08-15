classdef OutputHandlerTests < matlab.unittest.TestCase
    properties
        outputHandler
    end

    % Class based setup.
    methods (TestClassSetup)

        % Construct and setup an OutputHandler object.
        function setupOutputHandlerObject(testCase)
            testCase.outputHandler = OutputHandler();

            % Record values.
            state = 0.56;
            day   = 20;

            % Add entry.
            testCase.outputHandler.addRecord("foo", state, day);
        
        end
    end

    % Tests.
    methods (Test)
        
        % Test addRecord method.
        function testAddingRecords(testCase)

            % Alias testCase object.
            tc = testCase;

            % Import HasField function.
            import matlab.unittest.constraints.HasField
            
            % Test logs property.
            tc.verifyThat(tc.outputHandler.logbook, HasField("foo"));

            % Test record.
            tc.verifyEqual(tc.outputHandler.logbook.foo(20), 0.56);

        end

        % Test getClauseRecords method.
        function testRetrieval(testCase)

            % Alias testCase object.
            tc = testCase;

            % Get 'foo' variable records.
            fooClause = tc.outputHandler.getClauseRecords("foo");

            % Test result.
            assert(abs(fooClause(20) - 0.56) < 1e-12);

        end

        % Test getLogBook method.
        function testFullRetrieval(testCase)

            % Alias testCase object.
            tc = testCase;

            % Add some more variables.
            tc.outputHandler.addRecord("bar", 11.2, 1);
            tc.outputHandler.addRecord("foo", 11.2, 1);

            % Retrieve logbook.
            logbook = tc.outputHandler.getLogbook();

            % Import function HasField.
            import matlab.unittest.constraints.HasField

            % Test logbook variables.
            tc.verifyThat(logbook, HasField("foo"));
            tc.verifyThat(logbook, HasField("bar"));
            
            % Test records.
            assert(abs(logbook.foo(20) - 0.56) < 1e-12);
            assert(abs(logbook.foo(1) - 11.2) < 1e-12);
            assert(abs(logbook.bar(1) - 11.2) < 1e-12);

        end
    end
end