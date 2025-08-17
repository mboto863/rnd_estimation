function runHypergeometricCalculatorPerformanceTests()
%PERFORMANCETESTS Run a performance test on the time consuming procedures of the project.
%
% Input:

% Run performance tests.
results = runperf("HypergeometricCalculatorTests");

% Convert results to a table.
summary = sampleSummary(results);

% Write to .csv.
writetable(summary, 'HypergeometricCalculatorPerformance.csv');
end
