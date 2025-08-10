function mustBeCellOfChar(c)
    for iElement = 1:numel(c)
        if ~ischar(c{iElement})
            error('Each element must be a character vector.')
        end
    end
end