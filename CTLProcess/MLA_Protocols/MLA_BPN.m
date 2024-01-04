function [Fig, ch] = MLA_BPN(dataPath, FIGPATH)

% if exist(FIGPATH, "dir")
%     return
% end
%% Parameter Settings
try
    windowParams = evalin("base", "windowParams");
catch
    windowParams.Window = [-1000 3000]; % ms
end

%% Load data
try
    load(strrep(dataPath, "data.mat", "spkData.mat"));
    sortData.spikeTimeAll = data.sortdata(:,1);
    if size(data.sortdata, 2) == 2
        sortData.channelIdx = data.sortdata(:, 2);
    else
        sortData.channelIdx = 1;
    end
catch
    data = TDTbin2mat(dataPath, 'TYPE', [1, 2, 3]);
    sortData.spikeTimeAll = data.snips.eNeu.ts;
    sortData.channelIdx = data.snips.eNeu.chan;
end

ch = unique(sortData.channelIdx);

%% Process;
spkData = cellfun(@(x) BPNProcess(data, windowParams, sortData, x), num2cell(ch), "UniformOutput", false);
spkRes  = cell2struct([num2cell(ch), spkData], ["ch", "spkData"], 2);
run("postBPN.m");




end
