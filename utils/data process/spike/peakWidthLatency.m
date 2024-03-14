function varargout = peakWidthLatency(spikes, baseWin, respWin, varargin)
psthDef.binsize = 3;  psthDef.binstep = 0.3;

mIp = inputParser;
mIp.addRequired("spikes", @(x) isnumeric(x) | iscell(x));
mIp.addRequired("baseWin", @isnumeric);
mIp.addRequired("respWin", @isnumeric);
mIp.addOptional("psthPara", [], @(x) isstruct(x) | isempty(x));
mIp.addOptional("trials", [], @isnumeric);
mIp.addParameter("toPlot", false, @islogical);
mIp.addParameter("returnVal", "all", @(x) any(validatestring(x, {'all', 'peak', 'width', 'latency'})));
mIp.addParameter("latencyMethod", "threshold", @(x) all(matches(x, {'threshold', 'firstSpike', 'halfPeak', 'peak', 'halfArea', 'peakRatio'})));
mIp.addParameter("firstSpkWin", [10, 100], @isnumeric);
mIp.addParameter("peakRatio", 0.1, @isnumeric);

mIp.parse(spikes, baseWin, respWin, varargin{:});
psthPara = mIp.Results.psthPara;
trials = mIp.Results.trials;
toPlot = mIp.Results.toPlot;
returnVal = mIp.Results.returnVal;
latencyMethod = mIp.Results.latencyMethod;
firstSpkWin = mIp.Results.firstSpkWin;
peakRatio = mIp.Results.peakRatio;

if isnumeric(spikes)
    if isempty(trials)
        error("Please supply trial info !");
    elseif ~iscolumn(trials)
        trials = trials';
    end
    spikeCell = rowFcn(@(x) spikes(spikes(:, 2) == x), trials, "UniformOutput", false);
elseif iscell(spikes)
    spikeCell = spikes;
    spikes    = cell2mat(spikes);
end

if isempty(psthPara)
    psthPara = psthDef;
end

countRaw = cellfun(@length, spikeCell);
excludeIndex = countRaw > mean(countRaw)+3*std(countRaw);
spikeCell(excludeIndex) = [];
[frMean, ~, ~, frSD] = calFr(spikeCell, respWin);
[frBase, ~, ~, frSDBase] = calFr(spikeCell, baseWin);
% change window
calWinRaw = respWin;
respWin(1) = respWin(1) - psthPara.binsize;
respWin(2) = respWin(2) + psthPara.binsize;
% calPSTH
PSTH = calPsth(spikeCell, psthPara, 1e3, 'EDGE', respWin);
PSTH = findWithinInterval(PSTH, calWinRaw, 1);
smthPSTH = PSTH(:, 2);
% smthPSTH = mGaussionFilter(PSTH(:, 2), 20, 101);
% smthPSTH = smoothdata(PSTH(:, 2),'gaussian',11);

%% peak and width
peak = max(smthPSTH);

thr = 0.5*peak;
evokeIdx = find(smthPSTH >= thr & PSTH(:, 1) > 0);
temp = find([0; diff(evokeIdx)] > 25);
if ~isempty(temp)
    evokeIdx(temp(1):end) = [];
end
[firstIdx, lastIdx] = mConsecutive(evokeIdx, 5);
if ~isempty(firstIdx)
    width = PSTH(evokeIdx(lastIdx), 1)- PSTH(evokeIdx(firstIdx), 1);
else
    width = 0;
end
%% latency
for mIndex = 1 : length(latencyMethod)
    if strcmp(latencyMethod(mIndex), "threshold")
        thr = max([(frBase + 2*frSDBase)*baseWin / psthPara.binsize, 200/psthPara.binsize]);
        evokeIdx = find(smthPSTH >= thr & PSTH(:, 1) > 0);
        if ~isempty(evokeIdx)
            firstIdx = mConsecutive(evokeIdx, 3);
            if ~isempty(firstIdx)
                latency.(latencyMethod(mIndex)) = PSTH(evokeIdx(firstIdx), 1);
            else
                latency.(latencyMethod(mIndex)) = calWinRaw(2);
            end
        else
            latency.(latencyMethod(mIndex)) = calWinRaw(2);
        end

    elseif strcmp(latencyMethod(mIndex), "firstSpike")
        %     latency = mean(cell2mat(cellfun(@(x) min([firstSpkWin(2), x(find(x >= firstSpkWin(1) & x <= firstSpkWin(2), 1, "first"))]), spikeCell, "uni", false)));
        latency.(latencyMethod(mIndex)) = mean(cell2mat(cellfun(@(x) x(find(x >= firstSpkWin(1) & x <= firstSpkWin(2), 1, "first")), spikeCell, "uni", false)));

    elseif strcmp(latencyMethod(mIndex), "halfPeak")
        latency.(latencyMethod(mIndex)) = min([NaN, PSTH(find(smthPSTH >= (max(smthPSTH) - frBase)*0.5 + frBase, 1, "first"), 1)]);

    elseif strcmp(latencyMethod(mIndex), "peak")
        latency.(latencyMethod(mIndex)) = min([NaN, PSTH(find(smthPSTH == max(smthPSTH), 1, "first"), 1)]);

    elseif strcmp(latencyMethod(mIndex), "halfArea")
        latency.(latencyMethod(mIndex)) = min([NaN, PSTH(find(cumsum(smthPSTH) / sum(smthPSTH) >= 0.5, 1, "first"), 1)]);
    elseif strcmp(latencyMethod(mIndex), "peakRatio")
        latency.(latencyMethod(mIndex)) = min([NaN, PSTH(find(smthPSTH >= (max(smthPSTH) - frBase)*peakRatio + frBase, 1, "first"), 1)]);
    end

end

%% plot figure
if toPlot
    Fig = figure;
    subplot(2, 1, 1)
    plot(spikes(:, 1), spikes(:, 2), 'r.', 'MarkerSize', 10);
    xlim(calWinRaw);
    subplot(2, 1, 2)
    plot(PSTH(:, 1), smthPSTH);
    xlim(calWinRaw);
    lines(1).X = 0;
    addLines2Axes(Fig, lines);
    if latency.(latencyMethod(mIndex)) <calWinRaw(2)
        title(strcat("Response Peak = ", num2str(peak), "Hz, Width = ", num2str(width), "ms, Latency = ", num2str(latency.(latencyMethod(mIndex))), "ms"));
    else
        title("No Obvious Response!");
    end
else
    Fig = [];
end

switch returnVal
    case "all"
        varargout = [{peak}, {width}, {latency}, {Fig}, {PSTH}]';
    case "peak"
        varargout{1} = peak;
    case "width"
        varargout{1} = width;
    case "latency"
        varargout{1} = latency;
end
end