classdef DataSmootherTests < matlab.unittest.TestCase
    properties
        data
    end
    methods (TestClassSetup)
        function setup(tc)
            fileReader = FileReader();

            success = false;

            while ~success

                [fileData, success] = fileReader.readDay(1);
        
            end
            tc.data = fileData;
        end

    end
    methods (Test)
        function testSmoothing(tc)

            % Obtain smoothed out data.
            smoothData = DataSmoother.fitStrikeToImpliedVolatility(tc.data);

            % Smoothed strikes and volatilities.
            smoothStrike = smoothData.strike;
            smoothVolatility = smoothData.volatility;
            putPrice = smoothData.putPrice;
            
            figure(1);

            % Plot the volatility smile.
            plot(smoothStrike, smoothVolatility, '-o');
            xlabel('Strike');
            ylabel('Volatility');
            grid on;

            % Save figure
            saveas(figure(1), 'firstDayDataSmootherFit.png');

            figure(2);

            % Plot the (strike, option price) graph.
            plot(smoothStrike, putPrice, '-o');
            xlabel('Strike');
            ylabel('Put Price');
            grid on;

            % Save figure
            saveas(figure(2), 'firstDayDataSmootherPutPrice.png')
        end
    end
end