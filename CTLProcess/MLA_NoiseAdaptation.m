function varargout = MLA_NoiseAdaptation(MATPATH, baseWin, respWin, varargin)

mIp = inputParser;
mIp.addRequired("MATPATH", @(x) isstring(x) | ischar(x));
mIp.addRequired("baseWin", @isnumeric);
mIp.addRequired("respWin", @isnumeric);
mIp.addParameter("FIGPATH", [], @(x) isstring(x) | ischar(x));
mIp.addParameter("plotWin", [-50, 150], @isnumeric);

mIp.parse(MATPATH, baseWin, respWin, varargin{:});
MATPATH = mIp.Results.MATPATH;
baseWin = mIp.Results.baseWin;
respWin = mIp.Results.respWin;
FIGPATH = mIp.Results.FIGPATH;
plotWin = mIp.Results.plotWin;

Window = [-100, 100] + plotWin;

% if exist(FIGPATH, "dir")
%     return
% end
%% plot Noise
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

for cIndex = 1 : length(ch)

    segWin = num2cell(Window + data.epocs.Swep.onset*1000, 2);
    trialN = num2cell(1 : length(data.epocs.Swep.onset))';
    spikes = spikesAll(channelIdx == ch(cIndex), 1);
    spkRes(cIndex).noiseSpike = cellfun(@(x, y) [findWithinInterval(spikes, x) - x(1) + Window(1), fix(y)*ones(length(findWithinInterval(spikes, x)), 1)], segWin, trialN, "UniformOutput", false);
    [~, ~, ~, ~, spkRes(cIndex).PSTH] = peakWidthLatency(spkRes(cIndex).noiseSpike, baseWin, plotWin, "toPlot", false);
    
    baseCount = cellfun(@(x) length(findWithinInterval(x(:, 1), baseWin)), spkRes(cIndex).noiseSpike);
    respCount = cellfun(@(x) length(findWithinInterval(x(:, 1), respWin)), spkRes(cIndex).noiseSpike);
    sigRes(cIndex).CH = strcat("CH", num2str(ch(cIndex)));
    [H, sigRes(cIndex).P] = ttest(respCount, baseCount, "Tail", "right");
    sigRes(cIndex).H = H * double(mean(respCount) > 1);

end
% mkdir(FIGPATH);
% save(fullfile(FIGPATH, "Res.mat"), "spkRes", "sigRes", "-mat");

varargout{1} = spkRes;
varargout{2} = sigRes;
end