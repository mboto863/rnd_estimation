classdef (Abstract) ParameterSetup
    properties (Abstract)
        dim (1,1)
    end
    methods (Abstract)
        lvec = getAllLowerBounds(obj)
        uvec = getAllUpperBounds(obj)
        l = getLowerBound(obj,name)
        u = getUpperBound(obj,name)
        v = initializeParameter(obj,name,data)
    end
end