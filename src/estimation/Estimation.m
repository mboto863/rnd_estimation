classdef Estimation < handle
    properties
        model string
        outputHandler OutputHandler
        fileReader FileReader
        parameterSetup (1, 1)
        options = optimset('Display', 'none', 'TolFun', 1e-12, 'TolX', 1e-6);
    end
    methods
        function obj = Estimation(model, fileReader, parameterSetup)
            arguments
                model string
                fileReader FileReader
                parameterSetup (1, 1)
            end
            obj.model          = model;
            obj.outputHandler  = OutputHandler();
            obj.fileReader     = fileReader;
            obj.parameterSetup = parameterSetup;
        end
        function estimateDay(obj, day, valueHandler)
            
            % initialize parameter values
            [data, ok] = obj.fileReader.readDay(day);
            if ~ok
                return
            else
                % estimate
                structuredOutput = obj.estimateRiskNeutralDensity(valueHandler, data);
                percentError = obj.computePercentError(structuredOutput, data);
                
                % store outputs
                obj.outputHandler.addRecord('fval', structuredOutput.fval, day);
                obj.outputHandler.addRecord('exit_flag', structuredOutput.exit_flag, day);
                obj.outputHandler.addRecord('perc_error', percentError, day);
                
                % Informative logs.
                logger = PersistentLogger.getInstance();
                logger.writeInfo("fval: %d", structuredOutput.fval);
                logger.writeInfo("exit_flag: %d", structuredOutput.exit_flag);
                logger.writeInfo("perc_error: %d", percentError);

                for iName = 1 : size(valueHandler.names, 2)
                    name = valueHandler.names{iName};
                    obj.outputHandler.addRecord(name, valueHandler.getParameter(name), day);
                end

            end
        end
        function runEstimation(obj)
        %RUNESTIMATION  Run the estimation.
        %
        % Input:
        %   obj     Estimation object.
        %
        % Output:
        %
        
            arguments
                obj Estimation
            end
            % initialize parameter values
            firstDataset = obj.fileReader.readDay(1);            
            names        = obj.parameterSetup.getNames();            
            values       = obj.parameterSetup.initializeAll(firstDataset);
            % value handler instance
            valueHandler = ValueHandler(obj.parameterSetup.dimension, names, values);
            % get files
            files = obj.fileReader.getFiles();
            % iterate over days
            for iDay = 1 : size(files, 1)
                % check if day has enough data
                [data, ok] = obj.fileReader.readDay(iDay);
                if ~ok
                    continue;
                end
                % estimate
                structuredOutput = obj.estimateRiskNeutralDensity(...
                    valueHandler, data...
                    );
                % store outputs
                obj.outputHandler.addRecord(...
                    'fval',...
                    structuredOuput.fval,...
                    iDay...
                    );
                obj.outputHandler.addRecord(...
                    'exit_flag',...
                    structuredOuput.exit_flag,...
                    iDay...
                    );
                percentError = obj.computePercentError(...
                    structuredOuput,...
                    data...
                    );
                obj.outputHandler.addRecord(...
                    'perc_error',...
                    percentError,...
                    iDay...
                    );
                for jName = 1 : size(valueHandler.names, 2)
                    name = valueHandler.names{jName};
                    obj.outputHandler.addRecord(...
                        name,...
                        valueHandler.getParameter(name),...
                        iDay...
                        );
                end
            end
        end
    end
    methods (Access = private)
        function output = estimateRiskNeutralDensity(obj, valueHandler, data)
        %ESTIMATERISKNEUTRALDENSITY Estimates the risk neutral density
        %
        % Input:
        %   obj             The Estimation object.
        %   valueHandler    A ValueHandler object.
        %   data            Data to be used for the estimation.
        %
        % Output:
        %   output          The output from the optimization algorithm.

            arguments
                obj Estimation
                valueHandler ValueHandler
                data table
            end
            % get values from value handler
            initialValues = valueHandler.getVector();
            % get constraints
            wrappedConstraint = @(theta) feval(...
                obj.model+".getNonLinearConstraint",...
                theta,...
                valueHandler,...
                data...
                );
            % to minimize sum of squared errors
            objectiveFunction = @(theta) obj.sumSquaredErrors(...
                theta,...
                valueHandler,...
                data...
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
        function percentError = computePercentError(obj, parameters, data)
        %PERCENTERROR Computes percent error of option model price
        % Input:
        %   obj             The Estimation object.
        %   parameters      The parameters of the RND
        %   data            Tablized option data
        %
        % Output:
        %   percentError    Percent error of option model price

            arguments
                obj Estimation
                parameters struct
                data table
            end
            % Assign alias for column names configuration.
            c = ColumnNamesConfig();

            % only put data is being considered for percent error purposes
            putData = data(data.(c.optionType) == Constants.putCodification, :);
            
            % compute percent errors
            percentError = nan(size(putData.(c.optionType)));
            for iRow = 1:size(putData.(c.optionType),1)
                percentError(iRow) = obj.computeError(parameters,...
                    putData(iRow, :)) / putData.mid(iRow);
            end
        end
        function error = computeError(obj, parameters, data)
        %COMPUTEERROR Computes the error of option model price
        %
        % Input:
        %   obj         The Estimation object.
        %   parameters  The parameters of the RND
        %   data        Tablized option data
        %
        % Output:
        %   error       The error of option model price

            arguments
                obj Estimation
                parameters struct
                data (1, :)
            end
            error = feval(obj.model+".getPrice", parameters, data) -...
                data.(ColumnNamesConfig.optionMid);
        end
        function error = sumSquaredErrors(obj, theta, valueHandler, data)
        %SUMSQUAREDERRORS Computes the sum of the squared option model price errors
        %
        % Input:
        %   obj             The Estimation object.
        %   theta           The RND parameters
        %   valueHandler    A ValueHandler object.
        %   data            Tablized option data
        %
        % Output:
        %   error           Summed squared errors

            arguments
                obj Estimation
                theta (1, :)
                valueHandler ValueHandler
                data table
            end
            % Assign alias for column names configuration.
            c = ColumnNamesConfig();

            % update values
            valueHandler.setVector(theta);
            
            % get structured values
            parameters = valueHandler.getStructure();
            
            % assign sum variable
            sumValue = 0;
            
            % iterate over rows
            for iRow = 1 : size(data.(c.optionType), 1)
                % check option type                
                if data.(c.optionType)(iRow) == Constants.callCodification
                    % if call, get implicit put price
                    data.(c.optionMid)(iRow) = data.(c.optionMid)(iRow) - data.(c.underlyingMid)(iRow)...
                        * exp(-data.(c.dividendYield)(1) * data.(c.timeToMaturity)(1)) +...
                        data.(c.strike)(iRow) * exp(-data.(c.riskFreeRate)(1) * data.(c.timeToMaturity)(1));
                    sumValue       = sumValue + obj.computeError(parameters,...
                        data(iRow, :)) ^ 2;
                elseif data.(c.optionType)(iRow) == Constants.putCodification
                    sumValue = sumValue + obj.computeError(parameters,...
                        data(iRow, :)) ^ 2;
                end
            end
            error = sumValue;
        end
    end
end