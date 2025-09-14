classdef (Abstract) Model
    properties (Abstract)
        dimension (1, 1)
    end
    methods (Abstract)
        parameterSetup = getParameterSetup(obj)
    end
    methods (Abstract, Static)
        [inequality, equality] = getNonLinearConstraint(theta,...
            valueHandler, futuresPrice)
        price                  = getPrice(parameters, contractData)
        price                  = getForwardPrice(parameters, futuresPrice)
    end
end