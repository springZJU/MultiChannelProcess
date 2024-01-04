function trialAll = PassiveProcess_clickTrainMSTIReg(epocs)
%% Information extraction
trialOnsetIndex = 1:length(epocs.Swep.data);
ICIOnsetTimeAll = epocs.ICI0.onset * 1000; % ms
ICISeqAll = epocs.ICI0.data; % ms
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
    trialOnset = epocs.Swep.onset(tIndex) * 1000;
    if tIndex < length(trialOnsetIndex)
        trialOff = epocs.Swep.onset(tIndex + 1) * 1000;
        trialICIIdx = find(ICIOnsetTimeAll > trialOnset & ICIOnsetTimeAll < trialOff);
    else
        trialICIIdx = [find(ICIOnsetTimeAll > trialOnset, 1) : length(ICIOnsetTimeAll)]';
    end

    TrialICISeq = ICISeqAll(trialICIIdx);
    TrialICIOnsetTimeSeq = ICIOnsetTimeAll(trialICIIdx);
    ICIChangeIdx = find(diff([TrialICISeq(1); TrialICISeq]) ~= 0) + 1;%按电路设置每个ICI之后1个才是真实的change时刻
    
    %% Sequence
    trialAll(tIndex, 1).soundOnset = ICIOnsetTimeAll(trialICIIdx(1));
    trialAll(tIndex, 1).soundOnsetSeq = TrialICIOnsetTimeSeq(ICIChangeIdx);
    trialAll(tIndex, 1).ICISeq = TrialICISeq;
    
    trialAll(tIndex, 1).devOnset = trialAll(tIndex, 1).soundOnsetSeq(1);
    trialAll(tIndex, 1).ordrSeq = ordrAll(trialICIIdx(1));
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
