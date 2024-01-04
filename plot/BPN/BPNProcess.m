function result = BPNProcess(data, windowParams, sortData, chIndex)
narginchk(2, 4);

%% Parameter settings
parseStruct(windowParams); % ms

%% Information extraction
if isfield(data.epocs,'tril')
    onsetTimeAll = data.epocs.tril.onset * 1000; % ms
elseif isfield(data.epocs,'Swep')
    onsetTimeAll = data.epocs.Swep.onset * 1000; % ms
end
if isfield(data,'snips')
    spikeTimeAll = data.snips.eNeu.ts * 1000; % ms
end
if isfield(data.epocs,'ordr')
    OrdrAll = data.epocs.ordr.data; % Hz
end

if nargin == 3
    spikeTimeAll = sortData.spikeTimeAll * 1000; % ms
elseif nargin == 4
    spikeTimeAll = sortData.spikeTimeAll(sortData.channelIdx == chIndex) * 1000; % ms
end

%% Categorizations
% By sound onset time and window
for trialIndex = 1:length(onsetTimeAll)
    trialAll(trialIndex, 1).ordr = OrdrAll(trialIndex);
    trialAll(trialIndex, 1).spike = spikeTimeAll(spikeTimeAll >= onsetTimeAll(trialIndex) + Window(1) & spikeTimeAll < onsetTimeAll(trialIndex) + Window(2)) - onsetTimeAll(trialIndex);
end

% By Ordr
OrdrUnique = unique([trialAll.ordr])';
spikes    = cellfun(@(x) {trialAll([trialAll.ordr] == x, 1).spike}', num2cell(OrdrUnique), "UniformOutput", false);
result    = cell2struct([num2cell(OrdrUnique), spikes], ["ordr", "spikes"], 2);

return;
end
