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
            arguments
                obj FileReader
            end
            storedData = tabularTextDatastore(obj.folderPath,...
                'FileExtensions', '.csv');
            files = string(storedData.Files);
        end
        function [data, success] = readDay(obj, day)
            arguments
                obj FileReader
                day int16
            end
            files = obj.getFiles();
            tablizedDay = readtable(files(day));
            [data, success] = FileReader.filterTable(tablizedDay);            
        end
    end
    methods (Static, Access = private)
        function [filtered, success] = filterTable(data, columns)
            arguments
                data table
                columns string = [...
                "root_cycle", "t", "T", "tau_d", "tau", "opt_type", "K",...
                "bid", "mid", "ask", "vol", "oi", "under_bid", "under_mid",...
                "under_ask", "r", "P", "F", "divyield", "IV"...
                ]
            end

            % filter columns
            data = data(:, columns);
            
            % cells do not support operator '=='
            data.root_cycle = categorical(data.root_cycle);
            data.opt_type = categorical(data.opt_type);

            % basic filters
            filtered = data((data.root_cycle == "SPX7") & (data.tau_d > 7)...
                & (data.bid > 0.05), :);                     

            % filter ITM options
            filtered(...
                ((filtered.opt_type == 'c') &...
                (filtered.K <= filtered.F)) |...
                ((filtered.opt_type == 'p') &...
                (filtered.K >= filtered.F)),...
                :)...
                = [];

            % pick first maturity
            filtered = filtered(filtered.T == filtered.T(1), :);

            % check if enough data
            if height(filtered) <= 5
                filtered = [];
                success = false;
                return
            end
            success = true;
        end
        function root = getProjectRoot()
            root = matlab.project.rootProject().RootFolder;
        end
    end
end