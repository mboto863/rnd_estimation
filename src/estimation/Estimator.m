classdef Estimator < handle
    properties
        model char
        outputHandler OutputHandler
        fileReader FileReader
        valueHandler ValueHandler
        options = optimset('Display', 'none', 'TolFun', 1e-12, 'TolX', 1e-6);
    end
    methods
        function obj = Estimator(model, fileReader)
            arguments
                model
                fileReader FileReader
            end
            obj.model          = class(model);
            obj.outputHandler  = OutputHandler();
            obj.fileReader     = fileReader;
            
            % Get the parameter setup object.
            parameterSetup = model.getParameterSetup();

            % initialize parameter values
            firstDataset = fileReader.readDay(1);
            names        = parameterSetup.getNames();
            values       = parameterSetup.initializeAll(firstDataset);
            
            obj.valueHandler = ValueHandler(parameterSetup.dimension, names, values);
        end
        function estimateDay(obj, day)
        %ESTIMATEDAY Estimate the risk neutral density for a single day. Store outputs in an OutputHandler object.
        %
        % Input:
        %  obj             The Estimator object.
        %  day             The market day to estimate from.
        %
        % Output:
        %

            [data, ok] = obj.fileReader.readDay(day);
            if ~ok
                return
            else
                % Smooth the data.
                smoothData = DataSmoother.fitStrikeToImpliedVolatility(data);

                % Estimate
                structuredOutput = obj.estimateRiskNeutralDensity(smoothData);
                percentError = obj.computePercentError(structuredOutput, smoothData);
                
                
                % Store outputs
                obj.outputHandler.addRecord('fval', structuredOutput.fval, day);
                obj.outputHandler.addRecord('exit_flag', structuredOutput.exit_flag, day);
                obj.outputHandler.addRecord('perc_error', percentError, day);
                
                % Informative logs.
                logger = PersistentLogger.getInstance();
                logger.writeInfo("fval: %d", structuredOutput.fval);
                logger.writeInfo("exit_flag: %d", structuredOutput.exit_flag);

                for iName = 1 : size(obj.valueHandler.names, 2)
                    name = obj.valueHandler.names{iName};
                    obj.outputHandler.addRecord(name, obj.valueHandler.getParameter(name), day);
                end
            end
        end
        function runEstimation(obj)
        %RUNESTIMATION  Run the estimation.
        %
        % Input:
        %   obj     Estimator object.
        %
        % Output:
        %

            
            % Number of days.
            nDays = numel(obj.fileReader.getFiles());
            
            % Iterate over market days.
            for iDay = 1 : nDays
                
                % Estimate the risk neutral density for the ith market day.
                obj.estimateDay(iDay);
            end
        end
    end
    methods (Access = private)
        function output = estimateRiskNeutralDensity(obj, smoothData)
        %ESTIMATERISKNEUTRALDENSITY Estimates the risk neutral density
        %
        % Input:
        %   obj             The Estimator object.
        %   smoothData      Data obtained from the smoothing of market data.
        %
        % Output:
        %   output          The output from the optimization algorithm.

            arguments
                obj Estimator
                smoothData struct
            end

            % Cache the ValueHandler object.
            valueHandler = obj.valueHandler;

            % get values from value handler
            initialValues = valueHandler.getVector();
            
            % get constraints
            wrappedConstraint = @(theta) feval(...
                obj.model+".getNonLinearConstraint",...
                theta,...
                valueHandler,...
                smoothData.futuresPrice...
                );
            % to minimize sum of squared errors
            objectiveFunction = @(theta) obj.sumSquaredErrors(...
                theta,...
                valueHandler,...
                smoothData...
                );
            % optimization algorithm
            [theta,fval,exit_flag] = fmincon(...
                objectiveFunction,...
                initialValues,...
                [],...
                [],...
                [],...
                [],...
                [],...
                [],...
                wrappedConstraint, ...
                obj.options...
                );
            % update parameter values
            valueHandler.setVector(theta);
            output.omega = valueHandler.getParameter('omega');
            output.mu    = valueHandler.getParameter('mu');
            output.sigma = valueHandler.getParameter('sigma');
            output.nu    = valueHandler.getParameter('nu');
            
            % other optimization metrics
            output.fval      = fval;
            output.exit_flag = exit_flag;
        end
        function percentError = computePercentError(obj, parameters, smoothData)
        %PERCENTERROR Computes percent error of option model price
        % Input:
        %   obj             The Estimator object.
        %   parameters      The parameters of the RND
        %   smoothData            Smoothed option data.
        %
        % Output:
        %   percentError    Percent error of option model price

            arguments
                obj Estimator
                parameters struct
                smoothData struct
            end
            % Data from a single contract.
            contractData = struct(...
                'riskFreeRate', smoothData.riskFreeRate,...
                'dividendYield', smoothData.dividendYield,...
                'timeToMaturity', smoothData.timeToMaturity...
                );

            % compute percent errors
            percentError = zeros(size(smoothData.putPrice));
            for iContract = 1 : numel(percentError)

                % Update strike and option price of contract.
                contractData.strike = smoothData.strike(iContract);
                contractData.putPrice = smoothData.putPrice(iContract);

                % Compute the percent error.
                percentError(iContract) = obj.computeError(parameters, contractData) / contractData.putPrice;
            end
        end
        function error = computeError(obj, parameters, contractData)
        %COMPUTEERROR Computes the error of option model price
        %
        % Input:
        %   obj         The Estimator object.
        %   parameters  The parameters of the RND
        %   contractData        Contract market data. Must include strike, option price, riskFreeRate, dividendYield and timeToMaturity.
        %
        % Output:
        %   error       The error of option model price

            arguments
                obj Estimator
                parameters struct
                contractData struct
            end
            error = feval(obj.model + ".getPrice", parameters, contractData) - contractData.putPrice;
        end
        function error = sumSquaredErrors(obj, theta, valueHandler, smoothData)
        %SUMSQUAREDERRORS Computes the sum of the squared option model price errors
        %
        % Input:
        %   obj             The Estimator object.
        %   theta           The RND parameters
        %   valueHandler    A ValueHandler object.
        %   smoothData      Data obtained from smoothing market data.
        %
        % Output:
        %   error           Summed squared errors

            arguments
                obj Estimator
                theta (1, :)
                valueHandler ValueHandler
                smoothData struct
            end

            % update values
            valueHandler.setVector(theta);
            
            % get structured values
            parameters = valueHandler.getStructure();
            
            % Data from a single contract.
            contractData = struct(...
                'riskFreeRate', smoothData.riskFreeRate,...
                'dividendYield', smoothData.dividendYield,...
                'timeToMaturity', smoothData.timeToMaturity...
                );


            % assign sum variable
            sumValue = 0;
            
            % iterate over rows
            for iContract = 1 : numel(smoothData.putPrice)
                % % check option type                
                % if data.(c.optionType)(iRow) == Constants.callCodification
                %     % if call, get implicit put price
                %     data.(c.optionMid)(iRow) = data.(c.optionMid)(iRow) - data.(c.underlyingMid)(iRow)...
                %         * exp(-data.(c.dividendYield)(1) * data.(c.timeToMaturity)(1)) +...
                %         data.(c.strike)(iRow) * exp(-data.(c.riskFreeRate)(1) * data.(c.timeToMaturity)(1));
                %     sumValue       = sumValue + obj.computeError(parameters,...
                %         data(iRow, :)) ^ 2;
                % elseif data.(c.optionType)(iRow) == Constants.putCodification
                %     sumValue = sumValue + obj.computeError(parameters,...
                %         data(iRow, :)) ^ 2;
                % end

                % Update strike and option price of contract.
                contractData.strike = smoothData.strike(iContract);
                contractData.putPrice = smoothData.putPrice(iContract);

                sumValue = sumValue + (obj.computeError(parameters, contractData) ^ 2);
            end
            error = sumValue;
        end
    end
end