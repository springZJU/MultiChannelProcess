function [Fig, ch] = RNP_Precise(dataPath, FIGPATH)

% if exist(FIGPATH, "dir")
%     return
% end
%% Load data
load(strrep(dataPath, "data.mat", "spkData.mat"));

%% Parameter Settings
try
    windowParams = evalin("base", "windowParams");
catch
    windowParams.Window = [-1000 3000]; % ms
end
%% Process;

result.windowParams = windowParams;
sortData.spikeTimeAll = data.sortdata(:,1);
sortData.channelIdx = data.sortdata(:,2);

ch = unique(sortData.channelIdx);

%% quantifying
spkData = cellfun(@(x) sPREProcess(data, windowParams, sortData, x), num2cell(ch), "UniformOutput", false);
spkRes  = cell2struct([num2cell(ch), spkData], ["ch", "spkData"], 2);
mkdir(FIGPATH);
save(strcat(FIGPATH, "\spkRes.mat"), "spkRes", "windowParams", "-v7.3");

end
