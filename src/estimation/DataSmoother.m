classdef DataSmoother
    methods (Static)
        function smoothData = fitStrikeToImpliedVolatility(data)
            
            % Alias column names configuration class.
            cnf = ColumnNamesConfig();

            strikes = data.(cnf.strike);
            volatilities = data.(cnf.impliedVolatility);

            piecewisePolynomial = spline(strikes, volatilities);
        end
    end
end