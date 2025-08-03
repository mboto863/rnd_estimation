classdef (Abstract) Model
    properties (Abstract)

    end
    methods (Abstract, Static)
        names                  = getNames()
        [inequality, equality] = getNonLinearConstraint(theta,...
            valueHandler, data)
        price                  = getPrice(parameters, data)
        price                  = getForwardPrice(parameters)
    end
end