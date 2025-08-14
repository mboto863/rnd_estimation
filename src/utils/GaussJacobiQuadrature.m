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

            % Compute diagonals of the Jacobi matrix.
            [a, b] = GaussJacobiQuadrature.computeDiagonals(alphaExponent, betaExponent, nPoints);

            % Construct tridiagonal matrix.
            jacobiMatrix = diag(a) + diag(b, 1) + diag(b, -1);

            % Get eigen vectors and eigen values of the Jacobi matrix.
            [eigenVectors, eigenValues] = eig(jacobiMatrix);

            % Use eigenvalues and eigenvectors of matrix to compute nodes and weights.
            weights = eigenVectors(1, :);
            [nodes, index] = sort(diag(eigenValues));
            weights = weights(index);
            nodes = nodes';
            weights =...
            ((2 ^ (alphaExponent + betaExponent + 1)) *...
            GammaCalculator.computeGammaFunction(alphaExponent + 1) *...
            GammaCalculator.computeGammaFunction(betaExponent + 1)) /...
            (GammaCalculator.computeGammaFunction(alphaExponent + betaExponent + 2) .* (weights .^ 2));
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

            % Compute components of diagonals a and b.
            for iComponent = 1 : (nPoints - 1) % b only has nPoints - 1 components.
                [a(iComponent), b(iComponent)] = GaussJacobiQuadrature.computeComponent(alphaExponent, betaExponent, nPoints, iComponent);
            end

            [a(nPoints), ~] = GaussJacobiQuadrature.computeComponent(alphaExponent, betaExponent, nPoints, nPoints);
        end
        function [aComponent, bComponent] = computeComponent(alphaExponent, betaExponent, nPoints, iComponent)
        %COMPUTECOMPONENT Computes the idxth component of the diagonals a and b.
        %
        % Input:
        %   alphaExponent    The alpha exponent of the Gauss-Jacobi quadrature.
        %   betaExponent     The beta exponent of the Gauss-Jacobi quadrature.
        %   nPoints          Number of points of the Gauss-Jacobi quadrature.
        %   iComponent       The index of the components to calculate.
        %
        % Output:
        %   aComponent       The component idx of a.
        %   bComponent       The component idx of b.

            % Abstract this expression for readibility improvement
            sumalphabeta2i = alphaExponent + betaExponent + (2 * iComponent);

            switch iComponent
                % The first component follows a different pattern.
                case 1

                    % Compute the components.
                    aComponent    = (betaExponent - alphaExponent) / sumalphabeta2i;
                    bComponent    = sqrt((4 * (1 + alphaExponent) * (1 + betaExponent)) /...
                    ((sumalphabeta2i + 1) * (sumalphabeta2i)^2));

                % b doesn't have an nth component.
                case nPoints

                    % Compute the components.
                    aComponent = ((betaExponent ^ 2) - (alphaExponent ^ 2)) /...
                    ((sumalphabeta2i - 2) * sumalphabeta2i);
                    bComponent = NaN;

                % Other components follow thea same pattern.
                otherwise

                    % Compute the components.
                    aComponent = ((betaExponent ^ 2) - (alphaExponent ^ 2)) /...
                    ((sumalphabeta2i - 2) * sumalphabeta2i);
                    bComponent = sqrt(...
                    (4 * iComponent * (iComponent + alphaExponent) * (iComponent + betaExponent) *...
                    (iComponent + alphaExponent + betaExponent)) / ((sumalphabeta2i ^ 2 - 1) * sumalphabeta2i ^ 2));

            end
        end
    end
end