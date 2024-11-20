function [frMean, frSE, frRaw, frSD, trials] = calFr(spikes, window, varargin)
mIp = inputParser;
mIp.addRequired("spikes", @(x) isnumeric(x) | iscell(x));
mIp.addRequired("window", @isnumeric);
mIp.addOptional("trials", [], @isnumeric);

mIp.parse(spikes,window, varargin{:});
trials = mIp.Results.trials;

if isnumeric(spikes)
    if isempty(trials)
        error("Please supply trial info !");
    elseif ~iscolumn(trials)
        trials = trials';
    end
    spikesTemp = findWithinInterval(spikes, window, 1);
    spikeCell = rowFcn(@(x) spikesTemp(spikesTemp(:, 2) == x), trials, "UniformOutput", false);
    countRaw = [cellfun(@length, spikeCell), trials];
    frRaw = countRaw(:, 1)*1000 / diff(window);
elseif iscell(spikes)
    spikeCell = cellfun(@(x) findWithinInterval(x, window, 1), spikes, "UniformOutput", false);
    countRaw = cellfun(@length, spikeCell);
    frRaw = countRaw*1000 / diff(window);
end

frMean = mean(frRaw);
frSE = SE(frRaw);
frSD = std(frRaw);
end
