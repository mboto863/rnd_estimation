function startup()
    root = matlab.project.rootProject().RootFolder;
    % Add as new folders are implemented.
    addpath(fullfile(root,"utils"));
    addpath(fullfile(root,"params"));
    addpath(fullfile(root,"output"));
    addpath(fullfile(root,"model"));
    addpath(fullfile(root,"io"));
    addpath(fullfile(root,"estimation"));
    addpath(fullfile(root,"data"));    
end