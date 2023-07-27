function [Fig, ch] = sPrecise(dataPath, FIGPATH)


%% Load data
mWaitbar = waitbar(0, 'Data loading ...');
load(dataPath);
%     data = TDT2mat(dataPath, 'CHANNEL', 1);
waitbar(1/4, mWaitbar, 'Data loaded');

%% Parameter Settings
windowParams.Window = [-300 1300]; % ms
windowParams.frWin = [0, 1000]; % ms
windowParams.frWinEarly = [0, 200]; % ms
windowParams.frWinLate = [200, 1000]; % ms
%% Process;

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
    result.data = sPREProcess(data, windowParams, sortData, ch(cIndex));
    waitbar(chN / chNum, mWaitbar, ['Plotting process result ...  Ch' num2str(cIndex+1) ]);
    Fig = plotTuningPrecise(result, "on");
    lines(1).X = 0; lines(2).X = 1000;
    addLines2Axes(Fig, lines);
    % save figures
    mkdir(FIGPATH);
    print(Fig, strcat(FIGPATH,"\CH", num2str(ch(cIndex))), "-djpeg", "-r200");
    close(Fig);
end
waitbar(1, mWaitbar, 'Done');
close(mWaitbar);

return;
end
