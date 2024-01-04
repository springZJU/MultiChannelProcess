function trialAll = PassiveProcess_clickTrainMSTIChain(epocs)
onIdx         = find([0; diff(abs(roundn(epocs.ICI0.data, -1)))]);
ICI           = epocs.ICI0.data(onIdx);
ordr          = epocs.ordr.data(onIdx);
soundOnset    = epocs.ICI0.onset(onIdx+1);

trialOnset    = epocs.Swep.onset;
[~, trialSeg] = cellfun(@(x) min(abs(soundOnset - x)), num2cell(trialOnset));
trialNum      = cell2mat(cellfun(@(x, y) ones(x, 1)*y, num2cell(diff([trialSeg; length(soundOnset)+1])), num2cell(1:length(trialSeg))', "UniformOutput", false));
trialOnsets   = cell2mat(cellfun(@(x, y) x*ones(sum(trialNum == y), 1), num2cell(trialOnset), num2cell(unique(trialNum)), "UniformOutput", false));
ICIMin = min(ICI); ICIMax = max(ICI); BG = unique(ICI(~ismember(ICI, [max(ICI), min(ICI)])));
stimType(ICI  == BG & ordr == 1, 1)     = "BG-REG-SmallSTD";
stimType(ICI  == BG & ordr == 2, 1)     = "BG-IRREG-SmallSTD";
stimType(ICI  == BG & ordr == 3, 1)     = "BG-REG-LargeSTD";
stimType(ICI  == BG & ordr == 4, 1)     = "BG-IRREG-LargeSTD";
stimType(ICI  == ICIMin & ordr == 1, 1) = "STD-REG-Small";
stimType(ICI  == ICIMin & ordr == 2, 1) = "STD-IRREG-Small";
stimType(ICI  == ICIMin & ordr == 3, 1) = "DEV-REG-Small";
stimType(ICI  == ICIMin & ordr == 4, 1) = "DEV-IRREG-Small";
stimType(ICI  == ICIMax & ordr == 3, 1) = "STD-REG-Large";
stimType(ICI  == ICIMax & ordr == 4, 1) = "STD-IRREG-Large";
stimType(ICI  == ICIMax & ordr == 1, 1) = "DEV-REG-Large";
stimType(ICI  == ICIMax & ordr == 2, 1) = "DEV-IRREG-Large";

firstPos      = cellfun(@(x) find(trialNum == x, 1, "first"), num2cell(unique(trialNum)));
lastPos       = cellfun(@(x) find(trialNum == x, 1, "last"), num2cell(unique(trialNum)));
stimPos       = repmat("unimportant", length(trialNum), 1);
stimPos(firstPos) = "trial On";  stimPos(lastPos) = "trial End";

devIdx        = (find(contains(stimType, "DEV-"))+1)/2;
dist2Dev      = cell2mat(cellfun(@(x) reshape(repmat(1:x, 2, 1), [], 1) - ones(x*2, 1)*x, num2cell(diff([0; devIdx])), "UniformOutput", false));

trialAll      = cell2struct([num2cell([trialNum, soundOnset, ICI, ordr, [dist2Dev; nan(length(trialNum)-length(dist2Dev), 1)]]), cellstr(stimType), cellstr(stimPos)], ["trialNum", "soundOnsetSeq", "ICI", "ordr", "dist2Dev", "stimType", "stimPos"], 2);
trialAll([trialAll.ICI] == BG) = [];
end


