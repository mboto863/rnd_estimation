classdef FileReader < handle
    properties
        folderPath
    end
    methods
        function obj = FileReader(folderPath)
            arguments
                folderPath {mustBeTextScalar} = fullfile(...
                    FileReader.getProjectRoot(), "data")
            end
            obj.folderPath = folderPath;
        end
        function files = getFiles(obj)
        %FILES Retrieves a list of .csv files from the data folder
        % Input:
        %   obj     The FileReader object.
        %
        % Output:
        %   files   Column vector of strings of the names of the files.

            arguments
                obj FileReader
            end
            storedData = tabularTextDatastore(obj.folderPath, 'FileExtensions', '.csv');
            files      = string(storedData.Files);
        end
        function [data, success] = readDay(obj, day)
        %READDAY Read from the the file
        %
        % Input:
        %   obj     The FileReader object.
        %   day     Day to read.
        %
        % Output:
        %   data    Tablized data
        %   success Whether the file contains enough data to be used.

            arguments
                obj FileReader
                day int16
            end
            % get file list
            files = obj.getFiles();
            % read from file
            tablizedDay     = readtable(files(day));
            [data, success] = FileReader.filterTable(tablizedDay);
        end
    end
    methods (Static, Access = private)
        function [filtered, success] = filterTable(data)
        %FILTERTABLE Filters from tablized data.
        %
        % Input:
        %   data        Tablized data
        %   columns     Variables to be included
        %
        % Output:
        %   filtered    Filtered tablized data
        %   success     Whether the table contains enough data to be used

            arguments
                data table
            end

            % filter columns
            cnf = ColumnNamesConfig();
            c   = Constants();
            
            % cells do not support operator '=='
            data.(cnf.rootCycle)  = categorical(data.(cnf.rootCycle));
            data.(cnf.optionType) = categorical(data.(cnf.optionType));
            
            % Sort the data by ascending strike.
            data = sortrows(data, cnf.strike);
            
            % The call rows.
            callAsk    = data(data.(cnf.optionType) == c.callCodification, cnf.optionAsk);
            callAskRows = 1 : numel(callAsk);

            % The rows where the call ask is at the minimum tick value.
            callRowsMinimumTick = callAskRows(callAsk.(cnf.optionAsk) == 0.05);

            % The put rows.
            putAsk    = data(data.(cnf.optionType) == c.putCodification, cnf.optionAsk);
            putAskRows = 1 : numel(putAsk);

            % The rows where the put ask is at the minimum tick value.
            putRowsMinimumTick = putAskRows(putAsk.(cnf.optionAsk) == 0.05);

            % Remove the rows.
            rowsToRemove          = [putRowsMinimumTick(1 : (end - 1)), callRowsMinimumTick(2 : end)];
            data(rowsToRemove, :) = [];

            % Filter the option expiration pattern and maturity.
            filtered = data((data.(cnf.rootCycle) == c.expirationPattern) &...
                (data.(cnf.daysToMaturity) > c.minimumDaysToExpiration),...
                :);

            
            % filter ITM options
            filtered(((filtered.(cnf.optionType) == c.callCodification) &...
            (filtered.(cnf.strike) <= filtered.(cnf.futuresPrice))) |...
            ((filtered.(cnf.optionType) == c.putCodification) &...
            (filtered.(cnf.strike) >= filtered.(cnf.futuresPrice))), :) = [];

            % Pick first maturity.
            filtered = filtered(filtered.(cnf.maturity) == filtered.(cnf.maturity)(1), :);
            
            % Filter for variables not used in the estimation.
            filtered = filtered(:, c.estimationVariables);
            
            % Check if there is enough data for the estimation to take place.
            if height(filtered) <= c.minimumRows
                filtered = [];
                success  = false;
                return
            end
            success = true;
        end
        function root = getProjectRoot()
        %GETPROJECTROOT Retrieve the project root path
        %
        % Input:
        %
        % Output:
        %   root    Project root path.

            % Instanciate the matlab.project object for the root folder.
            project = matlab.project.rootProject();

            % If matlab's API is not able to initialize the project, get working directory.
            if isempty(project)
                root = pwd;
            
            else
                % Project successfully initialized by matlab's API
                root = project.RootFolder;

            end
        end
    end
end