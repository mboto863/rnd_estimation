classdef (Abstract) Model
    properties (Abstract)

    end
    methods (Abstract, Static)
        names = getNames()
        [c,ceq] = getnonlcon(theta,vh,data)
        price = getPrice(params,data)
        price = getForwardPrice(params)
    end
end