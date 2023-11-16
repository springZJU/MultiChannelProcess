function resPsth = calOriPsth(data, binsize, scaleFactor, varargin)
mIp = inputParser;
mIp.addRequired("data", @(x) isnumeric(x) | iscell(x));
mIp.addRequired("bin", @isnumeric);
mIp.addOptional("scaleFactor", 1e3, @isnumeric);
mIp.addParameter("NTRIAL", 1, @isnumeric);
mIp.addParameter("EDGE", [], @isnumeric);

mIp.parse(data, binsize, scaleFactor, varargin{:});
NTRIAL = mIp.Results.NTRIAL;
EDGE = mIp.Results.EDGE;
if isempty(data)
    resPsth = [0 0];
    return
end
if iscell(data)
    NTRIAL = length(data);
    data = cell2mat(data);
end
if isempty(EDGE)
    EDGE = [min(data), max(data)];
end

edges = EDGE(1):binsize:EDGE(2); % 边界数组
[counts, ~] = histcounts(data(:, 1), edges);
resY = counts/binsize/NTRIAL*scaleFactor;
resX = edges(1:end-1) + binsize/2;

resPsth = [resX' resY'];