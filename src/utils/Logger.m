classdef Logger < handle
    properties (Access = private)
        logFileID
    end
    methods
        function obj = Logger(logsFilePath)
            if nargin < 1
                logsFilePath = fullfile(pwd, 'logs', 'rnd_estimation_logs.txt');
            else
                % Use path provided by user.
            end
            obj.logFileID = fopen(logsFilePath, 'a');
            if obj.logFileID == -1
                error('Cannot open log file: %s', logsFilePath);
            else
                obj.info("Logger started at %s", datetime("now"));
            end
        end
    end
    methods (Access = private)
        
end