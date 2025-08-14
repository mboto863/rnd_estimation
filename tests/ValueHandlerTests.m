classdef ValueHandlerTests < matlab.unittest.TestCase
    properties
        valueHandler
    end
    % Class based setup.
    methods (TestMethodSetup)
        
        % Constructor tests.
        function Construct(testCase)

            % Constructor arguments.
            dimension = 2;
            names     = {'omega', 'foo', 'bar'};
            values    = [0.5, 1, 1, 0, 0];

            % Construct ValueHandler object.
            testCase.valueHandler = ValueHandler(dimension, names, values);

        end
    end

    % Tests.
    methods (Test)

        % Test if construction was as expected.
        function testConstructor(testCase)
            
            % Import the HasField function.
            import matlab.unittest.constraints.HasField

            % Alias testCase object.
            tc = testCase;

            % Verify ValueHandler object properties
            tc.verifyEqual(tc.valueHandler.lengths, [1, 2, 2]);
            tc.verifyEqual(tc.valueHandler.names, {'omega', 'foo', 'bar'});
            tc.verifyThat(tc.valueHandler.state, HasField('omega'));
            tc.verifyThat(tc.valueHandler.state, HasField('foo'));
            tc.verifyThat(tc.valueHandler.state, HasField('bar'));
        end

        % Test setVector method.
        function testSetter(testCase)

            % Alias testCase object.
            tc = testCase;

            % Set new values.
            tc.valueHandler.setVector([0, 0, 0, 1, 0]);

            % Verify is set successfully.
            tc.verifyEqual(tc.valueHandler.state.omega, 0);
            tc.verifyEqual(tc.valueHandler.state.foo, [0, 0]);
            tc.verifyEqual(tc.valueHandler.state.bar, [1, 0]);
        end

        % Test getVector, getStructure, getParameter methods.
        function testGetter(testCase)
            
            % Alias testCase object.
            tc = testCase;

            % Get vector
            vector = tc.valueHandler.getVector();

            % Expected vector.
            expectedVector = [0.5, 1, 1, 0, 0];

            % Get structure.
            structure = tc.valueHandler.getStructure();

            % Expected structure.
            expectedStructure = struct(...
                                'omega', 0.5,...
                                'foo', [1, 1],...
                                'bar', [0, 0]);

            % Get parameters
            omega = tc.valueHandler.getParameter('omega');
            foo   = tc.valueHandler.getParameter('foo');
            bar   = tc.valueHandler.getParameter('bar');

            % Expected parameters.
            expectedomega = 0.5;
            expectedfoo   = [1, 1];
            expectedbar   = [0, 0];

            % Test getters.
            tc.verifyEqual(vector, expectedVector);
            tc.verifyEqual(structure, expectedStructure);
            tc.verifyEqual(omega, expectedomega);
            tc.verifyEqual(foo, expectedfoo);
            tc.verifyEqual(bar, expectedbar);

        end
    end
end