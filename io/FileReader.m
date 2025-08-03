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
        function [filtered, success] = filterTable(data, columns)
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
                columns string = [...
                "root_cycle", "t", "T", "tau_d", "tau", "opt_type", "K", "bid", "mid", "ask", "vol", "oi", "under_bid",...
                "under_mid", "under_ask", "r", "P", "F", "divyield", "IV"]
            end

            % filter columns
            data = data(:, columns);
            
            % cells do not support operator '=='
            data.root_cycle = categorical(data.root_cycle);
            data.opt_type   = categorical(data.opt_type);
            
            expirationPattern       = "SPX7"; % Options that expire on the third friday of the month.
            minimumDaysToExpiration = 7; % Choose only options with more than 7 days to expiration.
            
            
            filtered = data((data.root_cycle == expirationPattern) & (data.tau_d > minimumDaysToExpiration) &...
            (data.bid > Constants.minimumTickValue), :);                     
            
            % filter ITM options
            filtered(((filtered.opt_type == Constants.callCodification) & (filtered.K <= filtered.F)) |...
            ((filtered.opt_type == Constants.putCodification) & (filtered.K >= filtered.F)), :) = [];

            % pick first maturity
            filtered = filtered(filtered.T == filtered.T(1), :);

            % check if enough data
            minimumRows  = 5; % Minimum number of rows to procceed with the estimation
            if height(filtered) <= minimumRows
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

            root = matlab.project.rootProject().RootFolder;
        end
    end
end