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
            obj.model          = model;
            obj.outputHandler  = OutputHandler();
            obj.fileReader     = fileReader;
            obj.parameterSetup = parameterSetup;
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
            output.omega = valueHandler.get('omega');
            output.mu    = valueHandler.get('mu');
            output.sigma = valueHandler.get('sigma');
            output.nu    = valueHandler.get('nu');
            
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
            % only put data is being considered for percent error purposes
            putData = data(data.opt_type == 'p', :);
            
            % compute percent errors
            percentError = nan(size(putData.opt_type));
            for iRow = 1:size(putData.opt_type,1)
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
                data.mid;
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
                    sumValue       = sumValue + obj.computeError(parameters,...
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