ccc

%%  MGB
ROOTPATH = "E:\MonkeyLinearArray\Figure\CTL_New";
protStr = "TB_BaseICI_4_8_16";

% parameters
CTLParams = MLA_ParseCTLParams(protStr);
params = structSelect(CTLParams, ["S1Duration", "stimStr"]);

%% configuration
params.winOnsetResp    = [0, 200];  params.winOnsetBase    = [-200, 0];
params.winChangeResp   = [0, 200];  params.winChangeBase   = [-200, 0];
params.binpara.binsize = 10;        params.binpara.binstep = 1; 
params.absThr          = 10;        params.sdThr         = 1;

%% MGB
popRes = loadDailyData(ROOTPATH, "MATNAME", "spkRes.mat", "protocols", protStr, "DATE", "MGB");
temp = popRes.(protStr);
if ~iscolumn(temp)
    temp = temp';
end

resMGB = cell2mat(rowFcn(@(x) batchSpkData(x, params), temp, "UniformOutput", false));
onsetIdx = changeCellRowNum(cellfun(@(x) [x.H]', {resMGB.onsetRes}', "UniformOutput", false));
changeIdx =  changeCellRowNum(cellfun(@(x) [x.H]', {resMGB.changeRes}', "UniformOutput", false));
sigOnset = cellfun(@(x) resMGB(x), onsetIdx, "uni", false);
sigChange = cellfun(@(x, y) resMGB(x & y), changeIdx, onsetIdx, "uni", false);
sigOnsetRes.MGB = cell2struct([sigOnset, sigChange], ["sigOnset", "sigChange"], 2);

%% AC
popRes = loadDailyData(ROOTPATH, "MATNAME", "spkRes.mat", "protocols", protStr, "DATE", "AC");
temp = popRes.(protStr);
if ~iscolumn(temp)
    temp = temp';
end

resAC = cell2mat(rowFcn(@(x) batchSpkData(x, params), temp, "UniformOutput", false));
onsetIdx = changeCellRowNum(cellfun(@(x) [x.H]', {resAC.onsetRes}', "UniformOutput", false));
changeIdx =  changeCellRowNum(cellfun(@(x) [x.H]', {resAC.changeRes}', "UniformOutput", false));
sigOnset = cellfun(@(x) resAC(x), onsetIdx, "uni", false);
sigChange = cellfun(@(x, y) resAC(x & y), onsetIdx, changeIdx, "uni", false);
sigOnsetRes.AC = cell2struct([sigOnset, sigChange], ["sigOnset", "sigChange"], 2);

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

