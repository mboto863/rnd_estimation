function entryPoint()
    startupProject();
    main();
end

function main()
    disp('Entry point has triggered the main program logic.');
    % Choose the dimension of the mixture approximation.
    dimension = 2;

    % Choose the template of the risk neutral density.
    model = Student(dimension);

    % Initiate a file reader.
    fileReader = FileReader();

    % Initiate an estimator.
    estimator = Estimator(model, fileReader);

    % Estimate first day.
    estimator.estimateDay(1);

    % The outputs from the estimation.
    outputs = estimator.outputHandler;

    % Write the parameter outputs in CSV format.
    writer = Writer(model, outputs);
    writer.writeParameters();
    writer.writeMetrics();

    disp('Done')
end

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



