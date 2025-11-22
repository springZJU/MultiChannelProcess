function epocs = rewriteEpocsTime(epocs, TTL_Onset, store)
narginchk(2, 3);

if nargin < 3
    storeNames = string(fields(epocs));
    store = storeNames(structfun(@(x) isfield(x, "onset"), epocs));
end
for sIndex = 1 : length(store)
    epocs.(store(sIndex)).onset = TTL_Onset - epocs.(store(sIndex)).onset(1);
    epocs.(store(sIndex)).offset = TTL_Onset - epocs.(store(sIndex)).onset(1) + epocs.(store(sIndex)).offset(1);
end
end
