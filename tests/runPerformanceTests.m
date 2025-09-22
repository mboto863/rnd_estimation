function runPerformanceTests(test)
%PERFORMANCETESTS Run a performance test on the time consuming procedures of the project.
%
% Input:

switch test
    case "Calculator"
        % Run performance tests.
        results = runperf("CalculatorPerformanceTests");
    case "HypergeometricMixture"
        % Run performance tests.
        results = runperf("HypergeometricMixtureTests");
    otherwise
        error('Unknown performance test.');
end
% Convert results to a table.
summary = sampleSummary(results);

% Write to .csv.
writetable(summary, 'HypergeometricCalculatorPerformance.csv');

end
