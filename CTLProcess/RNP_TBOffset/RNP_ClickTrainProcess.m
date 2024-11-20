function RNP_ClickTrainProcess(MATPATH, FIGPATH)
%% Parameter setting
params.processFcn = @PassiveProcess_clickTrainRNP;

fdMUA = 1000;
temp = string(strsplit(MATPATH, "\"));
% dateStr = temp(end - 1);
protStr = temp(end - 2);
DATAPATH = MATPATH;
FIGPATH = strcat(FIGPATH, "\");

temp = dir(FIGPATH);
Exist_Single = any(contains(string({temp.name}), "CH"));
% Exist_CSD_MUA = any(contains(string({temp.name}), "LFP_Compare_CSD_MUA"));
Exist_CSD_MUA = 1;
% Exist_LFP_By_Ch = any(contains(string({temp.name}), "LFP_ch"));
Exist_LFP_By_Ch = 1;
% Exist_LFP_Acorss_Ch = any(contains(string({temp.name}), "LFP_Compare_Chs"));
Exist_LFP_Acorss_Ch = 1;
if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_CSD_MUA, Exist_Single])
    return
end

%% load data and click train params
[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(DATAPATH, params);
% trialAll(61:120) = [];
CTLParams = RNP_ParseCTLParams(protStr);
parseStruct(CTLParams);
fd = fs;

if ~isequal(lfpDataset.fs, fd)
    lfpDataset = ECOGResample(lfpDataset, fd);
end
%% set trialAll
trialAll([trialAll.devOrdr] == 0) = [];
if protStr == "Offset_ICI_1_16"
    trialAll([trialAll.devOrdr] == 6) = [];
end

devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
[~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");
trialAll(1) = [];

%% split data
[trialsLFPRaw, ~, ~] = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
if length(trialsLFPRaw) < length(trialAll)
    trialAll(end - length(trialAll)+length(trialsLFPRaw) + 1 : end) = [];
end
trialsLFPFiltered = ECOGFilter(trialsLFPRaw, 0.1, 200, fd);
tIdx = excludeTrials(trialsLFPFiltered, 0.1);
trialsLFPFiltered(tIdx) = [];
trialsLFPRaw(tIdx) = [];
trialAllRaw = trialAll;
trialAll(tIdx) = [];
if ~Exist_CSD_MUA
    [~, WAVEDataset] = MUA_Preprocess(MATPATH);
    trialsWAVE = selectEcog(WAVEDataset, trialAll, "dev onset", Window);
end

% spike
chSelect = [spikeDataset.realCh]';
find(chSelect == 0)
trialsSpike = selectSpike(spikeDataset, trialAllRaw, CTLParams, "dev onset");



%% classify by devTypes

% initialize
t = linspace(Window(1), Window(2), size(trialsLFPFiltered{1}, 2))';
tFFT = linspace(Window(1), Window(2), size(trialsLFPRaw{1}, 2))';
PMean = cell(length(devType), 1);
chMean = cell(length(devType), 1);
temp = cell(length(devType), 1);
chSpikeLfp = struct("stimStr", temp);
chAll = struct("stimStr", temp);

% diff stims
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    tIndexRaw = [trialAllRaw.devOrdr] == devType(dIndex);
    trialsToFFT = trialsLFPRaw(tIndex);
    trialsLFP = trialsLFPFiltered(tIndex);
    if ~Exist_CSD_MUA
        trialsWave = trialsWAVE(tIndex);
    end
    trialsSPK = trialsSpike(tIndexRaw);
    LFP = [];
    for ch = 1 : size(trialsLFPFiltered{1}, 1)
        LFP(ch).info = strcat("CH", num2str(ch));
    end
    %% LFP
    % FFT
    tIdx = find(tFFT > FFTWin(dIndex, 1) & tFFT < FFTWin(dIndex, 2));
    [ff, PMean{dIndex, 1}, trialsFFT]  = trialsECOGFFT(trialsToFFT, lfpDataset.fs, tIdx, [], 2);
    % raw wave
    chMean{dIndex, 1} = cell2mat(cellfun(@mean , changeCellRowNum(trialsLFP), 'UniformOutput', false));
%     chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsLFP), 'UniformOutput', false));

    if ~Exist_CSD_MUA
    % CSD
    [badCh, dz] = MLA_CSD_Config(MATPATH);
    CSD = CSD_Process(trialsLFP, Window, "kCSD", badCh, dz);

    % MUA
    MUA = MUA_Process(trialsWave, Window, selWin, WAVEDataset.fs, fdMUA);

    else
        CSD = [];
        MUA = [];
    end

    % LFP
    for ch = 1 : size(chMean{dIndex, 1}, 1)
        LFP(ch).Wave(:, 1) = t';
        LFP(ch).Wave(:, 2) = chMean{dIndex, 1}(ch, :)';
        LFP(ch).FFT(:, 1) = ff';
        LFP(ch).FFT(:, 2) = PMean{dIndex, 1}(ch, :)';
    end
    rawLFP.t = t';
    rawLFP.rawWave = trialsToFFT;
    rawLFP.f = ff';
    rawLFP.FFT = trialsFFT;

    

    %% spike
    spikePlot = cellfun(@(x) cell2mat(x), num2cell(struct2cell(trialsSPK)', 1), "UniformOutput", false);
    spkeCell  = cellfun(@(x) cellfun(@(y) y(:, 1), x, "UniformOutput", false), num2cell(struct2cell(trialsSPK)', 1), "UniformOutput", false);
    chRS = cellfun(@(x) RayleighStatistic(x(:, 1), BaseICI(dIndex),sum(tIndexRaw)), spikePlot, "UniformOutput", false);
    psthPara = evalin("base", "psthPara");
    [~, ~, chPSTH] = cellfun(@(x) calPSTH(x, Window, psthPara.binsize, psthPara.binstep), spkeCell, "UniformOutput", false);
%     chPSTH = cellfun(@(x) calPsth(x(:, 1), psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "UniformOutput", false);
    chStr = fields(trialsSPK)';
    chSPK = cell2struct([chStr; spikePlot; chPSTH; chRS], ["info", "spikePlot", "PSTH", "chRS"]);


    %% integration
    chSpikeLfp(dIndex).trials = find(tIndex)';
    chSpikeLfp(dIndex).trialsRaw = find(tIndexRaw)';
    chSpikeLfp(dIndex).trialNum = sum(tIndex);
    chSpikeLfp(dIndex).trialNumRaw = sum(tIndexRaw);
    chSpikeLfp(dIndex).stimStr = stimStr(dIndex);
    chSpikeLfp(dIndex).chSPK = chSPK;
    chSpikeLfp(dIndex).chLFP = LFP(chSelect);
    chAll(dIndex).info = stimStr(dIndex);
    chAll(dIndex).chLFP = LFP;
    chAll(dIndex).chCSD = CSD;
    chAll(dIndex).chMUA = MUA;
    chAll(dIndex).rawLFP = rawLFP;
end

% %% Plot Figure
mkdir(FIGPATH);
single unit
if ~Exist_Single
    mkdir(FIGPATH);
    chPlotFcn(chSpikeLfp, CTLParams);
end

% lfp of whole period
if ~Exist_LFP_By_Ch
    FigLFP = MLA_PlotLfpByCh(chAll, CTLParams);
    scaleAxes(FigLFP, "x", plotWin);
    scaleAxes(FigLFP, "y", "on");
    print(FigLFP, strcat(FIGPATH, "LFP_ch"), "-djpeg", "-r300");
end

% lfp comparison acorss channels
if ~Exist_LFP_Acorss_Ch
    FigLFPCompare = MLA_PlotLfpAcrossCh(chAll, CTLParams);
    scaleAxes(FigLFPCompare, "x", [-50, 500]);
    scaleAxes(FigLFPCompare, "y", "on");
    print(FigLFPCompare, strcat(FIGPATH, "LFP_Compare_Chs"), "-djpeg", "-r300");
end

% CSD comparison
if ~Exist_CSD_MUA
    FigCSD = MLA_Plot_CSD_MUA_AcrossCh(chAll, CTLParams);
    scaleAxes(FigCSD, "x", [-300, 600]);
    AxesCSD = getObjVal(FigCSD, "FigOrAxes", [], "Tag", "CSD");
    scaleAxes(AxesCSD, "c", "on", "symOpts", "max");
    AxesMUA = getObjVal(FigCSD, "FigOrAxes", [], "Tag", "MUA");
    scaleAxes(AxesMUA, "c", "on");
    print(FigCSD, strcat(FIGPATH, "LFP_Compare_CSD_MUA"), "-djpeg", "-r300");
    % reduce MUA/CSD data size
    for dIndex = 1 : length(chAll)
        chAll(dIndex).chCSD = rmfield(chAll(dIndex).chCSD, ["Data", "t"]);
        chAll(dIndex).chMUA = rmfield(chAll(dIndex).chMUA, ["Data", "tImage"]);
    end
end
SAVENAME = strcat(FIGPATH, "res.mat");

save(SAVENAME, "chSpikeLfp", "chAll", "trialAll", "trialAllRaw", "-mat");
close all;
end


