classdef OutputHandler < handle
    properties
        logs struct = struct();
    end
    methods
        function addEntry(obj, name, value, day)
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
            %get(NAME) - retrieve the logged outputs for NAME
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
            %get all logs for all outputs
            records = obj.logs;
        end
    end
end