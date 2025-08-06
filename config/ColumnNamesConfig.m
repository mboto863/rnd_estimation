classdef ColumnNamesConfig
    properties (Constant)
        % Column names of the tables 
        rootCycle = "root_cycle";
        valuationDate = "t"; % (date) Reference time of the data.
        maturity = "T"; % (date)
        daysToMaturity = "tau_d";
        timeToMaturity = "tau"; % (years)
        optionType = "opt_type"; % The type of the option, either call or put.
        strike = "K"; % option strike.
        optionBid = "bid"; % The bidding price of the option contract.
        optionMid = "mid"; % The average of the bidding and asking prices of the option contract.
        optionAsk = "ask"; % The asking price of the option contract.
        volume = "vol"; % Daily volume of the option contract.
        openInterest = "oi"; % Open interest of the option contract.
        underlyingBid = "under_bid"; % The bidding price of the underlying asset.
        underlyingMid = "under_mid"; % The average of the bidding and asking prices of the underlying asset.
        underlyingAsk = "under_ask"; % The asking price of the underlying asset.
        riskFreeRate = "r"; % (yearly) The risk free rate of return for the period corresponding to the time to maturity of the
        % option contract.
        discountFactor = "P"; % (yearly) The discount factor for the period corresponding to the time to maturity of the option
        % contract.
        futuresPrice = "F"; % The market price of the futures contract over the underlying asset.
        dividendYield = "divyield"; % (yearly) The dividend yield of the underlying asset.
        impliedVolatility = "IV"; % The implied volatility of the underlying asset.
    end
end