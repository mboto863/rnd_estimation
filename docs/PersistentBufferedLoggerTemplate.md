# A persistent logger with buffering for performance.

```matlab
classdef Logger < handle
    %LOGGER Singleton, buffered logging utility

    properties (Access = private)
        buffer cell = {}       % Holds log entries before flush
        bufferSize double = 50 % Number of messages to keep in memory before writing
        logFile string         % Path to log file
    end

    methods (Access = private)
        function obj = Logger(logFilePath)
            if nargin < 1
                logFilePath = fullfile(pwd, 'logs', 'app.log');
            end
            obj.logFile = logFilePath;

            % Ensure log folder exists
            logFolder = fileparts(logFilePath);
            if ~exist(logFolder, 'dir')
                mkdir(logFolder);
            end
        end
    end

    methods (Static)
        function obj = getInstance(logFilePath)
            persistent uniqueInstance
            if isempty(uniqueInstance) || ~isvalid(uniqueInstance)
                uniqueInstance = Logger(logFilePath);
            end
            obj = uniqueInstance;
        end
    end

    methods
        function log(obj, message)
            % Timestamp and store in buffer
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
            obj.buffer{end+1} = sprintf('[%s] %s', timestamp, message);

            % Flush if buffer is full
            if numel(obj.buffer) >= obj.bufferSize
                obj.flush();
            end
        end

        function flush(obj)
            if isempty(obj.buffer), return; end

            fid = fopen(obj.logFile, 'a');
            if fid ~= -1
                fprintf(fid, '%s\n', obj.buffer{:});
                fclose(fid);
            end

            obj.buffer = {}; % Clear buffer
        end

        function delete(obj)
            % Ensure we flush before the logger is destroyed
            obj.flush();
        end
    end
end
```
