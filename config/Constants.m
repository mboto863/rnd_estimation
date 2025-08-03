classdef Constants
    properties (Constant)
        callCodification = 'c'; % Call options are identified with the character 'c'.
        putCodification  = 'p'; % Put options are identified with the character 'p'.
        minimumTickValue = 0.05; % The minimum tick value of the option market price.
    end
end