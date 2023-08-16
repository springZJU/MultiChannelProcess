function [peak, width, latency, Fig] = peakWidthLatency(spikes, baseWin, calWin, trials, toPlot)
narginchk(4, 5);
if nargin == 4
    toPlot = false;
end
[~, ~, Raw, ~, trials1] = calFR(spikes, calWin, trials);
excludeIndex = Raw >= 2 & Raw > mean(Raw)+3*std(Raw);
spikes(ismember(spikes(:, 2),trials1(excludeIndex)), :) = [];
trials(excludeIndex) = [];
[frMean, ~, ~, frSD] = calFR(spikes, baseWin, trials);
psthPara.binsize = 3; % ms
psthPara.binstep = 0.3; % ms
% change window
calWinRaw = calWin;
calWin(1) = calWin(1)-psthPara.binsize;
calWin(2) = calWin(2)+psthPara.binsize;
PSTH = calPsth(spikes(:, 1), psthPara, 1e3, 'EDGE', calWin, 'NTRIAL', length(trials));
PSTH = findWithinInterval(PSTH, calWinRaw, 1);
smthPSTH = PSTH(:, 2);
% smthPSTH = mGaussionFilter(PSTH(:, 2), 20, 101);
%     smthPSTH = smoothdata(PSTH(:, 2),'gaussian',11);


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
thr = max([frMean + 2*frSD, 200/psthPara.binsize]);
evokeIdx = find(smthPSTH >= thr & PSTH(:, 1) > 0);
if ~isempty(evokeIdx)
    firstIdx = mConsecutive(evokeIdx, 3);
    if ~isempty(firstIdx)
        latency = PSTH(evokeIdx(firstIdx), 1);
    else
        latency = calWinRaw(2);
    end
else
    latency = calWinRaw(2);
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
    if latency <calWinRaw(2)
        title(strcat("Response Peak = ", num2str(peak), "Hz, Width = ", num2str(width), "ms, Latency = ", num2str(latency), "ms"));
    else
        title("No Obvious Response!");
    end
else
    Fig = [];
end
end
