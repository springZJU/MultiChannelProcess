function trialAll = PassiveProcess_NoiseTone(epocs)

%% Information extraction
trialOnsetIndex = 1:length(epocs.Swep.data);
soundOnsetTimeAll = epocs.Swep.onset * 1000; % ms

n = length(trialOnsetIndex);
temp = cell(n, 1);
trialAll = struct('trialNum', temp, ...
    'soundOnsetSeq', temp);

%% All trials
% Absolute time, abort the last trial
for tIndex = 1:length(trialOnsetIndex)
    trialAll(tIndex, 1).trialNum = tIndex;
    %% Sequence
    if tIndex < length(trialOnsetIndex)
    soundOnsetIndex = trialOnsetIndex(tIndex):(trialOnsetIndex(tIndex + 1) - 1);
    else
         soundOnsetIndex = trialOnsetIndex(tIndex):length(epocs.Swep.data);
    end
    trialAll(tIndex, 1).soundOnsetSeq = soundOnsetTimeAll(soundOnsetIndex);

end

return;
end
