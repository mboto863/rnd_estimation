function runGammaCalculatorPerformanceTests()
%PERFORMANCETESTS Run a performance test on the time consuming procedures of the project.
%
% Input:

% Run performance tests.
results = runperf("GammaCalculatorPerformanceTests");

% Convert results to a table.
summary = sampleSummary(results);

% Write to .csv.
writetable(summary, 'GammaCalculatorPerformance.csv');
end
