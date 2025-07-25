classdef OutputHandler < handle
    properties
        logs struct = struct();
    end
    methods
        function addEntry(obj,name,value,day)
            arguments
                obj OutputHandler
                name string
                value
                day (1,1) double
            end
            if ~isfield(obj.logs,name)
                obj.logs.(name) = containers.Map('KeyType','double','ValueType','any');
            end
            obj.logs.(name)(day) = value;
        end
        function val = getRecords(obj,name)
            %get(NAME) - retrieve the logged outputs for NAME
            arguments
                obj OutputHandler
                name string
            end
            if isfield(obj.logs,name)
                val = obj.logs.(name);
            else
                error('Output not found for name=%s',name)
            end
        end
        function s = getAllRecords(obj)
            %get all logs for all outputs
            s = obj.logs;
        end
    end
end