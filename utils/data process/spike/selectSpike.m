function [res, sampleinfo] = selectSpike(spikeDataset, trials, CTLParams, segOption)
narginchk(2, 4);

if nargin < 3
    CTLParams.temp = [];
end

if nargin < 4
    segOption = "trial onset";
end

parseStruct(CTLParams);
windowIndex = Window;

switch segOption
    case "trial onset"
        segIndex = cellfun(@(x) x(1), {trials.soundOnsetSeq}');
    case "dev onset"
        segIndex = [trials.devOnset]';
    case "push onset" % make sure pushing time of all trials not empty
%         if length(trials) ~= length([trials.firstPush])
%             error("Pushing time of all trials should not be empty");
%         end
        segIndex = cell2mat(cellfun(@(x, y) max([x, y]), {trials.firstPush}', {trials.devOnset}', "UniformOutput", false));
    case "last std"
        segIndex = cellfun(@(x) x(end - 1), {trials.soundOnsetSeq}');
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
                trialSpike{tIndex, cIndex} = [windowIndex(1), tIndex];

            end
        end
    end
    res= cell2struct(trialSpike, string(cellfun(@(x) strcat("CH", string(num2str(x))), {spikeDataset.ch}', "uni", false)), 2);
    return;
end
end