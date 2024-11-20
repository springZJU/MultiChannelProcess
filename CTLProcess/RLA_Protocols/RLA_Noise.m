function RLA_Noise(MATPATH, FIGPATH)

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

for cIndex = 1 : length(ch)
Window = [-1, 1] * fix(diff(data.epocs.Swep.onset(1:2))*1000);
baseWin = [-100, 0]; respWin = [0, 100];

segWin = num2cell(Window + data.epocs.Swep.onset*1000, 2);
trialN = num2cell(1 : length(data.epocs.Swep.onset))';
spikes = spikesAll(channelIdx == ch(cIndex), 1);
noiseSpike = cellfun(@(x, y) [findWithinInterval(spikes, x) - x(1) + Window(1), fix(y)*ones(length(findWithinInterval(spikes, x)), 1)], segWin, trialN, "UniformOutput", false);

baseCount = cellfun(@(x) length(findWithinInterval(x(:, 1), baseWin)), noiseSpike);
respCount = cellfun(@(x) length(findWithinInterval(x(:, 1), respWin)), noiseSpike);
sigRes(cIndex).CH = strcat("CH", num2str(ch(cIndex)));
[H, sigRes(cIndex).P] = ttest(respCount, baseCount, "Tail", "right");
sigRes(cIndex).H = H * double(mean(respCount) > 1);

noiseRes(cIndex).info = strcat("CH", num2str(ch(cIndex)));
noiseRes(cIndex).spikes = spikes;
noiseRes(cIndex).noiseSpike = noiseSpike;
noiseRes(cIndex).baseCount = baseCount;
noiseRes(cIndex).respCount = respCount;
noiseRes(cIndex).frMean_Base = mean(baseCount*1000/(diff(baseWin)));
noiseRes(cIndex).frMean_Resp = mean(respCount*1000/(diff(respWin)));
noiseRes(cIndex).frSE_Base = SE(baseCount*1000/(diff(baseWin)));
noiseRes(cIndex).frSE_Resp = SE(respCount*1000/(diff(respWin)));
noiseRes(cIndex).H = H * double(mean(respCount) > 1);

end
mkdir(FIGPATH)
save(fullfile(FIGPATH, "noiseRes.mat"), "noiseRes", "baseWin", "respWin", "-mat");
end