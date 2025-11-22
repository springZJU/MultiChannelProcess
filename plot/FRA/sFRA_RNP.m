function [Fig, ch] = sFRA_RNP(dataPath, FIGPATH)

narginchk(1, 2);
%% Load data
mWaitbar = waitbar(0, 'Data loading ...');
try
    load(fullfile(erase(dataPath, regexp(dataPath, "\\\w*.mat", "match")), "spkData.mat"));
    sortData.spikeTimeAll = data.sortdata(:,1);
    if size(data.sortdata, 2) == 2
        sortData.channelIdx = data.sortdata(:, 2);
    else
        sortData.channelIdx = 1;
    end
catch
    data = TDTbin2mat(dataPath, 'TYPE', [1, 2, 3]);
    fieldname = fieldnames(data.snips);% 20240513 edit by YHT
    sortData.spikeTimeAll = data.snips.(string(fieldname)).ts;
    if numel(data.snips.(string(fieldname)).chan) ~= 1
        sortData.channelIdx = data.snips.(string(fieldname)).chan;
    else
        sortData.channelIdx = repmat(data.snips.(string(fieldname)).chan, size(data.snips.(string(fieldname)).data, 1), 1);
    end
end
waitbar(1/4, mWaitbar, 'Data loaded');

%% Parameter Settings
windowParams.window = [0 150]; % ms

%% Process

result.windowParams = windowParams;
chNum = length(unique(sortData.channelIdx)');
chN = 0;
ch = unique(sortData.channelIdx)';
if any(ch == 0)
    sortData.channelIdx = sortData.channelIdx + 1;
    ch = unique(sortData.channelIdx)';
end
for cIndex = 1:length(ch)
    chN = chN + 1;
    waitbar(chN / chNum, mWaitbar, ['Processing ...  Ch' num2str(cIndex+1) ]);
    result.data = sFRAProcess(data, windowParams, sortData, ch(cIndex));
    waitbar(chN / chNum, mWaitbar, ['Plotting process result ...  Ch' num2str(cIndex+1) ]);
    Fig = plotTuning(result, "on");
    % save figures
    mkdir(FIGPATH);
    print(Fig, strcat(FIGPATH,"\CH", num2str(ch(cIndex))), "-djpeg", "-r200");
    close(Fig);
end
waitbar(1, mWaitbar, 'Done');
close(mWaitbar);

return;
end
