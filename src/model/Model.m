classdef (Abstract) Model
    properties (Abstract)
        dimension (1, 1)
    end
    methods (Abstract)
        parameterSetup = getParameterSetup(obj)
    end
    methods (Abstract, Static)
        [inequality, equality] = getNonLinearConstraint(theta,...
            valueHandler, contractData)
        price                  = getPrice(parameters, contractData)
        price                  = getForwardPrice(parameters, contractData)
    end
end