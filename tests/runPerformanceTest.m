function runPerformanceTest()
%RUNPERFORMANCETEST Run a performance test on the time consuming procedures of the project.
%
% Input:
%
% Output:
%
    % Create logger object.
    logger = Logger(fullfile(pwd, "logs", "performance_logs.txt"));

    % Let the FileReader object read all days.
    readAllDaysResult = run(FileReaderTests, "readAllDays");

    % Log the performance.
    logger.writeInfo("FileReader read all days task Runtime: %d seconds.", readAllDaysResult.Duration);

end
