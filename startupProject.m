function startupProject()
%STARTUPPROJECT add all relevant paths to MATLAB's path
%
% Input:
%
% Output:
%

    try
        % Try to get the project root using the Project API
        root = matlab.project.rootProject().RootFolder;
    catch
        root = pwd;
        
    end
    
    % Add as new folders are implemented.
    folders = ["data", "estimation", "io", "model", "output", "params", "tests", "utils"];
    for f = folders
        folderPath = fullfile(root, f);
        if isfolder(folderPath)
            addpath(folderPath);
        else
            warning("Folder not found: %s", folderPath);
        end
    end
   % addpath(fullfile(root,"params"));
   % addpath(fullfile(root,"utils"));
   % addpath(fullfile(root,"output"));
   % addpath(fullfile(root,"model"));
   % addpath(fullfile(root,"io"));
   % addpath(fullfile(root,"estimation"));
   % addpath(fullfile(root,"data"));
   % addpath(fullfile(root, "tests"));
end