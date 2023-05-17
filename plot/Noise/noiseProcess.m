function trialAll = noiseProcess(data, windowParams, sortData, chIndex)
narginchk(2, 4);

%% Parameter settings
window = windowParams.window; % ms

%% Information extraction
if isfield(data.epocs,'tril')
    onsetTimeAll = data.epocs.tril.onset * 1000; % ms
elseif isfield(data.epocs,'Swep')
    onsetTimeAll = data.epocs.Swep.onset * 1000; % ms
end
if isfield(data,'snips')
    spikeTimeAll = data.snips.eNeu.ts * 1000; % ms
end


if nargin == 3
    spikeTimeAll = sortData.spikeTimeAll * 1000; % ms
elseif nargin == 4
    spikeTimeAll = sortData.spikeTimeAll(sortData.channelIdx == chIndex) * 1000; % ms
end

%% Categorizations
% By sound onset time and window
for trialIndex = 1:length(onsetTimeAll)
    trialAll(trialIndex, 1).spike = spikeTimeAll(spikeTimeAll >= onsetTimeAll(trialIndex) + window(1) & spikeTimeAll < onsetTimeAll(trialIndex) + window(2)) - onsetTimeAll(trialIndex);
end

return;
end
