function array = arrayRep(array, old, new)

    if numel(old) ~= numel(new)
        error("old elements and new elements should be save length!");
    end

    if numel(old) ~= length(old)
        error("old and new should be vectors!")
    end

    for i = 1 : length(old)
        array(array == old(i)) = new(i);
    end
end