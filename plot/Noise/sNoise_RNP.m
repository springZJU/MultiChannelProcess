function [Fig, ch] = sNoise_RNP(dataPath, FIGPATH)

narginchk(1, 2);
%% Load data
mWaitbar = waitbar(0, 'Data loading ...');
try
    load(dataPath);
    sortData.spikeTimeAll = data.sortdata(:,1);
    sortData.channelIdx = data.sortdata(:,2);
catch
    data = TDTbin2mat(dataPath);
    sortData.spikeTimeAll = data.snips.eNeu.ts;
    sortData.channelIdx = data.snips.eNeu.chan;
end
waitbar(1/4, mWaitbar, 'Data loaded');

%% Parameter Settings
windowParams.window = [0 150]; % ms

%% Process

result.windowParams = windowParams;
%     result.data = FRAProcess(data, windowParams);
%     Fig = plotTuning(result, "on");


chNum = length(unique(sortData.channelIdx)');
chN = 0;
fIdx = 0;
ch = unique(sortData.channelIdx)';
nFig = 0;
for cIndex = 1:length(ch)
    if mod(cIndex, 100) == 1
        nFig = nFig + 1;
        Fig= figure;
        maximizeFig(Fig);
        fIdx = fIdx + 1;
    end
    chN = chN + 1;
    waitbar(chN / chNum, mWaitbar, ['Processing ...  Neruon' num2str(cIndex) ]);
    result = noiseProcess(data, windowParams, sortData, ch(cIndex));
    try
        toPlot = cell2mat(cellfun(@(x, y) [x, ones(length(x), 1)*y], {result.spike}', num2cell(1:length(result))', "UniformOutput", false));
    catch
        toPlot = [];
    end
    waitbar(chN / chNum, mWaitbar, ['Plotting process result ...  Neuron' num2str(ch(cIndex)) ]);
    if mod(cIndex, 100) > 0
        mSubplot(10, 10, mod(cIndex, 100));
    else
        mSubplot(10, 10, 100);
    end
    if ~isempty(toPlot)
        scatter(toPlot(:, 1), toPlot(: ,2), 10, "red", "filled"); hold on
    end
    plot([0, 0], [0, length(result)], "Color", "k", "LineStyle", ":"); hold on;
    xlim([windowParams.window(1), windowParams.window(2)]);
    title(['CH=', num2str(ch(cIndex))]);
    drawnow;
    if mod(cIndex, 100) == 0 || cIndex == length(ch)
        mkdir(FIGPATH);
        mPrint(Fig, strcat(FIGPATH, "\Noise_Fig", num2str(fIdx)), "-djpeg", "-r300");
        close(Fig);
    end
end
waitbar(1, mWaitbar, 'Done');
close(mWaitbar);

return;
end
