classdef (Abstract) ParameterSetup
    properties (Abstract)
        dimension (1, 1)
    end
    methods (Abstract)
        lowerVector  = getAllLowerBounds(obj)
        upperVector  = getAllUpperBounds(obj)
        lower        = getLowerBound(obj, name)
        upper        = getUpperBound(obj, name)
        initialValue = initializeParameter(obj, name, data)
    end
end