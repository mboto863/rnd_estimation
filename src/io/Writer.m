classdef Writer
    properties
        model
        parameterSetup
        outputHandler
    end
    methods
        % Constructor
        function obj = Writer(model, outputHandler)
            obj.model = model;
            obj.parameterSetup = model.getParameterSetup();
            obj.outputHandler = outputHandler;
        end
        function createComparisonPlot(obj)
            fileReader = FileReader();
            days       = obj.getDays();
            plotDay    = days{1};

            [data, ~]  = fileReader.readDay(plotDay);
            
            % Get the parameter estimation outputs.
            modelName = class(obj.model);
            switch modelName
                case "Student"
                    omegaClause = obj.outputHandler.getClause('omega');
                    nuClause    = obj.outputHandler.getClause('nu');
                    muClause    = obj.outputHandler.getClause('mu');
                    sigmaClause = obj.outputHandler.getClause('sigma');
                    parameters  = struct(...
                        'omega', omegaClause(plotDay),...
                        'nu', nuClause(plotDay),...
                        'mu', muClause(plotDay),...
                        'sigma', sigmaClause(plotDay)...
                    );
                case "Lognormal"
                    omegaClause = obj.outputHandler.getClause('omega');
                    muClause = obj.outputHandler.getClause('mu');
                    sigmaClause = obj.outputHandler.getClause('sigma');
                    parameters = struct(...
                        'omega', omegaClause(plotDay),...
                        'mu', muClause(plotDay),...
                        'sigma', sigmaClause(plotDay)...
                    );
            end
            smoothData = DataSmoother.fitStrikeToImpliedVolatility(data);
            % Data from a single contract.
            contractData = struct(...
                'riskFreeRate', smoothData.riskFreeRate,...
                'dividendYield', smoothData.dividendYield,...
                'timeToMaturity', smoothData.timeToMaturity,...
                'underlyingMid', smoothData.underlyingMid...
                );

            % Iterate over rows
            modelPrice = nan(size(smoothData.strike));
            for iContract = 1 : numel(smoothData.putPrice)
                % Update strike and option price of contract.
                contractData.strike   = smoothData.strike(iContract);
                contractData.putPrice = smoothData.putPrice(iContract);
                modelPrice(iContract) = obj.model.getPrice(parameters, contractData);
            end

            % Create the comparison plot.
            figure; % Open a new figure window.
            logger = PersistentLogger.getInstance();
            logger.writeDebug("smoothData.strike: [%s]", mat2str(smoothData.strike));
            plot(smoothData.strike, smoothData.putPrice, 'b-', 'LineWidth', 2, 'DisplayName', 'Benchmark');
            hold on; % Keep the plot active
            plot(smoothData.strike, modelPrice, 'r--', 'LineWidth', 2, 'DisplayName', 'Model Price');

            % Customize the plot.
            title('Model to Benchmark Price Comparison', 'FontSize', 14);
            xlabel('Strike', 'FontSize', 12);
            ylabel('Option Price', 'FontSize', 12);
            legend('show'); % Display a legend.
            grid on;
            hold off; % Release the plot.
            
            % Save figure to the current working directory.
            saveas(gcf, 'price_comparison_plot.png'); 
        end
        function days = getDays(obj)
            clause = obj.outputHandler.getClause('exit_flag');

            days = clause.keys; % Assuming every parameter clause has the same days.
        end
        % Handle the parameters.
        function writeParameters(obj)

            % Get the parameter names from the model's ParameterSetup object.
            parameterNames = obj.parameterSetup.getNames();

            days = obj.getDays(); % Assuming every parameter clause has the same days.
            nDays = numel(days);

            % The number of parameters in the model.
            nParameters = numel(parameterNames);

            % Prepare the table's header.
            header = [{'Day'}, parameterNames];

            dataCell = cell(nDays, nParameters + 1);

            for iDay = 1 : nDays
                % Store the day
                dataCell{iDay, 1} = days{iDay};

                for jParameter = 1 : nParameters
                    parameterName = parameterNames{jParameter};

                    % Get the parameter clause.
                    parameterClause = obj.outputHandler.getClause(parameterName);
                    
                    % The parameter state for the corresponding day.
                    parameterState = parameterClause(iDay);

                    % Store the state.
                    dataCell{iDay, jParameter + 1} = mat2str(parameterState); % Convert the state to string.
                end
            end

            % Convert to table and write
            T = cell2table(dataCell, "VariableNames", header);
            writetable(T, 'parameters.csv');
        end

        % Handle the metrics.
        function writeMetrics(obj)

            % Get the estimation days.
            days = obj.getDays();
            nDays = numel(days);

            optimizationMetrics  = {'fval', 'exit_flag'};
            nOptimizationMetrics = numel(optimizationMetrics);
            

            % Prepare the table's header.
            header = [{'Day'}, optimizationMetrics];

            percentErrorColumns = {...
                'MeanPE',...
                'MedianPE',...
                'StdPE',...
                'MinPE',...
                'MaxPE',...
                'q25PE',...
                'q75PE',...
                'SkewnessPE',...
                'KurtosisPE'...
                };

            dataCell = cell(nDays, nOptimizationMetrics + 1);

            for iDay = 1 : nDays
                % Store the day
                dataCell{iDay, 1} = days{iDay};
                for jMetric = 1 : nOptimizationMetrics

                    % Get the parameter clause.
                    metricClause = obj.outputHandler.getClause(optimizationMetrics{jMetric});
                    
                    % The parameter state for the corresponding day.
                    metricState = metricClause(iDay);

                    % Store the state.
                    dataCell{iDay, jMetric + 1} = mat2str(metricState); % Convert the state to string.
                end
            end
            
            % Convert to table and write
            T = cell2table(dataCell, "VariableNames", header);

            % Create the columns for the statistics of percent error.
            nanMatrix = nan(size(T.Day));
            for iColumn = 1 : numel(percentErrorColumns)
                T.(percentErrorColumns{iColumn}) = nanMatrix;
            end
            
            % Get the percentError clause of the logbook.
            percentErrorClause = obj.outputHandler.getClause('percentError');

            for iEstimation = 1 : nDays
                tempPercentError = percentErrorClause(iEstimation);
                logger = PersistentLogger.getInstance();
                logger.writeDebug("tempPercentError: [%s]", mat2str(tempPercentError));
                T.MeanPE(iEstimation) = mean(tempPercentError);
                T.MedianPE(iEstimation) = median(tempPercentError);
                T.StdPE(iEstimation) = std(tempPercentError);
                T.MinPE(iEstimation) = min(tempPercentError);
                T.MaxPE(iEstimation) = max(tempPercentError);
                T.q25PE(iEstimation) = prctile(tempPercentError, 25);
                T.q75PE(iEstimation) = prctile(tempPercentError, 75);
                T.SkewnessPE(iEstimation) = skewness(tempPercentError);
                T.KurtosisPE(iEstimation) = kurtosis(tempPercentError);
            end

            % Write the table in CSV format.
            writetable(T, 'metrics.csv');
        end
    end
end