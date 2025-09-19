classdef Estimator < handle
    properties
        model char
        outputHandler OutputHandler
        fileReader FileReader
        valueHandler ValueHandler
        parameterSetup
        options = optimset(...
            'Display',...
            'none',...
            'TolFun',...
            1e-12,...
            'TolX',...
            1e-6);
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
            obj.parameterSetup = model.getParameterSetup();

            % initialize parameter values
            firstDataset = fileReader.readDay(1);
            names        = obj.parameterSetup.getNames();
            values       = obj.parameterSetup.initializeAll(firstDataset);
            
            obj.valueHandler = ValueHandler(obj.parameterSetup.dimension, names, values);
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
                obj.outputHandler.addRecord('percentError', percentError, day);
                
                % Informative logs.
                logger = PersistentLogger.getInstance();
                logger.writeInfo("fval: %d", structuredOutput.fval);
                logger.writeInfo("exit_flag: %d", structuredOutput.exit_flag);
                logger.writeInfo("from stucturedOutput, omega: [%s]", mat2str(structuredOutput.omega))
                logger.writeInfo("from valueHandler, omega: [%s]", mat2str(obj.valueHandler.getParameter('omega')))
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
        %   output          The output from the optimization algorithm. Is struct.

            arguments
                obj Estimator
                smoothData struct
            end

            % get values from value handler
            initialValues = obj.valueHandler.getVector();
            
            % get constraints
            lb = obj.parameterSetup.getAllLowerBounds();
            logger = PersistentLogger.getInstance();
            logger.writeDebug("lb: [%s]", mat2str(lb));
            wrappedConstraint = @(theta) feval(...
                obj.model+".getNonLinearConstraint",...
                theta,...
                obj.valueHandler,...
                smoothData.futuresPrice...
                );
            % to minimize sum of squared errors
            objectiveFunction = @(theta) obj.sumSquaredErrors(...
                theta,...
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
                lb,...
                [],...
                wrappedConstraint, ...
                obj.options...
                );
            % update parameter values
            obj.valueHandler.setVector(theta);
            logger.writeDebug("theta: [%s]", mat2str(theta));
            % The names of the parameters in value handler.
            names = obj.valueHandler.getParameterNames();

            % Update output handler.
            for iName = 1 : numel(names)
                output.(names{iName}) = obj.valueHandler.getParameter(names{iName});
            end

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
                'timeToMaturity', smoothData.timeToMaturity,...
                'underlyingMid', smoothData.underlyingMid...
                );

            % compute percent errors
            percentError = zeros(size(smoothData.putPrice));
            for iContract = 1 : numel(percentError)

                % Update strike and option price of contract.
                contractData.strike = smoothData.strike(iContract);
                contractData.putPrice = smoothData.putPrice(iContract);

                % Compute the percent error.
                percentError(iContract) = obj.computeError(parameters, contractData) / contractData.putPrice * 100;
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
        function error = sumSquaredErrors(obj, theta, smoothData)
        %SUMSQUAREDERRORS Computes the sum of the squared option model price errors
        %
        % Input:
        %   obj             The Estimator object.
        %   theta           The RND parameters
        %   smoothData      Data obtained from smoothing market data.
        %
        % Output:
        %   error           Summed squared errors

            arguments
                obj Estimator
                theta (1, :)
                smoothData struct
            end

            % update values
            obj.valueHandler.setVector(theta);
            
            % get structured values
            parameters = obj.valueHandler.getStructure();
            
            % Data from a single contract.
            contractData = struct(...
                'riskFreeRate', smoothData.riskFreeRate,...
                'dividendYield', smoothData.dividendYield,...
                'timeToMaturity', smoothData.timeToMaturity,...
                'underlyingMid', smoothData.underlyingMid...
                );


            % assign sum variable
            sumValue = 0;
            
            % Iterate over rows
            for iContract = 1 : numel(smoothData.putPrice)
                % Update strike and option price of contract.
                contractData.strike = smoothData.strike(iContract);
                contractData.putPrice = smoothData.putPrice(iContract);

                sumValue = sumValue + (obj.computeError(parameters, contractData) ^ 2);
            end
            error = sumValue;
        end
    end
end