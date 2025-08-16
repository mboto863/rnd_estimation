classdef PersistentLogger < handle
    properties (Access = private)
        logFileId
    end
    methods (Access = private)
        function obj = PersistentLogger(logFilePath)
            
            % No file path is given.
            if nargin < 1
                
                % General logbook file path
                logFilePath = fullfile(pwd, 'logs', 'rnd_estimation_logbook.txt');
                
                % File path is given.
            else
                % Use path provided by user.
                
            end
            
            % Attempt to open the path and store the result.
            obj.logFileId = fopen(logFilePath, 'a');
            
            if obj.logFileId == -1
                % Attempt not sucsseful.
                error('Cannot open log file: %s', logFilePath);
            else
                % Attempt was sucsseful.
                obj.writeInfo("Logger started at %s", datetime("now"));
            end
        end
    end
    methods
        function writeInfo(obj, message, varargin)
            %INFO Commands to add an informative log entry.
            %
            % Input:
            %   obj         The Logger object.
            %   message     The informative message to log.
            %   varargin    Any extra parameters to be included in the log.
            %
            % Output:
            %
            % Commands to write.
            obj.writeToLogBook("INFO", message, varargin{:});
        end
        function writeWarning(obj, message, varargin)
            %WRITEWARNING Commands to add a warning log entry.
            %
            % Input:
            %   obj         The Logger object.
            %   message     The warning message to log.
            %   varargin    Any extra parameters to be included in the log.
            %
            % Ouput:
            %
            
            % Commands to write.
            obj.writeToLogBook("WARNING", message, varargin{:});
        end
        function writeError(obj, message, varargin)
            %WRITEERROR Commands to add an error log entry.
            %
            % Input:
            %   obj    The Logger object.
            %   message    The error message to log.
            %   varargin    Any extra parameters to be included in the log.
            %
            % Ouput:
            %
            
            % Commands to write.
            obj.writeToLogBook("ERROR", message, varargin{:});
        end
        
        % Destructor
        function delete(obj)
            if obj.logFileId > 0
                fclose(obj.logFileId);
            else
                % File not correctly open.
            end
        end
    end
    methods (Access = private)
        
        % This is a persistent logger. Construction needs to pass through this getter.
        function obj = getInstance(logFilePath)
            %GETINSTANCE Get a PersistentLogger instance.
            %
            % Input:
            %   logFilePath    Optionally give the log file to write to.
            %
            % Output:
            %   obj            The PersistentLogger object.
            
            % Make the instance persistent.
            persistent uniqueInstance
            
            % Should an instance be created?
            isToCreate = isempty(uniqueInstance) || ~isvalid(uniqueInstance);
            if isToCreate
                uniqueInstance = PersistentLogger(logFilePath);
                
            else
                % Give the logger.
                obj = uniqueInstance;
                
            end
        end
        function writeToLogBook(obj, level, message, varargin)
            %WRITELOG Adds a log entry to the log book.
            %
            % Input:
            %   obj    The Logger object.
            %   level    The level of the log.
            %   message    The message to log.
            %   varargin    Any extra parameters to be included in the message.
            %
            % Output:
            %
            
            timestamp   = datetime("now");
            fullMessage = sprintf(message, varargin{:});
            logEntry    = sprintf("[%s] [%s] %s", timestamp, level, fullMessage);
            
            % Print to console
            fprintf("%s\n", logEntry);
            
            % Write in the log book.
            fprintf(obj.logFileId, "%s\n", logEntry);
        end
    end
end