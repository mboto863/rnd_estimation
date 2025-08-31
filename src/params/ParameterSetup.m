classdef (Abstract) ParameterSetup
    properties (Abstract)
        dimension (1, 1)
    end
    methods (Abstract)
        initialValue = initializeParameter(obj, name, data)
        names        = getNames()
    end
end