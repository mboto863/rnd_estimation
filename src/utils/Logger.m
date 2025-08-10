classdef Logger < handle
    properties (Access = private)
        logFileId
    end
    methods
        function obj = Logger(logsFilePath)
            if nargin < 1
                logsFilePath = fullfile(pwd, 'logs', 'rnd_estimation_log_book.txt');
            else
                % Use path provided by user.
            end
            obj.logFileId = fopen(logsFilePath, 'a');
            if obj.logFileId == -1
                error('Cannot open log file: %s', logsFilePath);
            else
                obj.writeInfo("Logger started at %s", datetime("now"));
            end
        end
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