function [trialSpike, trialNum] = selectSpikeMMN(spikeDataset, trialAll, CTLParams, varargin)
    parseStruct(CTLParams);
    windowIndex = spkWindow;
%% params
    mIp = inputParser;
    mIp.addRequired("spikeDataset", @(x) isstruct(x));
    mIp.addRequired("trialAll", @(x) isstruct(x));
    mIp.addRequired("CTLParams", @(x) isstruct(x));
    mIp.addOptional("segOption", [], @(x) any(validatestring(x, {'trial onset', 'dev onset', 'last std', 'control', 'all trial'})));
    mIp.addOptional("stitype", 0, @(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0, '<', 20}));
    mIp.addParameter("segIndex", [], @(x) validateattributes(x, "numeric", "nonempty"));

    mIp.parse(spikeDataset, trialAll, CTLParams, varargin{:});
    segOption = mIp.Results.segOption;
    stitype = mIp.Results.stitype;
    segIndex = mIp.Results.segIndex;

%%
switch segOption
    case "trial onset"
        trials = trialAll([trialAll.TypeOrd] == stitype);
        trialNum = [trialAll([trialAll.TypeOrd] == stitype).trialNum];
        segIndex = cellfun(@(x) x(1), {trials.soundOnsetSeq}');
        windowIndex = lfpWindow;  % one trial
    case "dev onset"
        trials = trialAll([trialAll.devOrdr] == stitype);
        trialNum = [trialAll([trialAll.devOrdr] == stitype).trialNum];
        segIndex = fix([trials.devOnset]');

    case "last std"
        trials = trialAll([trialAll.stdOrdr] == stitype);
        trialNum = [trialAll([trialAll.stdOrdr] == stitype).trialNum];
        segIndex = cellfun(@(x) x(end - 1), {trials.soundOnsetSeq}');

    case "control"
        trials = trialAll([trialAll.stdOrdr] == 0);
        trialNum = [trialAll([trialAll.stdOrdr] == 0).trialNum];
        segIndex = cell2mat(cellfun(@(x, y) y(ismember(x, stitype)), {trials.ordrSeq}', {trials.soundOnsetSeq}', 'UniformOutput', false));
    case 'all trial'
        trialNum = [];
end

if isempty(segIndex)
    trialSpike{1} = [];
    sampleinfo = [];
else
    if segIndex(1) <= 0
        segIndex(1) = 1;
    end

    trialSpike = cell(length(segIndex), length(spikeDataset));
    % by channel    
    for cIndex = 1 : length(spikeDataset)        
        % by trial
        sampleinfo = zeros(length(segIndex), 2);
        temp = spikeDataset(cIndex).spike;
        for tIndex = 1:length(segIndex)
            sampleinfo(tIndex, :) = segIndex(tIndex) + windowIndex;
            if sum(temp > sampleinfo(tIndex, 1) & temp < sampleinfo(tIndex, 2)) ~= 0
                trialSpike{tIndex, cIndex}(:, 1) = temp(temp >= sampleinfo(tIndex, 1) & temp <= sampleinfo(tIndex, 2)) - segIndex(tIndex);
                trialSpike{tIndex, cIndex}(:, 2) = ones(length(trialSpike{tIndex, cIndex}), 1) * tIndex;
            end
        end
    end
    trialSpike = trialSpike';
   return;
end
