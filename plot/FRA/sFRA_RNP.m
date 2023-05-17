function [Fig, ch] = sFRA_RNP(dataPath, FIGPATH)

narginchk(1, 2);
%% Load data
mWaitbar = waitbar(0, 'Data loading ...');
load(dataPath);
%     data = TDT2mat(dataPath, 'CHANNEL', 1);
waitbar(1/4, mWaitbar, 'Data loaded');

%% Parameter Settings
windowParams.window = [0 100]; % ms

%% Process

result.windowParams = windowParams;
%     result.data = FRAProcess(data, windowParams);
%     Fig = plotTuning(result, "on");
sortData.spikeTimeAll = data.sortdata(:,1);
sortData.channelIdx = data.sortdata(:,2);

chNum = length(unique(sortData.channelIdx)');
chN = 0;
ch = unique(sortData.channelIdx)';
for cIndex = 1:length(ch)
    chN = chN + 1;
    waitbar(chN / chNum, mWaitbar, ['Processing ...  Ch' num2str(cIndex+1) ]);
    result.data = sFRAProcess(data, windowParams, sortData, ch(cIndex));
    waitbar(chN / chNum, mWaitbar, ['Plotting process result ...  Ch' num2str(cIndex+1) ]);
    Fig = plotTuning(result, "on");
    % save figures
    mkdir(FIGPATH);
    print(Fig, strcat(FIGPATH,"Idx", num2str(ch(cIndex) + 1)), "-djpeg", "-r200");
    close(Fig);
end
waitbar(1, mWaitbar, 'Done');
close(mWaitbar);

return;
end
