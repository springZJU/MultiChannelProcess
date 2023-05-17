function [trialAll, spikeDataset, lfpDataset, soundFold] = spikeLfpProcess(DATAPATH, params)
% Description: load data from *.mat or TDT block
% Input:
%     DATAPATH: full path of *.mat or TDT block path
%     params:
%         - choiceWin: choice window, in ms
%         - processFcn: behavior processing function handle

% Output:
%     trialAll: n*1 struct of trial information
%     ECOGDataset: TDT dataset of [streams.(posStr(posIndex))]



%% Parameter settings

paramsNames = fieldnames(params);
for index = 1:size(paramsNames, 1)
    eval([paramsNames{index}, '=params.', paramsNames{index}, ';']);
end

%% Validation
if isempty(processFcn)
    error("Process function is not specified");
end

%% Loading data
try
    disp("Try loading data from MAT");
    load(DATAPATH);
    spikeDataset = spikeByCh(sortrows(data.sortdata, 2));
    lfpDataset = data.lfp;
    epocs = data.epocs;
    trialAll = processFcn(epocs);

catch e
    disp(e.message);
    disp("Try loading data from TDT BLOCK...");
    temp = TDTbin2mat(DATAPATH, 'TYPE', {'epocs'});
    epocs = temp.epocs;
    trialAll = processFcn(epocs);

    temp = TDTbin2mat(DATAPATH, 'TYPE', {'streams'});
    streams = temp.streams;
    spikeDataset = spikeByCh(sortrows([temp.snips.eNeu.ts double(temp.snips.eNeu.chan)], 2));
    lfpDataset = streams.Llfp;
    soundFold = [];
end

return;
end