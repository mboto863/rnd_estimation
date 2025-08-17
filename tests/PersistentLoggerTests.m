classdef PersistentLoggerTests < matlab.unittest.TestCase
    
    % Tests.
    methods (Test)
        
        % Fast test.
        function test(tc)
            
            % Get the PersitentLogger object.
            logger = PersistentLogger.getInstance();
            
            % Log something
            logger.writeInfo("some info");
        end
    end
end