function MLA_MSTIRegProcess(DATAPATH, FIGPATH)
addpath(genpath('K:\Program'), '-begin');
%% Parameter setting
params.processFcn = @PassiveProcess_clickTrainMSTIChainByTrail;

%% load data and params
% Exist_Single = any(contains(string({temp.name}), "CH"));
Exist_Single = 0;
Exist_CSD_MUA = 1;
Exist_LFP_By_Ch = 1;
Exist_LFP_Acorss_Ch = 1;
if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_CSD_MUA, Exist_Single])
    return
end

temp = strsplit(FIGPATH, "\");
try
    protStr = evalin("base", "protStr");
catch
    protStr = temp(end - 2);
end
[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(char(DATAPATH), params);
MSTIRegParams = MLA_ParseMSTIRegParams(protStr);
parseStruct(MSTIRegParams);
fd = lfpDataset.fs;
%% set trialAll
trialAll([trialAll.devOrdr] == 0) = [];
devType = unique([trialAll.devOrdr]);
% OnsetTemp = {trialAll.devOnset}';
% [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
% ordTemp = num2cell(ordTemp);
% temp = cellfun(@(x, y) MSTIsoundinfo(x).Std_Dev_Onset(end) + y, ordTemp, OnsetTemp, "UniformOutput", false);
% trialAll = addFieldToStruct(trialAll, temp, "devOnset");
trialAll(1) = [];
MSTIRegParams.tStdToDev     = sortrows(unique(cell2mat(cellfun(@(x, y) [roundn(diff(x([end-1, end])), -1), y], {trialAll.soundOnsetSeq}', {trialAll.devOrdr}', "UniformOutput", false)), "rows"), 2);
MSTIRegParams.Std_Dev_Onset = cellfun(@(x) x*(-1*mode([trialAll.stdNum]):0), num2cell(MSTIRegParams.tStdToDev(:, 1)), "UniformOutput", false);

%% split data
[trialsLFPRaw, ~, ~] = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
trialsLFPFiltered = ECOGFilter(trialsLFPRaw, 0.1, 200, lfpDataset.fs);
tIdx = excludeTrials(trialsLFPFiltered, 0.1);
trialsLFPFiltered(tIdx) = [];
trialsLFPRaw(tIdx) = [];
trialAllRaw = trialAll;
trialAll(tIdx) = [];
if ~Exist_CSD_MUA
    [~, WAVEDataset] = MUA_Preprocess(DATAPATH);
    trialsWAVE = selectEcog(WAVEDataset, trialAll, "dev onset", Window);
end
% spikes, after kilosort
chSelectForLFP = [spikeDataset.realCh]';
trialsSpike = selectSpike(spikeDataset, trialAllRaw, MSTIRegParams, "dev onset");

%% classify by devTypes
% initialize
t = linspace(Window(1), Window(2), size(trialsLFPFiltered{1}, 2))';
tFFT = linspace(Window(1), Window(2), size(trialsLFPRaw{1}, 2))';
PMean = cell(length(devType), 1);
chMean = cell(length(devType), 1);
temp = cell(length(devType), 1);
chSpikeLfp = struct("stimStr", temp);

% diff stims
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    tIndexRaw = [trialAllRaw.devOrdr] == devType(dIndex);
    trialsToFFT = trialsLFPRaw(tIndex);
    trialsLFP = trialsLFPFiltered(tIndex);
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
    % cwt
    [TFR{dIndex}, t_fsD, f, coi{dIndex}] = computeTFR(chMean{dIndex}, lfpDataset.fs, fd, Window);

    if ~Exist_CSD_MUA
        fdMUA = 1000;
        % CSD
        [badCh, dz] = MLA_CSD_Config(DATAPATH);
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
        LFP(ch).cwt_time = t_fsD';
        LFP(ch).cwt_f = f;
        LFP(ch).cwt = TFR{dIndex}{ch};
    end

    rawLFP.t = t';
    rawLFP.rawWave = trialsToFFT;
    rawLFP.f = ff';
    rawLFP.FFT = trialsFFT;

    %% spike
    spikePlot = cellfun(@(x) cell2mat(x), num2cell(struct2cell(trialsSPK)', 1), "UniformOutput", false);
    for ICIidx = 1 : size(BaseICI, 2)
        for chIdx = 1 : numel(spikePlot)
            chRS{chIdx}(ICIidx, 1) = RayleighStatistic(spikePlot{chIdx}(:, 1), BaseICI(dIndex, ICIidx), numel(trialsSPK));
            chRS{chIdx}(ICIidx, 2) = BaseICI(dIndex, ICIidx);
        end
    end
    %     minBaseICI = min(BaseICI, [], "all");
    psthPara.binsize = 30; % ms
    psthPara.binstep = 5; % ms
    chPSTH = cellfun(@(x) calPsth(x, psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "uni", false);
    chStr = fields(trialsSPK)';
    kilochSPK = cell2struct([chStr; spikePlot; chPSTH; chRS], ["info", "spikePlot", "PSTH", "chRS"]);

    % integration
    chSpikeLfp(dIndex).trials = find(tIndex)';
    chSpikeLfp(dIndex).trialsRaw = find(tIndexRaw)';
    chSpikeLfp(dIndex).trialNum = sum(tIndex);
    chSpikeLfp(dIndex).trialNumRaw = sum(tIndexRaw);
    chSpikeLfp(dIndex).stimStr = stimStrs(dIndex);
    chSpikeLfp(dIndex).chSPK = kilochSPK;
    chSpikeLfp(dIndex).chLFP = LFP(chSelectForLFP);
    chAll(dIndex).info = stimStrs(dIndex);
    chAll(dIndex).chLFP = LFP;
    chAll(dIndex).chCSD = CSD;
    chAll(dIndex).chMUA = MUA;
    chAll(dIndex).rawLFP = rawLFP;
end

%% save
chSpikeLfpCopy = chSpikeLfp;
% spikeRes
SAVENAME = strcat(FIGPATH, "spkRes.mat");
chSpikeLfp = rmfield(chSpikeLfpCopy, "chLFP");
save(SAVENAME, "chSpikeLfp", "trialAll", "trialAllRaw", "-mat");

% lfpRes
SAVENAME = strcat(FIGPATH, "lfpRes.mat");
chSpikeLfp = rmfield(chSpikeLfpCopy, "chSPK");
save(SAVENAME, "chSpikeLfp", "trialAll", "trialAllRaw", "-mat");

% lfpRaw
SAVENAME = strcat(FIGPATH, "lfpRaw.mat");
save(SAVENAME, "chAll", "trialAll", "trialAllRaw", "-mat");


%% Plot Figure
% single unit
if ~Exist_Single
%     mkdir(FIGPATH);
    MSTIRegParams.FIGPATH = FIGPATH;
    MSTIRegParams.trialAll = trialAll;
    chPlotFcn = @MLA_PlotRasterLfp_MSTIRegProcess;
    chPlotFcn(chSpikeLfpCopy, MSTIRegParams);
end

end


