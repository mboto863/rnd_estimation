classdef FileReader
    properties
        folderPath
    end
    methods
        function obj = FileReader(folderPath)
            arguments
                folderPath {mustBeTextScalar} = fullfile(...
                    FileReader.getProjectRoot(),"data")
            end
            obj.folderPath = folderPath;
        end
        function l = getFiles(obj)
            arguments
                obj FileReader
            end
            ds = tabularTextDatastore(obj.folderPath,'FileExtensions',...
                '.csv');
            l = string(ds.Files);
        end
        function [data,success] = readDay(obj,day)
            arguments
                obj FileReader
                day int16
            end
            files = obj.getFiles();
            tbl = readtable(files(day));
            [data,success] = FileReader.filter(tbl);            
        end
    end
    methods (Static, Access = private)
        function [filtered,success] = filter(data,columns,maturity)
            arguments
                data table
                columns string = [...
                "root_cycle","t","T","tau_d","tau","opt_type","K","bid",...
                "mid","ask","vol","oi","under_bid","under_mid","under_ask",...
                "r","P","F","divyield","IV"...
                ]
                maturity string = "16/06/2023 09:30:00" %%%%
            end
            data = data(:,columns);
            filtered = data((data.root_cycle == "SPX7") & (data.tau_d > 7)...
                & (data.bid > 0.05) & (data.T == maturity),:);
            if height(filtered) <= 5
                filtered = [];
                success = false;
                return
            end
            filtered.opt_type = categorical(filtered.opt_type);
            success = true;
        end
        function root = getProjectRoot()
            root = matlab.project.rootProject().RootFolder;
        end
    end
end