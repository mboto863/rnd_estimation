classdef Estimation < handle
    properties
        model string
        outputHandler OutputHandler
        fileReader FileReader
        parameterSetup (1, 1)
        options = optimset('Display', 'none', 'TolFun', 1e-6, 'TolX', 1e-6);
    end
    methods
        function obj = Estimation(model, fileReader, parameterSetup)
            arguments
                model string
                fileReader FileReader
                parameterSetup (1, 1)
            end
            obj.model = model;
            obj.outputHandler = OutputHandler();
            obj.fileReader = fileReader;
            obj.parameterSetup = parameterSetup;
        end
        function runEstimation(obj)
            arguments
                obj Estimation
            end
            % initialize parameter values
            firstDataset = obj.fileReader.readDay(1);            
            names = obj.parameterSetup.getNames();            
            values = obj.parameterSetup.initializeAll(firstDataset);
            % value handler instance
            valueHandler = ValueHandler(...
                obj.parameterSetup.dimension,...
                names,...
                values...
                );
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
                structuredOuput = obj.estimateRiskNeutralDensity(...
                    valueHandler, data...
                    );
                % store outputs
                obj.outputHandler.addEntry(...
                    'fval',...
                    structuredOuput.exit_flag,...
                    iDay...
                    );
                obj.outputHandler.addEntry(...
                    'exit_flag',...
                    structuredOuput.exit_flag,...
                    iDay...
                    );
                percentError = obj.computePercentError(...
                    structuredOuput,...
                    data...
                    );
                obj.outputHandler.addEntry(...
                    'perc_error',...
                    percentError,...
                    iDay...
                    );
                for jName = 1 : size(valueHandler.names, 2)
                    name = valueHandler.names{jName};
                    obj.outputHandler.addEntry(...
                        name,...
                        valueHandler.get(name),...
                        iDay...
                        );
                end
            end
        end
    end
    methods (Access = private)
        function s = estimateRiskNeutralDensity(obj, valueHandler, data)
            arguments
                obj Estimation
                valueHandler ValueHandler
                data table
            end
            % get values from value handler
            initialValues = valueHandler.getVector();
            % get constraints
            staticBounds = {...
                obj.parameterSetup.getAllLowerBounds(),...
                obj.parameterSetup.getAllUpperBounds()...
                };
            wrappedConstraint = @(theta) feval(...
                obj.model+".getnonLinearConstraint",...
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
                staticBounds{1},...
                staticBounds{2},...
                wrappedConstraint, ...
                obj.options...
                );
            % update parameter values
            valueHandler.setVector(theta);
            s.omega = valueHandler.get('omega');
            s.mu = valueHandler.get('mu');
            s.sigma = valueHandler.get('sigma');
            s.nu = valueHandler.get('nu');
            % other optimization metrics
            s.fval = fval;
            s.exit_flag = exit_flag;
        end
        function percentError = computePercentError(obj, parameters, data)
            % only put data is being considered for percent error purposes
            arguments
                obj Estimation
                parameters struct
                data table
            end
            % filter data
            putData = data(data.opt_type == 'p', :);
            % compute percent errors
            percentError = nan(size(putData.opt_type));
            for iRow = 1:size(putData.opt_type,1)
                percentError(iRow) = obj.computeError(parameters,...
                    putData(iRow, :)) / putData.mid(iRow);
            end
        end
        function error = computeError(obj, parameters, data)
            arguments
                obj Estimation
                parameters struct
                data (1, :)
            end
            error = feval(obj.model+".getPrice", parameters, data) -...
                data.mid;
        end
        function error = sumSquaredErrors(obj, theta, valueHandler, data)
            arguments
                obj Estimation
                theta (1, :)
                valueHandler ValueHandler
                data table
            end
            % update values
            valueHandler.setVector(theta);
            % get structured values
            parameters = valueHandler.getStructure();
            % assign sum variable
            sumValue = 0;
            % iterate over rows
            for iRow = 1 : size(data.opt_type, 1)
                % check option type                
                if data.opt_type(iRow) == 'c'
                    % if call, get implicit put price
                    data.mid(iRow) = data.mid(iRow) - data.under_mid(iRow)...
                        * exp(-data.divyield(1) * data.tau(1)) +...
                        data.K(iRow) * exp(-data.r(1) * data.tau(1));
                    sumValue = sumValue + obj.computeError(parameters,...
                        data(iRow, :)) ^ 2;
                elseif data.opt_type(iRow) == 'p'
                    sumValue = sumValue + obj.computeError(parameters,...
                        data(iRow, :)) ^ 2;
                end
            end
            error = sumValue;
        end
    end
end