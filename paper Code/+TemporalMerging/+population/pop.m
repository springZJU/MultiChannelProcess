%% DDZ MGB
ROOTPATH = "E:\MonkeyLinearArray\Figure\CTL_New";
protStr = "TB_BaseICI_4_8_16";
popRes = loadDailyData(ROOTPATH, "MATNAME", "spkRes.mat", "protocols", protStr, "DATE", ["cm", "MGB"]);

% parameters
CTLParams = MLA_ParseCTLParams(protStr);
temp = popRes.(protStr);

% find neurons that have significant onset response, select 
if ~iscolumn(temp)
    temp = temp';
end
params = structSelect(CTLParams, ["S1Duration", "stimStr"]);
params.winOnset1 = [0, 200]; params.winOnset2 = [-200, 0];
params.winChange1 = [0, 200]; params.winChange2 = [-200, 0];
params.binpara.binsize = 10; params.binpara.binstep = 1; 

res = rowFcn(@(x) batchSpkData(x, params), temp, "UniformOutput", false);
onsetRes = cell2mat(cellfun(@(x) x.Onset, res, "UniformOutput", false));
changeRes = cell2mat(cellfun(@(x) x.Change, res, "UniformOutput", false));
changeOnsetIdx = cell2mat(cellfun(@(x) x(1).H, {changeRes.stimRes}', "UniformOutput", false));
sigOnsetRes.DDZ_MGB = changeRes([onsetRes.H]');
sigOnChangeRes.DDZ_MGB = changeRes([onsetRes.H]' == 1 & changeOnsetIdx);

%% DDZ AC
clearvars -except sigOnChangeRes sigOnsetRes ROOTPATH protStr
popRes = loadDailyData(ROOTPATH, "MATNAME", "spkRes.mat", "protocols", protStr, "DATE", ["cm", "AC"]);

% parameters
CTLParams = MLA_ParseCTLParams(protStr);
temp = popRes.(protStr);

% find neurons that have significant onset response, select 
if ~iscolumn(temp)
    temp = temp';
end
params = structSelect(CTLParams, ["S1Duration", "stimStr"]);
params.winOnset1 = [0, 200]; params.winOnset2 = [-200, 0];
params.winChange1 = [0, 200]; params.winChange2 = [-200, 0];
res = rowFcn(@(x) batchSpkData(x, params), temp, "UniformOutput", false);
onsetRes = cell2mat(cellfun(@(x) x.Onset, res, "UniformOutput", false));
changeRes = cell2mat(cellfun(@(x) x.Change, res, "UniformOutput", false));
changeOnsetIdx = cell2mat(cellfun(@(x) x(1).H, {changeRes.stimRes}', "UniformOutput", false));
sigOnsetRes.DDZ_AC = changeRes([onsetRes.H]');
sigOnChangeRes.DDZ_AC = changeRes([onsetRes.H]' == 1 & changeOnsetIdx);


%% integration
% part1: ratio of significant change response in neurons with onset response
integrationRes(1).nameStr = "ratio of neurons with change";
integrationRes(1).DDZ_AC = [length(sigOnChangeRes.DDZ_AC), length(sigOnsetRes.DDZ_AC), length(sigOnChangeRes.DDZ_AC)/length(sigOnsetRes.DDZ_AC)];
integrationRes(1).DDZ_MGB = [length(sigOnChangeRes.DDZ_MGB), length(sigOnsetRes.DDZ_MGB), length(sigOnChangeRes.DDZ_MGB)/length(sigOnsetRes.DDZ_MGB)];

% part2: repsonse ratio of neurons with onset response
integrationRes(2).nameStr = "resp level with onset";
integrationRes(2).DDZ_AC = [sigOnChangeRes.DDZ_AC.changeOnRatio]';
integrationRes(2).DDZ_MGB = [sigOnChangeRes.DDZ_MGB.changeOnRatio]';

% part3: repsonse ratio of neurons with change response
integrationRes(3).nameStr = "resp level with change";
integrationRes(3).DDZ_AC = [sigOnsetRes.DDZ_AC.changeOnRatio]';
integrationRes(3).DDZ_MGB = [sigOnsetRes.DDZ_MGB.changeOnRatio]';

