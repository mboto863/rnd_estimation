classdef GaussJacobiQuadrature
    methods (Static)
        function [nodes, weights] = computeNodesWeights(alphaExponent,betaExponent, nPoints, logger)
            % function [nodes,weights] = gjquad_nw(alpha,beta,N)
            % 
            % Computes Gauss-Jacobi nodes and weights using Golub-Welsch method.
            % 
            % This code uses the notation of Golub and Welsch.


            % Apply condition for quadrature rule to be valid.
            if real(alphaExponent) <= -1 || real(betaExponent) <= -1
                logger.writeWarning(...
                "Re(alphaExponent) and Re(betaExponent) must both be >= -1. alphaExponent: %d, betaExponent: %d",...
                alphaExponent, betaExponent)
                return
            end

            % Initialize vectors.
            a = zeros(nPoints, 1);
            b = zeros(nPoints - 1, 1);

            % Compute crucial quantities
            ab2 = 2+alpha+beta;
            a(1) = (betaExponent - alphaExponent) / (2 + alphaExponent + betaExponent);
            b(1) = sqrt((4 * (1 + alphaExponent) * (1 + betaExponent)) /...
            ((3 + alphaExponent + betaExponent) * (2 + alphaExponent + betaExponent)^2));

            % Compute components of vectors a and b
            a2b2 = beta^2-alpha^2;
            for i = 2 : (nPoints - 1)
                ab2 = 2*i+alpha+beta;
                a(i) = a2b2/((ab2-2)*ab2);
                b(i) = sqrt((4*i*(i+alpha)*(i+beta)*(i+alpha+beta))/((ab2^2-1)*ab2^2));
            end
            ab2 = 2*N+alpha+beta;
            a(N) = a2b2/((ab2-2)*ab2);

            % Construct tridiagonal matrix
            Matrix = diag(a)+diag(b,1)+diag(b,-1);

            % Use eigenvalues and eigenvectors of matrix to compute nodes and weights
            [evec,eval] = eig(Matrix);
            weights = evec(1,:);
            [nodes,index] = sort(diag(eval));
            weights = weights(index);
            nodes = nodes';
            weights = 2^(alpha+beta+1)*gamfun(alpha+1)*gamfun(beta+1)/ ...
                gamfun(alpha+beta+2).*weights.^2;
        end
    end
    methods (Static, Access = private)
        function [a, b] = computeDiagonals(alphaExponent, betaExponent, nPoints)
        %COMPUTEDIAGONALS Computes the Jacobi matrix diagonals needed for the Golub-Welsch algorithm.
        %
        % Input:
        %   alphaExponent    The alpha exponent of the Gauss-Jacobi quadrature.
        %   betaExponent     The beta exponent of the Gauss-Jacobi quadrature.
        %
        % Output:
        %   a                The diagonal of the Jacobi matrix.
        %   b                The lower diagonal of the Jacobi matrix.

            % Initialize vectors.
            a = zeros(nPoints, 1);
            b = zeros(nPoints - 1, 1);

            % Compute crucial quantities
            ab2 = 2+alpha+beta;
            a(1) = (betaExponent - alphaExponent) / (2 + alphaExponent + betaExponent);
            b(1) = sqrt((4 * (1 + alphaExponent) * (1 + betaExponent)) /...
            ((3 + alphaExponent + betaExponent) * (2 + alphaExponent + betaExponent)^2));

            % Compute components of vectors a and b
            a2b2 = beta^2-alpha^2;
            for i = 2 : (nPoints - 1)
                ab2 = 2*i+alpha+beta;
                a(i) = a2b2/((ab2-2)*ab2);
                b(i) = sqrt((4*i*(i+alpha)*(i+beta)*(i+alpha+beta))/((ab2^2-1)*ab2^2));
            end
            ab2 = 2*N+alpha+beta;
            a(N) = a2b2/((ab2-2)*ab2);
        end
    end
end


