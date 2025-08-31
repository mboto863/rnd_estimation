classdef OutputHandler < handle
    properties (Access = private)
        logbook = struct();
    end
    methods
        function addRecord(obj, clause, state, day)
        %ADDRECORD   Adds a log record.
        %
        % Input:
        %   obj       The OutputHandler object.
        %   clause    The clause of the logbook from which a new record should be added.
        %   state     The state of the clause at time day.
        %   day       The day of the log record.
        %
        % Output:
        %

            arguments
                obj OutputHandler
                clause string
                state
                day (1, 1) double
            end
            if ~isfield(obj.logbook, clause)
                obj.logbook.(clause) = containers.Map('KeyType', 'double',...
                    'ValueType', 'any');
            end
            obj.logbook.(clause)(day) = state;
        end
        function records = getClause(obj, clause)
        %GETCLAUSE(OBJ, CLAUSE) Retrieve the logged outputs from clause CLAUSE.
        %
        % Input:
        %   obj           The OutputHandler object.
        %   clause        The clause defines the section in the logbook from which retrieval is to take place. 
        %
        % Output:
        %   records       The records of the logbook.

            arguments
                obj OutputHandler
                clause
            end
            if isfield(obj.logbook, clause)
                records = obj.logbook.(clause);
            else
                error('Output not found for clause=%s', clause)
            end
        end
        function logbook = getLogbook(obj)
        %GETLOGBOOK Retrieves the logbook.
        %
        % Input:
        %   obj         The OutputHandler object.
        %
        % Output:
        %   logbook     The logbook.
        
            logbook = obj.logbook;
        end
    end
end