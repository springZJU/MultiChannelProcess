function RNP_Noise(MATPATH, FIGPATH, plotWin)
narginchk(2, 3);
if nargin < 3
    plotWin = [-50, 150];
end
if exist(FIGPATH, "dir")
    return
end
%% plot Noise
% sNoise_RNP(MATPATH, FIGPATH);
try
    load(strrep(MATPATH, "data.mat", "spkData.mat"));
    spikeTimeAll = data.sortdata(:,1)*1000;
    channelIdx = data.sortdata(:,2);
catch
    data = TDTbin2mat(MATPATH);
    spikeTimeAll = data.snips.eNeu.ts*1000;
    channelIdx = data.snips.eNeu.chan;  
end
spikesAll = double([spikeTimeAll, channelIdx]);
ch = unique(channelIdx);

for cIndex = 1 : length(ch)
Window = [-100, 100] + plotWin;
segWin = num2cell(Window + data.epocs.Swep.onset*1000, 2);
trialN = num2cell(1 : length(data.epocs.Swep.onset))';
spikes = spikesAll(channelIdx == ch(cIndex), 1);
noiseSpike = cell2mat(cellfun(@(x, y) [findWithinInterval(spikes, x) - x(1) + Window(1), fix(y)*ones(length(findWithinInterval(spikes, x)), 1)], segWin, trialN, "UniformOutput", false));
[~, ~, ~, Fig] = peakWidthLatency(noiseSpike, [-100, 0], plotWin, [], 1 : length(trialN), "toPlot", true);
mkdir(FIGPATH);
mPrint(Fig, strcat(FIGPATH, "\CH", num2str(ch(cIndex))), "-djpeg", "-r300");
close(Fig);
end
end