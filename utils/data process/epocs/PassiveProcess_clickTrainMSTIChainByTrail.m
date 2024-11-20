function trialAll = PassiveProcess_clickTrainMSTIChainByTrail(epocs)
%check ICI sequence
ICISeqIdx = find(roundn(epocs.ICI0.data, -1) == roundn(mode(epocs.ICI0.data), -1));% BGICI
% ICISeqIdx = find(roundn(epocs.ICI0.data, -1) == 5);
epocs.ICI0.data = epocs.ICI0.data(ICISeqIdx(1):ICISeqIdx(end));
epocs.ICI0.onset = epocs.ICI0.onset(ICISeqIdx(1):ICISeqIdx(end));
epocs.ICI0.offset = epocs.ICI0.offset(ICISeqIdx(1):ICISeqIdx(end));
epocs.ordr.data = epocs.ordr.data(ICISeqIdx(1):ICISeqIdx(end));
epocs.ordr.onset = epocs.ordr.onset(ICISeqIdx(1):ICISeqIdx(end));
epocs.ordr.offset = epocs.ordr.offset(ICISeqIdx(1):ICISeqIdx(end));

ExcludeICIIdx  = find(roundn(epocs.ICI0.data, -1) == 0);
epocs.ICI0.data(ExcludeICIIdx) = [];
epocs.ICI0.onset(ExcludeICIIdx) = [];
epocs.ICI0.offset(ExcludeICIIdx) = [];
epocs.ordr.data(ExcludeICIIdx) = [];
epocs.ordr.onset(ExcludeICIIdx) = [];
epocs.ordr.offset(ExcludeICIIdx) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
onIdx         = find([0; diff(abs(roundn(epocs.ICI0.data, -1)))]);
onIdx         = onIdx(1:2:end);
ICI           = epocs.ICI0.data(onIdx);
ordr          = epocs.ordr.data(onIdx);
soundOnset    = epocs.ICI0.onset(onIdx+1) * 1000;

trialOnset    = epocs.Swep.onset * 1000;
[~, trialSeg] = cellfun(@(x) min(abs(soundOnset - x)), num2cell(trialOnset));
trialNum      = cell2mat(cellfun(@(x, y) ones(x, 1)*y, num2cell(diff([trialSeg; length(soundOnset)+1])), num2cell(1:length(trialSeg))', "UniformOutput", false));

ICIMin = min(ICI); ICIMax = max(ICI);
trialType(ICI == ICIMin & ordr == 1, 1) = "S1S2-REG-STD";
trialType(ICI == ICIMin & ordr == 2, 1) = "S1S2-IRREG-STD";
trialType(ICI == ICIMin & ordr == 3, 1) = "S2S1-REG-DEV";
trialType(ICI == ICIMin & ordr == 4, 1) = "S2S1-IRREG-DEV";
trialType(ICI == ICIMax & ordr == 1, 1) = "S1S2-REG-DEV";
trialType(ICI == ICIMax & ordr == 2, 1) = "S1S2-IRREG-DEV";
trialType(ICI == ICIMax & ordr == 3, 1) = "S2S1-REG-STD";
trialType(ICI == ICIMax & ordr == 4, 1) = "S2S1-IRREG-STD";
devIdx        = find(contains(trialType, "DEV"));

% exclude STD behind the last dev in a chain
temp          = trialSeg(cellfun(@(x) isempty(find(devIdx == x-1, 1)), num2cell(trialSeg)));
excludeSTD    = cell2mat(cellfun(@(x) (devIdx(find(devIdx - x < 0, 1, "last"))+1 : x-1)', num2cell(temp(2:end)), "UniformOutput", false));
if devIdx < length(trialNum); excludeSTD = [excludeSTD', devIdx(end)+1 : length(trialNum)]'; end
trialType(excludeSTD) = []; trialNum(excludeSTD) = []; ordr(excludeSTD) = []; soundOnset(excludeSTD) = []; ICI(excludeSTD) = []; devIdx  = find(contains(trialType, "DEV"));

% construct struct
cellTemp      = mat2cell([trialNum, ordr, soundOnset, ICI], diff([0; devIdx]), ones(4, 1));
devOnset      = cellfun(@(x) x(end), cellTemp(:, 3), "UniformOutput", false);
stdNum        = cellfun(@(x) length(x) - 1, cellTemp(:, 3), "UniformOutput", false);
trialAll      = cell2struct([cellfun(@unique, cellTemp(:, 1:2), "UniformOutput", false), stdNum, cellTemp(:, 3:end), devOnset], ... 
                            ["trialNum", "devOrdr", "stdNum", "soundOnsetSeq", "ICI", "devOnset"], 2);
end


