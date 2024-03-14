function trialAll = PassiveProcess_clickTrainIntrinsic(epocs)

CTLParams = MLA_ParseCTLParams("Intrinsic");
parseStruct(CTLParams);
%% Information extraction
if ~isfield(epocs, "ordr")
    epocs.ordr.data  = ones(1000/segLength, 1);
    epocs.ordr.onset = 0:segLength:1000-segLength;
    epocs.ordr.offset = segLength:segLength:1000;
end
trialOnsetIndex = 1:length(epocs.ordr.data);
soundOnsetTimeAll = epocs.ordr.onset * 1000; % ms
ordrAll = epocs.ordr.data; % Hz


n = length(trialOnsetIndex);
temp = cell(n, 1);
trialAll = struct('trialNum', temp, ...
    'soundOnsetSeq', temp, ...
    'devOnset', temp, ...
    'ordrSeq', temp, ...
    'stdOrdr',temp, ...
    'devOrdr', temp, ...
    'oddballType', temp, ...
    'stdNum', temp);

%% All trials
% Absolute time, abort the last trial
for tIndex = 1:length(trialOnsetIndex)
    trialAll(tIndex, 1).trialNum = tIndex;
    %% Sequence
    if tIndex < length(trialOnsetIndex)
    soundOnsetIndex = trialOnsetIndex(tIndex):(trialOnsetIndex(tIndex + 1) - 1);
    else
         soundOnsetIndex = trialOnsetIndex(tIndex):length(epocs.ordr.data);
    end
    trialAll(tIndex, 1).soundOnsetSeq = soundOnsetTimeAll(soundOnsetIndex);
    trialAll(tIndex, 1).devOnset = trialAll(tIndex, 1).soundOnsetSeq(end);
     trialAll(tIndex, 1).ordrSeq = ordrAll(soundOnsetIndex);
    trialAll(tIndex, 1).stdOrdr = trialAll(tIndex, 1).ordrSeq(1);
    if trialAll(tIndex, 1).ordrSeq(end) == trialAll(tIndex, 1).ordrSeq(1)
        trialAll(tIndex, 1).oddballType = "STD";
    else
        trialAll(tIndex, 1).oddballType = "DEV";
    end
    trialAll(tIndex, 1).devOrdr = trialAll(tIndex, 1).ordrSeq(end);
    trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).ordrSeq) - 1;

end

return;
end
