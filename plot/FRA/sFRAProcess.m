function result = sFRAProcess(data, windowParams, sortData, chIndex)
narginchk(2, 4);

%% Parameter settings
window = windowParams.window; % ms

%% Information extraction
if isfield(data.epocs,'freq')
    freqAll = data.epocs.freq.data; % Hz
elseif isfield(data.epocs,'vair')
    freqAll = data.epocs.vair.data; % Hz
end
if isfield(data.epocs,'attv')
    attAll = data.epocs.attv.data; % absolute attenuation, dB
elseif isfield(data.epocs,'var2')
    attAll = data.epocs.var2.data; % absolute attenuation, dB
end

if nargin == 3
    spikeTimeAll = sortData.spikeTimeAll * 1000; % ms
elseif nargin == 4
    try
        spikeTimeAll = sortData.spikeTimeAll(sortData.channelIdx == chIndex) * 1000; % ms
    catch
        spikeTimeAll = sortData.spikeTimeAll(sortData.clusterIdx == chIndex) * 1000; % ms
    end

end

%% Categorizations
% By sound onset time and window
for trialIndex = 1:length(onsetTimeAll)
    trialAll(trialIndex, 1).freq = freqAll(trialIndex);
    trialAll(trialIndex, 1).att = attAll(trialIndex);
    trialAll(trialIndex, 1).spike = spikeTimeAll(spikeTimeAll >= onsetTimeAll(trialIndex) + window(1) & spikeTimeAll < onsetTimeAll(trialIndex) + window(2)) - onsetTimeAll(trialIndex);
end

% By freq
freqUnique = unique(freqAll);

for fIndex = 1:length(freqUnique)
    result(fIndex, 1).freq = freqUnique(fIndex);
    trials = trialAll([trialAll.freq] == freqUnique(fIndex), 1);

    % By attenuation
    attUnique = sort(unique([trials.att]), "ascend");

    for aIndex = 1:length(attUnique)
        temp(aIndex, 1).amp = abs(roundn(attUnique(aIndex) - attUnique(end), 0)) + 10; % relative attenuation
        temp(aIndex, 1).spikes = {trials([trials.att] == attUnique(aIndex), 1).spike}';
    end

    result(fIndex, 1).trials = temp;
    clearvars temp
end

return;
end
