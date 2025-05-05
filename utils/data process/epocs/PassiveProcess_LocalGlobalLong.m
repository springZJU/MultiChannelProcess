function trialAll = PassiveProcess_LocalGlobalLong(epocs)
%% Information extraction
if ~isfield(epocs, "ordr")
    epocs.ordr = epocs.Swep;
end
changeT = evalin("base", "changeT");
S1Duration = evalin("base", "S1Duration");
ordr = epocs.ordr.data;
t    = epocs.ordr.onset;
devOnset = cell2mat(cellfun(@(x, y) (x*1000+changeT{y})', num2cell(t), num2cell(ordr), "UniformOutput", false));
devOrdr = cell2mat(cellfun(@(x) (1:length(changeT{1}))' + (1-mod(x, 2))*length(changeT{1}), num2cell(ordr), "UniformOutput", false));
trialOnset = cell2mat(cellfun(@(x, y) (x*1000+changeT{y} - S1Duration(y))', num2cell(t), num2cell(ordr), "UniformOutput", false));


dataCell = num2cell([(1:length(devOrdr))', trialOnset, devOnset, devOrdr, reshape(repmat(ordr, 1, length(changeT{1}))', [], 1)]);
dataName = ["trialNum", "soundOnsetSeq", "devOnset", "devOrdr", "type"];
trialAll = cell2struct(dataCell, dataName, 2);
end