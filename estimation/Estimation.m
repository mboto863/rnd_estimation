classdef Estimation < handle
    properties
        model string
        oh OutputHandler
        fr FileReader
        ps (1,1)
        options = optimset('Display','none','TolFun',1e-6,'TolX',1e-6);
    end
    methods
        function obj = Estimation(model,fr,ps)
            arguments
                model string
                fr FileReader
                ps (1,1)
            end
            obj.model = model;
            obj.oh = OutputHandler();
            obj.fr = fr;
            obj.ps = ps;
        end
        function run(obj)
            arguments
                obj Estimation
            end
            first_dataset = obj.fr.readDay(1);
            names = obj.ps.getNames();
            values = obj.ps.initializeAll(first_dataset);
            vh = ValueHandler(obj.ps.dim,names,values);
            files = obj.fr.getFiles();    
            for iDay = 1:size(files,1)
                [data,ok] = obj.fr.readDay(iDay);
                if ~ok
                    continue;
                end
                s_ouput = obj.estimate(vh,data);
                obj.oh.addEntry('fval',s_ouput.exit_flag,iDay);
                obj.oh.addEntry('exit_flag',s_ouput.exit_flag,iDay);
                perc_e = obj.percentError(s_ouput,data);
                obj.oh.addEntry('perc_error',perc_e,iDay);
                for jName = 1:size(vh.names,2)
                    name = vh.names{jName};
                    obj.oh.addEntry(name,vh.get(name),iDay);
                end
            end
        end
    end
    methods (Access = private)
        function s = estimate(obj,vh,data)
            arguments
                obj Estimation
                vh ValueHandler
                data table
            end
            init_v = vh.getVector();
            static_bounds = {obj.ps.getAllLowerBounds(),obj.ps.getAllUpperBounds()};
            wrapped_con = @(theta) feval(obj.model+".getnonlcon",theta,vh,data);
            obj_fun = @(theta) obj.totalSquaredErrors(theta,vh,data);
            [theta,fval,exit_flag] = fmincon(...
                obj_fun,...
                init_v,...
                [],...
                [],...
                [],...
                [],...
                static_bounds{1},...
                static_bounds{2},...
                wrapped_con, ...
                obj.options...
                );
            vh.setVector(theta);
            s.omega = vh.get('omega');
            s.mu = vh.get('mu');
            s.sigma = vh.get('sigma');
            s.nu = vh.get('nu');
            s.fval = fval;
            s.exit_flag = exit_flag;
        end
        function perc_e = percentError(obj,params,data)
            % only put data is being considered for percent error purposes
            arguments
                obj Estimation
                params struct
                data table
            end
            data_puts = data(data.opt_type == 'p',:);
            perc_e = nan(size(data_puts.opt_type));
            for iRow = 1:size(data_puts.opt_type,1)
                perc_e(iRow) = obj.error(params,data_puts(iRow,:))/data_puts.mid(...
                    iRow);
            end
        end
        function e = error(obj,params,data)
            arguments
                obj Estimation
                params struct
                data (1,:)
            end
            e = feval(obj.model+".getPrice",params,data)-data.mid;
        end
        function e = totalSquaredErrors(obj,theta,vh,data)
            arguments
                obj Estimation
                theta (1,:)
                vh ValueHandler
                data table
            end            
            vh.setVector(theta);
            pars = vh.getStruct();
            summ = 0;
            for iRow = 1:size(data.opt_type,1)
                if data.opt_type(iRow) == 'c' && data.K(iRow) > data.F(iRow)
                    data.mid(iRow) = data.mid(iRow)-data.under_mid(iRow)*exp(-data.divyield(1)*data.tau(1))+...
                    data.K(iRow)*exp(-data.r(1)*data.tau(1));
                    summ = summ+obj.error(pars,data(iRow,:))^2;
                elseif data.opt_type(iRow) == 'p' && data.K(iRow) < data.F(iRow)
                    summ = summ+obj.error(pars,data(iRow,:))^2;
                end
            end
            e = summ;
        end
    end
end