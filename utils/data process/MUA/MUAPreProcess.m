function [trialAll, muaDataset] = MUAPreProcess(DATAPATH, params)
% Description: load data from *.mat or TDT block
% Input:
%     DATAPATH: full path of *.mat or TDT block path
%     params:
%         - DATAPATH: the path of TDT data or exported mat file
%         - params: struct that contains behavior processing function handle

% Output:
%     trialAll: n*1 struct of trial information
%     spikeDataset: m*1 struct that contains spiketime, realCh(for lfp) and ch(k*1000+realCh)
%     lfpDataset: TDT dataset of [streams.(posStr(posIndex))]

%% Parameter settings
parseStruct(params);

%% Validation
if isempty(processFcn)
    error("Process function is not specified");
end

%% Loading data
disp("Try loading data from MAT");

% lfp
load(fullfile(erase(DATAPATH, regexp(DATAPATH, "\\\w*.mat", "match")), "muaData.mat"));
muaDataset = data.mua;
epocs = data.epocs;
trialAll = processFcn(epocs);
%     if length(trialAll) > 10000
%         for sIndex = 1:length(epocs.Swep.onset)
%             tt = find([trialAll(:).soundOnsetSeq] > epocs.Swep.onset(sIndex) * 1000);
%             trialnum(sIndex) = trialAll(tt(1)).trialNum;
%         end
%         trialAll = trialAll(trialnum);
%     end
return;
end