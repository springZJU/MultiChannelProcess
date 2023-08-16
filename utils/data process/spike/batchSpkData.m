function res = batchSpkData(spkData, params)
parseStruct(params);
if ~iscolumn(spkData)
    spkData = spkData';
end

%% reorganize data
chSPK_All = {spkData.chSpikeLfp.chSPK}';
stimStr = {spkData.chSpikeLfp.stimStr}';
trialsRaw = {spkData.chSpikeLfp.trialsRaw}';
trialsAll = cell2mat(cellfun(@(x,y ) [x, y*ones(length(x), 1)], {spkData.chSpikeLfp.trialsRaw}', num2cell(1 : length(spkData.chSpikeLfp))', "UniformOutput", false));
for cIndex = 1 :length(spkData.chSpikeLfp(1).chSPK)
    frBasic(cIndex).dateStr = cellfun(@(x) [spkData.date, char(x(cIndex).info)], chSPK_All(1), "UniformOutput", false);
    frBasic(cIndex).spikeOnset = cell2mat(cellfun(@(x, y) [x(cIndex).spikePlot(:, 1)+y, x(cIndex).spikePlot(:, 2)], chSPK_All, num2cell(S1Duration)', "UniformOutput", false));
    frBasic(cIndex).spikeChange = cell2mat(cellfun(@(x) x(cIndex).spikePlot, chSPK_All, "UniformOutput", false));
    frBasic(cIndex).spikeStim = addFieldToStruct(rmfield(cell2mat(cellfun(@(x) x(cIndex), chSPK_All, "UniformOutput", false)), "info"), [stimStr, trialsRaw], ["stimStr"; "trialsRaw"]);
    frBasic(cIndex).trialsAll = trialsAll;
end

%% judge significant onset response
frResOnset = cell2mat(cellfun(@(x, y) spikeDiffWinTest(x, winOnset1, winOnset2, y(:, 1), "Tail", "right", "Alpha", 0.05), {frBasic.spikeOnset}', {frBasic.trialsAll}', "UniformOutput", false));
res.Onset = structcat(frBasic, frResOnset);

%% change response
for sIndex = 1 : length(frBasic)
    temp = frBasic(sIndex).spikeStim;
    tempRes{sIndex, 1} = cell2mat(cellfun(@(x, y) spikeDiffWinTest(x, winOnset1, winOnset2, y, "Tail", "right", "Alpha", 0.05), {temp.spikePlot}', {temp.trialsRaw}', "UniformOutput", false));
    tempOnset{sIndex, 1} = cell2mat(cellfun(@(x, y, z) spikeDiffWinTest(x, winOnset1+z, winOnset2+z, y, "Tail", "right", "Alpha", 0.05), {temp.spikePlot}', {temp.trialsRaw}', num2cell(S1Duration)', "UniformOutput", false));
    calPsth()
end
tempFR = cellfun(@(x) cell2mat({x.frMean_1}'), tempRes, "UniformOutput", false);
onsetFR = cellfun(@(x) cell2mat({x.frMean_1}'), tempOnset, "UniformOutput", false);
tempSE = cellfun(@(x) cell2mat({x.frSE_1}'), tempRes, "UniformOutput", false);
changeOnRatio = cellfun(@(x, y) cell2mat({x.frMean_1}') ./  cell2mat({y.frMean_1}'), tempRes, tempOnset, "UniformOutput", false);
frResChange = cell2struct([tempRes, onsetFR, tempFR, tempSE, tempOnset, changeOnRatio], ["stimRes"; "onsetFR"; "stimFR"; "stimSE"; "onsetRes"; "changeOnRatio"], 2);
res.Change = structcat(frBasic, frResChange);
end
