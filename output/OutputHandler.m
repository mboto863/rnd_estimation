classdef OutputHandler < handle
    properties
        logs struct = struct();
    end
    methods
        function addEntry(obj, name, value, day)
        %ADDENTRY   Adds a log entry.
        %
        % Input:
        %   obj     The OutputHandler object.
        %   name    The name of the log entry.
        %   value   The value of the log entry.
        %   day     The day of the log entry.
        %
        % Output:
        %

            arguments
                obj OutputHandler
                name string
                value
                day (1, 1) double
            end
            if ~isfield(obj.logs, name)
                obj.logs.(name) = containers.Map('KeyType', 'double',...
                    'ValueType', 'any');
            end
            obj.logs.(name)(day) = value;
        end
        function records = getRecords(obj, name)
        %GETRECORDS Retrieve the logged outputs
        %
        % Input:
        %   obj         The OutputHandler object.
        %   name        The Name of the log entries to retrieve.
        %
        % Output:
        %   records     The records of the logbook.

            arguments
                obj OutputHandler
                name string
            end
            if isfield(obj.logs, name)
                records = obj.logs.(name);
            else
                error('Output not found for name=%s', name)
            end
        end
        function records = getAllRecords(obj)
        %GETALLRECORDS Retrieves all the records.
        %
        % Input:
        %   obj         The OutputHandler object.
        %
        % Output:
        %   records     The records.
        
            records = obj.logs;
        end
    end
end