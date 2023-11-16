function trialAll = PassiveProcess_ClickTrainMMN(epocs)
ratioFromCaller = evalin('caller', 'ratio');     %  windowParams from RNP_MMN
stimStrFromCaller = evalin('caller', 'stimStr');

trialOnsetIndex = 1:sum(ratioFromCaller):length(epocs.ordr.data); % trialnum
soundOnsetTimeAll = epocs.ordr.onset * 1000; % ms
ordrAll = epocs.ordr.data; 
typeAll = epocs.type.data;
temp = cell(length(trialOnsetIndex), 1);
trialAll = struct('trialNum', temp, ...
    'soundOnsetSeq', temp, ...
    'devOnset', temp, ...
    'ordrSeq', temp, ...
    'stdOrdr',temp, ...
    'devOrdr', temp, ...
    'oddballType', temp, ...
    'stdNum', temp, ...
    'TypeOrd', temp);

% Absolute time, abort the last trial
for tIndex = 1:length(trialOnsetIndex)
    trialAll(tIndex, 1).trialNum = tIndex;
    if tIndex < length(trialOnsetIndex)
        soundOnsetIndex = trialOnsetIndex(tIndex):(trialOnsetIndex(tIndex + 1) - 1);
    else
        soundOnsetIndex = trialOnsetIndex(tIndex):length(epocs.ordr.data);
    end
    trialAll(tIndex, 1).soundOnsetSeq = soundOnsetTimeAll(soundOnsetIndex);
    trialAll(tIndex, 1).ordrSeq = ordrAll(soundOnsetIndex);    
    trialAll(tIndex, 1).TypeOrd = unique(typeAll(soundOnsetIndex));

    if trialAll(tIndex, 1).TypeOrd ~= max(typeAll)
        trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).ordrSeq) - 1;
        trialAll(tIndex, 1).devOnset = trialAll(tIndex, 1).soundOnsetSeq(end);
        trialAll(tIndex, 1).stdOrdr = trialAll(tIndex, 1).ordrSeq(1);
        trialAll(tIndex, 1).devOrdr = trialAll(tIndex, 1).ordrSeq(end);
        trialAll(tIndex, 1).oddballType = strcat(stimStrFromCaller{trialAll(tIndex, 1).stdOrdr}, ...
                                          '|', stimStrFromCaller{trialAll(tIndex, 1).devOrdr});
    else
        trialAll(tIndex, 1).stdNum = 0;
        trialAll(tIndex, 1).devOnset = 0;
        trialAll(tIndex, 1).stdOrdr = 0;
        trialAll(tIndex, 1).devOrdr = 0;
        trialAll(tIndex, 1).oddballType = 'ManyStd';
    end
end

return;
end
