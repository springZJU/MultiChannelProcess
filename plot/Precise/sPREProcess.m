function result = sPREProcess(data, windowParams, sortData, chIndex)
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
if isfield(data.epocs,'ICIs')
    ICIsAll = data.epocs.ICIs.data; % Hz
end
if isfield(data.epocs,'nSel')
    typeAll = data.epocs.nSel.data; % Hz
end
if isfield(data.epocs,'attv')
    attAll = data.epocs.attv.data; % absolute attenuation, dB
elseif isfield(data.epocs,'var2')
    attAll = data.epocs.var2.data; % absolute attenuation, dB
elseif isfield(data.epocs,'atts')
    attAll = data.epocs.atts.data; % absolute attenuation, dB
end


if nargin == 3
    spikeTimeAll = sortData.spikeTimeAll * 1000; % ms
elseif nargin == 4
    spikeTimeAll = sortData.spikeTimeAll(sortData.channelIdx == chIndex) * 1000; % ms
end

%% Categorizations
% By sound onset time and window
for trialIndex = 1:length(onsetTimeAll)
    trialAll(trialIndex, 1).ICI = ICIsAll(trialIndex);
    trialAll(trialIndex, 1).att = attAll(trialIndex);
    trialAll(trialIndex, 1).type = typeAll(trialIndex);
    trialAll(trialIndex, 1).spike = spikeTimeAll(spikeTimeAll >= onsetTimeAll(trialIndex) + Window(1) & spikeTimeAll < onsetTimeAll(trialIndex) + Window(2)) - onsetTimeAll(trialIndex);
end

% trialAll = trialAll([trialAll.type]==1);

% By ICI
ICIUnique = unique([trialAll.ICI])';
spikes    = cellfun(@(x) {trialAll([trialAll.ICI] == x, 1).spike}', num2cell(ICIUnique), "UniformOutput", false);
result    = cell2struct([num2cell(ICIUnique), spikes], ["ICI", "spikes"], 2);

return;
end
