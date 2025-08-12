classdef FileReader
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
            % data = data(:, columns);
            c = ColumnNamesConfig();
            
            % cells do not support operator '=='
            data.(c.rootCycle) = categorical(data.(c.rootCycle));
            data.(c.optionType)   = categorical(data.(c.optionType));
            
            
            
            filtered = data((data.(c.rootCycle) == Constants.expirationPattern) &...
            (data.(c.daysToMaturity) > Constants.minimumDaysToExpiration) &...
            (data.(c.optionBid) > Constants.minimumTickValue), :);                     
            
            % filter ITM options
            filtered(((filtered.(c.optionType) == Constants.callCodification) &...
            (filtered.(c.strike) <= filtered.(c.futuresPrice))) |...
            ((filtered.(c.optionType) == Constants.putCodification) &...
            (filtered.(c.strike) >= filtered.(c.futuresPrice))), :) = [];

            % Pick first maturity.
            filtered = filtered(filtered.(c.maturity) == filtered.(c.maturity)(1), :);
            
            % Filter for variables not used in the estimation.
            estimationVariables = [];
            for variable = Constants.estimationVariables
                estimationVariables = [estimationVariables, variable];
            end
            filtered = filtered(:, estimationVariables);
            % check if enough data
            if height(filtered) <= Constants.minimumRows
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