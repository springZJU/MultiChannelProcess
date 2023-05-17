function MLA_MSTI_Process(MATPATH, FIGPATH)
%% Parameter setting
params.processFcn = @PassiveProcess_clickTrainContinuous;
fd = 500;
temp = string(strsplit(MATPATH, "\"));
dateStr = temp(end - 1);
protStr = temp(end - 2);
DATAPATH = strcat(MATPATH, "data.mat");
FIGPATH = strcat(FIGPATH, dateStr, "\");

temp = dir(FIGPATH);
Exist_Single = any(contains(string({temp.name}), "CH"));
Exist_CSD_MUA = any(contains(string({temp.name}), "LFP_Compare_CSD_MUA"));
Exist_LFP_By_Ch = any(contains(string({temp.name}), "LFP_ch"));
Exist_LFP_Acorss_Ch = any(contains(string({temp.name}), "LFP_Compare_Chs"));
if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_CSD_MUA, Exist_Single])
    return
end

[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(DATAPATH, params);

%% load MSTI params
MSTIParams = MLA_ParseMSTIParams(protStr);
MSTIFields = string(fields(MSTIParams));
for fIndex = 1 : length(MSTIFields)
    eval(strcat(MSTIFields(fIndex), " = MSTIParams.", MSTIFields(fIndex), ";"));
end
lfpDataset = ECOGResample(lfpDataset, fd);

%% set trialAll
devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
stdTemp = {trialAll.soundOnsetSeq}';
[~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
temp = cellfun(@(x, y) x + DevOnset(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");
temp = cellfun(@(x, y) x + Std_Dev_Onset(y, 1:end-1), stdTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "soundOnsetSeq");
trialAll(1) = [];

%% split data
[trialsLFPRaw, ~, ~] = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
trialsLFPFiltered = ECOGFilter(trialsLFPRaw, 0.1, 1000, fd);
[trialsLFPFiltered, ~, idx] = excludeTrialsChs(trialsLFPFiltered, 0.04);
trialAllRaw = trialAll;
trialAll = trialAll(idx);
if ~Exist_CSD_MUA
    [~, WAVEDataset] = MUA_Preprocess(MATPATH);
else
    WAVEDataset = lfpDataset; % with no significance in fact
end
trialsWAVE = selectEcog(WAVEDataset, trialAll, "dev onset", Window);

% spike
psthPara.binsize = 10; % ms
psthPara.binstep = 4; % ms
chSelect = [spikeDataset.realCh]';
trialsSpike = selectSpike(spikeDataset, trialAllRaw, psthPara, MSTIParams, "dev onset");

% initialize
t = linspace(Window(1), Window(2), size(trialsLFPFiltered{1}, 2))';


%% classify by devTypes
PMean = cell(length(devType), 1);
chMean = cell(length(devType), 1);
temp = cell(length(devType), 1);

chSpikeLfp = struct("stimStr", temp);
chAll = struct("stimStr", temp);

for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    tIndexRaw = [trialAllRaw.devOrdr] == devType(dIndex);
    trialsLFP = trialsLFPFiltered(tIndex);
    trialsWave = trialsWAVE(tIndex);
    trialsSPK = trialsSpike(tIndexRaw);
    chLFP = [];
    for ch = 1 : size(trialsLFPFiltered{1}, 1)
        chLFP(ch).info = strcat("CH", num2str(ch));
    end
    %% LFP
    % raw wave
    chMean{dIndex, 1} = cell2mat(cellfun(@mean , changeCellRowNum(trialsLFP), 'UniformOutput', false));

    if ~Exist_CSD_MUA
    % CSD
    [badCh, dz] = MLA_CSD_Config(MATPATH);
    CSD = CSD_Process(trialsLFP, Window, "kCSD", badCh, dz);
    % MUA
    MUA = MUA_Process(trialsWave, Window, selWin, WAVEDataset.fs);
    else
        CSD = [];
        MUA = [];
    end

    for ch = 1 : size(chMean{dIndex, 1}, 1)
        chLFP(ch).Wave(:, 1) = t';
        chLFP(ch).Wave(:, 2) = chMean{dIndex, 1}(ch, :)';
    end

    %% spike
    spikePlot = cellfun(@(x) cell2mat(x), num2cell(struct2cell(trialsSPK)', 1), "UniformOutput", false);
    chPSTH = cellfun(@(x) calPsth(x(:, 1), psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "uni", false);
    chStr = fields(trialsSPK)';
    chSPK = cell2struct([chStr; spikePlot; chPSTH], ["info", "spikePlot", "PSTH"]);

    % integration
    chSpikeLfp(dIndex).trialNum = sum(tIndexRaw);
    chSpikeLfp(dIndex).stimStr = stimStr(dIndex);
    chSpikeLfp(dIndex).chSPK = chSPK;
    chSpikeLfp(dIndex).chLFP = chLFP(chSelect);
    chAll(dIndex).chLFP = chLFP;
    chAll(dIndex).chCSD = CSD;
    chAll(dIndex).chMUA = MUA;
end

%% Plot Figure

% single unit
if ~Exist_Single
    Fig = chPlotFcn(chSpikeLfp, MSTIParams);
    mkdir(FIGPATH);
    for cIndex = 1 : length(Fig)
        print(Fig(cIndex), strcat(FIGPATH, "CH", num2str(spikeDataset(cIndex).ch)), "-djpeg", "-r300");
        close(Fig(cIndex));
    end
end

% lfp of whole period
if ~Exist_LFP_By_Ch
    FigLFP = MLA_PlotLfpByCh(chAll, MSTIParams);
    scaleAxes(FigLFP, "x", plotWin);
    scaleAxes(FigLFP, "y", "on");
    print(FigLFP, strcat(FIGPATH, "LFP_ch"), "-djpeg", "-r300");
end

% lfp comparison acorss channels
if ~Exist_LFP_Acorss_Ch
    FigLFPCompare = MLA_PlotLfpAcrossCh(chAll, MSTIParams);
    print(FigLFPCompare, strcat(FIGPATH, "LFP_Compare_Chs"), "-djpeg", "-r300");
end

% CSD comparison
if ~Exist_CSD_MUA
    FigCSD = MLA_Plot_CSD_MUA_AcrossCh(chAll, MSTIParams);
    scaleAxes(FigCSD, "x", [-1000, 1000]);
    print(FigCSD, strcat(FIGPATH, "LFP_Compare_CSD_MUA"), "-djpeg", "-r300");
end
close all;
end


