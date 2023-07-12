function [res, sampleinfo] = selectSpike(spikeDataset, trials, CTLParams, segOption)
narginchk(3, 4);

if nargin < 4
    segOption = "trial onset";
end

CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end

windowIndex = Window;

switch segOption
    case "trial onset"
        segIndex = cellfun(@(x) fix(x(1)), {trials.soundOnsetSeq}');
    case "dev onset"
        segIndex = fix([trials.devOnset]');
    case "push onset" % make sure pushing time of all trials not empty

        if length(trials) ~= length([trials.firstPush])
            error("Pushing time of all trials should not be empty");
        end

        segIndex = fix([trials.firstPush]');
    case "last std"
        segIndex = cellfun(@(x) fix(x(end - 1)), {trials.soundOnsetSeq}');
end

if isempty(segIndex)
    trialSpike{1} = 0;
    sampleinfo = [];
else


    if segIndex(1) <= 0
        segIndex(1) = 1;
    end

    % by channel
    trialSpike = cell(length(length(segIndex)), length(spikeDataset));
    for cIndex = 1 : length(spikeDataset)
        % by trial
        sampleinfo = zeros(length(segIndex), 2);
        temp = spikeDataset(cIndex).spike;

        for tIndex = 1:length(segIndex)
            sampleinfo(tIndex, :) = segIndex(tIndex) + windowIndex;
            if any(temp > sampleinfo(tIndex, 1) & temp < sampleinfo(tIndex, 2))
                trialSpike{tIndex, cIndex}(:, 1) = temp(temp > sampleinfo(tIndex, 1) & temp < sampleinfo(tIndex, 2)) - segIndex(tIndex);
                trialSpike{tIndex, cIndex}(:, 2) = ones(length(trialSpike{tIndex, cIndex}), 1) * tIndex;
            else
                trialSpike{tIndex, cIndex}(1, 1) = windowIndex(1);
                trialSpike{tIndex, cIndex}(1, 2) = -1e6;
            end
        end
        %         PSTH{tIndex, cIndex} = calPsth(spikePlot{cIndex, 1}(:, 1), psthPara, scaleFactor, 'EDGE', Window, 'NTRIAL', length(trials));
    end
    res= cell2struct(trialSpike, string(cellfun(@(x) strcat("CH", string(num2str(x))), {spikeDataset.ch}', "uni", false)), 2);
    return;
end
end