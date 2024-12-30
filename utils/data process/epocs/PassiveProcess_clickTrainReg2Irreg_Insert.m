function trialAll = PassiveProcess_clickTrainReg2Irreg_Insert(epocs)
%% Information extraction
if ~isfield(epocs, "ordr")
    epocs.ordr = epocs.Swep;
end

temp = epocs.ICI0.data;
% if temp(1) == 4
    for k = 1:8
        temp(epocs.ordr.data == k) = epocs.ICI0.data(epocs.ordr.data == k+8);
    end
% else
%     for k = 9:16
%         temp(epocs.ordr.data == k) = epocs.ICI0.data(epocs.ordr.data == k-8);
%     end
% end

t          = epocs.ICI0.onset;
regIdx     = find(temp == 4);
regPos     = [0; find(diff(regIdx) > 1)] + 1;
regOnT     = t(regIdx(regPos)) * 1000;
insertN    = diff(regPos);
insertN    = [insertN; max(insertN)];
irregOnT   = t(regIdx(regPos) + insertN) * 1000;
nTypes     = length(insertN) / length(epocs.Swep.data);
trialOnset = reshape(repmat(epocs.Swep.onset, 1, nTypes)', [], 1) * 1000;

ordr = epocs.ordr.data([0; find(diff(epocs.ordr.onset) > 1)] + 1);
devOrdr = reshape(repmat(ceil(ordr/8) * 1000, 1, nTypes)', [], 1) + insertN;
ordrTemp = unique(devOrdr);
for dIndex = 1 : length(ordrTemp)
    devOrdr(devOrdr == ordrTemp(dIndex)) = dIndex;
end

dataCell = num2cell([(1:length(devOrdr))', trialOnset, regOnT, irregOnT, devOrdr, repmat(ceil(ordr/8), nTypes, 1)]);
dataName = ["trialNum", "soundOnsetSeq", "devOnset", "firstPush", "devOrdr", "type"];
trialAll = cell2struct(dataCell, dataName, 2);
end