% TDT block path
BLOCKPATH = 'G:\ECOG\DDZ\ddz20221224\Block-15'; 
params.processFcn = @PassiveProcess_clickTrainContinuous;
[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(BLOCKPATH, params);

%% load click train params
fd = 600;
protStr = "Offset_Variance_Effect_4ms_16ms_sigma250_2_500msReg";
CTLParams = MLA_ParseCTLParams(protStr);
CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), " = CTLParams.", CTLFields(fIndex), ";"));
end
lfpDataset = ECOGResample(lfpDataset, fd);

%% set trialAll
trialAll([trialAll.devOrdr] == 0) = [];
devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
[~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");
trialAll(1) = [];

%% split data
[trialsLFPRaw, ~, ~] = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
trialsLFPFiltered = ECOGFilter(trialsLFPRaw, 0.1, 200, fd);
[trialsLFPFiltered, ~, idx] = excludeTrialsChs(trialsLFPFiltered, 0.1);
trialsLFPRaw = trialsLFPRaw(idx);
trialAllRaw = trialAll;
trialAll = trialAll(idx);
t = linspace(Window(1), Window(2), size(trialsLFPFiltered{1}, 2))';

%% classify by devTypes
PMean = cell(length(devType), 1);
chMean = cell(length(devType), 1);
temp = cell(length(devType), 1);
chSpikeLfp = struct("stimStr", temp);
chAll = struct("stimStr", temp);
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    trialsLFP = trialsLFPFiltered(tIndex);
    chLFP = [];
    chMean{dIndex, 1} = cell2mat(cellfun(@mean , changeCellRowNum(trialsLFP), 'UniformOutput', false));
    for ch = 1 : size(chMean{dIndex, 1}, 1)
        chLFP(ch).info = strcat("CH", num2str(ch));
        chLFP(ch).Wave(:, 1) = t';
        chLFP(ch).Wave(:, 2) = chMean{dIndex, 1}(ch, :)';
    end
    chAll(dIndex).stimStr = stimStr(dIndex);
    chAll(dIndex).chLFP = chLFP;
end

%% plot Figure
for gIndex = 1 : length(Compare_Index) % the number of figure
    temp = Compare_Index{gIndex};
    for dIndex = 1 : length(temp)
        chData(dIndex).chMean = chMean{temp(dIndex), 1};
        chData(dIndex).color = colors(dIndex);
    end
    Fig(gIndex) = plotRawWaveMulti_SPR(chData, Window, [], [4, 4]);
    addLegend2Fig(Fig(gIndex), stimStr(temp));
    scaleAxes(Fig(gIndex), "x", [-50, 500]);
    scaleAxes(Fig(gIndex), "y", "on");
end




