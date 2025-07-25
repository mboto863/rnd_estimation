classdef Student < Model
    properties
        
    end
    methods (Static)
        function [c,ceq] = getnonlcon(theta,vh,data)
            arguments
                theta (1,:)
                vh ValueHandler
                data table
            end
            vh.setVector(theta);
            pars = vh.getStruct();
            mu = pars.mu;
            sigma = pars.sigma;
            nu = pars.nu;
            ceq = Student.getForwardPrice(pars)-data.F(1);
            n1 = (mu./sigma).^2;
            n2 = ((data.K(end)-mu)./sigma).^2;
            n = max([n1;n2]);
            zb = mu.^2./sigma.^2./nu-1;
            c = [zb,n-nu];
        end
        function price = getPrice(params,data)
            arguments
                params struct
                data (1,:)
            end
            omega = params.omega;
            mu = params.mu;
            sigma = params.sigma;
            nu = params.nu;
            strike = data.K;
            r = data.r;
            q = data.divyield;
            tau = data.tau;
            a = -0.5*ones(size(mu));
                b = 1-nu./2;
                c = 0.5*ones(size(mu));
                z = {1./(1+sigma.^2.*nu./mu.^2),...
                    (strike-mu).^2./((strike-mu).^2+sigma.^2.*nu)};
                normalization_factor = sigma.*sqrt(nu.*pi).*...
                    gamma(nu./2)./gamma((nu+1)./2);
                d = mu./abs(mu).*sigma.*nu./(nu-1)./normalization_factor.*...
            (1+mu.^2./sigma.^2./nu).^0.5.*...
            Student.approximateBySingleFraction(a,b,c,z{1});
                omega = [omega,1-sum(omega)];
                price = exp(-(r-q)*tau)*sum(omega.*(d+(strike-mu)./abs(...
                    strike-mu).*sigma.^2.*nu./(nu-1)./...
                    normalization_factor.*...
                    (1+(strike-mu).^2./sigma.^2./nu).^0.5.*...
                    Student.approximateBySingleFraction(a,b,c,z{2})));
        end
        function price = getForwardPrice(params)
            arguments
                params struct
            end
            price = sum(params.omega.*params.mu(1:end-1))+(1-sum(...
                params.omega))*params.mu(end);
        end
    end
    methods (Static, Access = private)
        function v = approximateBySingleFraction(a,b,c,z)
            arguments
                a (1,:) double
                b (1,:) double
                c (1,:) double
                z (1,:) double
            end
            v = zeros(1,size(a,2));
            tol = 10^-15;
            for iComponent = 1:size(a,2)
                alpha = 0;
                betaa = 1;
                gammaa = 1;
                %zeta = [zeta(j-2), zeta(j-1), zeta(j), zeta(j+1)]
                zeta = [1, 0, 0, 0];
                for jIteration = 1:3
                    alpha = (alpha+betaa)*jIteration*(c(iComponent)+jIteration-1);
                    betaa = betaa*(a(iComponent)+jIteration-1)*(b(iComponent)+jIteration-1)*z(iComponent);
                    gammaa = gammaa*jIteration*(c(iComponent)+jIteration-1);
                    zeta(jIteration+1) = (alpha+betaa)/gammaa;
                end
                jIteration = 4;
                while abs(zeta(4)-zeta(3))/abs(zeta(3)) > tol ||...
                        abs(zeta(3)-zeta(2))/abs(zeta(2)) > tol ||...
                        abs(zeta(2)-zeta(1))/abs(zeta(1)) > tol
                    alpha = (alpha+betaa)*jIteration*(c(iComponent)+jIteration-1);
                    betaa = betaa*(a(iComponent)+jIteration-1)*(b(iComponent)+jIteration-1)*z(iComponent);
                    gammaa = gammaa*jIteration*(c(iComponent)+jIteration-1);
                    zeta(1) = zeta(2);
                    zeta(2) = zeta(3);
                    zeta(3) = zeta(4);
                    zeta(4) = (alpha+betaa)/gammaa;
                    jIteration = jIteration+1;
                end
                v(iComponent) = zeta(4);
            end
        end
    end
end