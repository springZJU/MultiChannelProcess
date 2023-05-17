function epocs = rewriteEpocsTime(epocs, delta_T, store)
narginchk(2, 3);

if nargin < 3
    storeNames = string(fields(epocs));
    store = storeNames(structfun(@(x) isfield(x, "onset"), epocs));
end
for sIndex = 1 : length(store)
    epocs.(store(sIndex)).onset = epocs.(store(sIndex)).onset + delta_T;
    epocs.(store(sIndex)).offset = epocs.(store(sIndex)).offset + delta_T;
end
end
