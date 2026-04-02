function Recover_RNP_Noise(MATPATH, FIGPATH, plotWin, toPlot)
narginchk(2, 4);
if nargin < 4
    plotWin = [-50, 300];
end
if nargin < 3
    toPlot = false;
end
% if exist(FIGPATH, "dir")
%     return
% end
%% plot Noise
% sNoise_RNP(MATPATH, FIGPATH);
try
    load(strrep(MATPATH, "data.mat", "spkData.mat"));
    spikeTimeAll = data.sortdata(:,1)*1000;
    channelIdx = data.sortdata(:,2);
catch
    data = TDTbin2mat(MATPATH);
    spikeTimeAll = data.snips.eNeu.ts*1000;
    if numel(data.snips.eNeu.chan) ~= 1
        channelIdx = data.snips.eNeu.chan;
    else
        channelIdx = repmat(data.snips.eNeu.chan, [size(data.snips.eNeu.data, 1), 1]);
    end
end
spikesAll = double([spikeTimeAll, channelIdx]);
ch = unique(channelIdx);
dateStr = erase(erase(regexp(MATPATH, "RNP_Noise\\.*\\", "match"), "RNP_Noise\"), "\");
for cIndex = 1 : length(ch)
    Window = [-100, 100] + plotWin;
    baseWin = [-200, 0]; respWin = [0, 200];

    segWin = num2cell(Window + data.epocs.Swep.onset*1000, 2);
    trialN = num2cell(1 : length(data.epocs.Swep.onset))';
    spikes = spikesAll(channelIdx == ch(cIndex), 1);
    noiseSpike = cellfun(@(x, y) findWithinInterval(spikes, x) - x(1) + Window(1), segWin, trialN, "UniformOutput", false);

    baseCount = cellfun(@(x) length(findWithinInterval(x(:, 1), baseWin)), noiseSpike);
    respCount = cellfun(@(x) length(findWithinInterval(x(:, 1), respWin)), noiseSpike);
    noiseRes(cIndex).CH = strcat(dateStr, "_CH", num2str(ch(cIndex)));
    noiseRes(cIndex).noiseSpike = noiseSpike;
    [H, noiseRes(cIndex).P] = ttest(respCount, baseCount, "Tail", "right");
    noiseRes(cIndex).H = H * double(mean(respCount) > 1);
    mkdir(FIGPATH);
    if toPlot
        [~, ~, ~, Fig] = peakWidthLatency(noiseSpike, [-100, 0], plotWin, "toPlot", toPlot);
        mPrint(Fig, strcat(FIGPATH, "\CH", num2str(ch(cIndex))), "-djpeg", "-r300");
        close(Fig);
    end
end
save(fullfile(FIGPATH, "noiseRes.mat"), "noiseRes", "-mat");
end