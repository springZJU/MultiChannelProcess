clear;clc;
MATPATH = 'H:\AC\DDZ\ddz20230904\Block-12';
% MATPATH = 'H:\AC\CM\cm20230905\Block-9';
FIGPATH = MATPATH;

%% Parameter setting
params.processFcn = @PassiveProcess_clickTrainRNP;
protStr = "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s";
% protStr = "Insert_ICI15.2_ratio1.02_N1-2-4-8";

DATAPATH = MATPATH;
FIGPATH = strcat(FIGPATH, "\");

temp = dir(FIGPATH);
Exist_Single = any(contains(string({temp.name}), "CH"));
% Exist_CSD_MUA = any(contains(string({temp.name}), "LFP_Compare_CSD_MUA"));
Exist_CSD_MUA = 1;
% Exist_LFP_By_Ch = any(contains(string({temp.name}), "LFP_ch"));
Exist_LFP_By_Ch = 1;
% Exist_LFP_Acorss_Ch = any(contains(string({temp.name}), "LFP_Compare_Chs"));
Exist_LFP_Acorss_Ch = 0;
% if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_CSD_MUA, Exist_Single])
%     return
% end

[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(DATAPATH, params);

%% load click train params
if contains(protStr, "MSTI")
    MSTIParams = MLA_ParseMSTIParams(protStr);
elseif contains(protStr, "Insert")
    MSTIParams = MLA_ParseTITSParams(protStr);
end
parseStruct(MSTIParams);
fd = lfpDataset.lfp.fs;

if ~isequal(lfpDataset.lfp.fs, fd)
    lfpDataset = ECOGResample(lfpDataset.lfp, fd);
else
    lfpDataset = lfpDataset.lfp;
end

%% set trialAll
trialAll([trialAll.devOrdr] == 0) = [];
devType = unique([trialAll.devOrdr]);
OnsetTemp = {trialAll.devOnset}';
[~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
ordTemp = num2cell(ordTemp);
temp = cellfun(@(x) S1Duration + x, OnsetTemp, "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");
trialAll(1) = [];

%% split data
[trialsLFPRaw, ~, ~] = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
trialsLFPFiltered = ECOGFilter(trialsLFPRaw, 0.1, 200, fd);
[trialsLFPFiltered, ~, idx] = excludeTrialsChs(trialsLFPFiltered, 0.1);
trialsLFPRaw = trialsLFPRaw(idx);
trialAllRaw = trialAll;
trialAll = trialAll(idx);
if ~Exist_CSD_MUA
    [~, WAVEDataset] = MUA_Preprocess(MATPATH);
    trialsWAVE = selectEcog(WAVEDataset, trialAll, "dev onset", Window);
end
% spike
chSelect = [spikeDataset.realCh]';
trialsSpike = selectSpike(spikeDataset, trialAllRaw, MSTIParams, "dev onset");
% initialize
t = linspace(Window(1), Window(2), size(trialsLFPFiltered{1}, 2))';
tFFT = linspace(Window(1), Window(2), size(trialsLFPRaw{1}, 2))';

%% classify by devTypes
PMean = cell(length(devType), 1);
chMean = cell(length(devType), 1);
temp = cell(length(devType), 1);
chSpikeLfp = struct("stimStr", temp);
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
    tIdx = find(tFFT > FFTWin(1) & tFFT < FFTWin(2));
    [ff, PMean{dIndex, 1}, trialsFFT]  = trialsECOGFFT(trialsToFFT, lfpDataset.fs, tIdx, [], 2);
    % raw wave
    chMean{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(trialsLFP), 'UniformOutput', false));
    % chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsLFP), 'UniformOutput', false));
    if ~Exist_CSD_MUA
        fdMUA = 1000;
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
    for chIdx = 1 : numel(spikePlot)
        chRS{chIdx}(1) = RayleighStatistic(spikePlot{chIdx}(:, 1), BaseICI);
        chRS{chIdx}(2) = BaseICI;
    end
    psthPara.binsize = 30; % ms
    psthPara.binstep = 1; % ms
    chPSTH = cellfun(@(x) calPsth(x(:, 1), psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "uni", false);
    chStr = fields(trialsSPK)';
    chSPK = cell2struct([chStr; spikePlot; chPSTH; chRS], ["info", "spikePlot", "PSTH", "chRS"]);

    % integration
    chSpikeLfp(dIndex).trials = find(tIndex)';
    chSpikeLfp(dIndex).trialsRaw = find(tIndexRaw)';
    chSpikeLfp(dIndex).trialNum = sum(tIndex);
    chSpikeLfp(dIndex).trialNumRaw = sum(tIndexRaw);
    chSpikeLfp(dIndex).stimStr = stimStrs(dIndex);
    chSpikeLfp(dIndex).chSPK = chSPK;
    chSpikeLfp(dIndex).chLFP = LFP(chSelect);
    chAll(dIndex).info = stimStrs(dIndex);
    chAll(dIndex).chLFP = LFP;
    chAll(dIndex).chCSD = CSD;
    chAll(dIndex).chMUA = MUA;
    chAll(dIndex).rawLFP = rawLFP;
end

%% Plot Figure

% single unit
if ~Exist_Single
    mkdir(FIGPATH);
    MSTIParams.FIGPATH = FIGPATH;
    chPlotFcn(chSpikeLfp, MSTIParams);
end

% lfp of whole period
% if ~Exist_LFP_By_Ch
%     FigLFP = MLA_PlotLfpByCh(chAll, MSTIParams);
%     scaleAxes(FigLFP, "x", plotWin);
%     scaleAxes(FigLFP, "y", "on");
%     print(FigLFP, strcat(FIGPATH, "LFP_ch"), "-djpeg", "-r300");
% end

% lfp comparison acorss channels
% if ~Exist_LFP_Acorss_Ch
%     FigLFPCompare = MLA_PlotLfpAcrossCh_version1(chAll, MSTIParams);
%     scaleAxes(FigLFPCompare, "x", compareWin);
%     scaleAxes(FigLFPCompare, "y", [-250, 250]);
%     print(FigLFPCompare, strcat(FIGPATH, "LFP_Compare_Chs"), "-djpeg", "-r300");
% end

% CSD comparison
% if ~Exist_CSD_MUA
%     FigCSD = MLA_Plot_CSD_MUA_AcrossCh(chAll, CTLParams);
%     scaleAxes(FigCSD, "x", [-300, 600]);
%     AxesCSD = getObjVal(FigCSD, "FigOrAxes", [], "Tag", "CSD");
%     scaleAxes(AxesCSD, "c", "on", "symOpts", "max");
%     AxesMUA = getObjVal(FigCSD, "FigOrAxes", [], "Tag", "MUA");
%     scaleAxes(AxesMUA, "c", "on");
%     print(FigCSD, strcat(FIGPATH, "LFP_Compare_CSD_MUA"), "-djpeg", "-r300");
% end
SAVENAME = strcat(FIGPATH, "res.mat");
% for dIndex = 1 : length(chAll)
%     chAll(dIndex).chCSD = rmfield(chAll(dIndex).chCSD, ["Data", "t"]);
%     chAll(dIndex).chMUA = rmfield(chAll(dIndex).chMUA, ["Data", "tImage"]);
% end
save(SAVENAME, "chSpikeLfp", "chAll", "trialAll", "trialAllRaw", "-mat");
close all;



