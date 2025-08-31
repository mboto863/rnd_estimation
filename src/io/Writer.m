classdef Writer
    properties
        parameterSetup
        outputHandler
    end
    methods
        % Constructor
        function obj = Writer(parameterSetup, outputHandler)
        obj.parameterSetup = parameterSetup;
        obj.outputHandler = outputHandler
        end

        % Handle the parameters.
        function writeParameters()
            % Get the parameter names from the model's ParameterSetup object.
            parameterNames = obj.parameterSetup.getNames();
            
            % Get the omega clause from the OutputHandler object.
            omegaClause = obj.outputHandler.getClause(parameterNames{1});

            days = omegaClause.keys; % Assuming every parameter clause has the same days.

            % The number of days in the logbook.
            nDays = numel(days);

            % The number of parameters in the model.
            nParameters = numel(parameterNames);

            % Prepare the table's header.
            header = [{'Day'}, parameterNames];

            dataCell = cell(nDays, nParameters + 1);

            for iDay = 1 : nDays
                % Store the day
                dataCell{iDay, 1} = days{iDay};

                for jParameter = 1 : nParameters
                    parameterName = parameterNames{jParameter};

                    % Get the parameter clause.
                    parameterClause = obj.outputHandler.getClause(parameterName);
                    
                    % The parameter state for the corresponding day.
                    parameterState = parameterClause(iDay);

                    % Store the state.
                    dataCell{iDay, jParameter + 1} = mat2str(parameterState); % Convert the state to string.
                end
            end

            % Convert to table and write
            T = cell2table(dataCell, "VariableNames", header);
            writetable(T, 'parameters.csv');
        end
    end
end