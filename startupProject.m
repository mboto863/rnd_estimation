function startupProject()
%STARTUPPROJECT add all relevant paths to MATLAB's path
%
% Input:
%
% Output:
%
    project = matlab.project.rootProject();
    % Check if a matlab project is currently open.
    if isempty(project)
        root = pwd;
    else
        root = matlab.project.rootProject().RootFolder;
    end
    % Add folders in the root.
    addpath(fullfile(root, "tests"));
    addpath(fullfile(root, "data"));

    % Add as new folders are implemented.
    folders = ["estimation", "io", "model", "output", "params", "utils", "config"];
    for f = folders
        folderPath = fullfile(root, "src", f);
        if isfolder(folderPath)
            addpath(folderPath);
        else
            warning("Folder not found: %s", folderPath);
        end
    end
end