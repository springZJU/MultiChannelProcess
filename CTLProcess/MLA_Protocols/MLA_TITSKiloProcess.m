function MLA_TITSKiloProcess(BLOCKPATH, MATPATH, FIGPATH)
addpath(genpath('K:\Program'), '-begin');
%% Parameter setting
params.processFcn = @PassiveProcess_clickTrainRNP;
fdMUA = 1000;

%% load data and params
try
    kilospikes = load(strcat(MATPATH, "spkData.mat"), "data");
    sortdata = kilospikes.data.sortdata;
catch
    error("No kilosort data!");
end

temp = dir(FIGPATH);
Exist_Single = any(contains(string({temp.name}), "CH"));
Exist_CSD_MUA = 1;
Exist_LFP_By_Ch = 1;
Exist_LFP_Acorss_Ch = 1;
if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_CSD_MUA, Exist_Single])
    return
end

temp = strsplit(FIGPATH, "\");
protStr = temp(end - 2);
[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(char(BLOCKPATH), params);
TITSParams = MLA_ParseTITSParams(protStr);
parseStruct(TITSParams);
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
if contains(protStr, "Insert")
    temp = cellfun(@(x) S1Duration + x, OnsetTemp, "UniformOutput", false);
end
trialAll = addFieldToStruct(trialAll, temp, "devOnset");
trialAll(1) = [];

%% split data
[trialsLFPRaw, ~, ~] = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
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
% spikes, after kilosort
chSelectForLFP = [spikeDataset.realCh]';
spikeDataset = [];
sortIDs = unique(sortdata(:, 2));
for sortIDidx = 1 : numel(sortIDs)
    selectspikeidx = find(sortdata(:, 2) == sortIDs(sortIDidx));
    IDspkiestimes = sortdata(selectspikeidx, 1);

    spikeDataset(sortIDidx, 1).ch = sortIDs(sortIDidx);
    spikeDataset(sortIDidx, 1).spike = IDspkiestimes * 1000;
end

trialsSpike = selectSpike(spikeDataset, trialAllRaw, TITSParams, "dev onset");

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
    if contains(protStr, "Insert")
        for chIdx = 1 : numel(spikePlot)
            chRS{chIdx}(1) = RayleighStatistic(spikePlot{chIdx}(:, 1), BaseICI);
            chRS{chIdx}(2) = BaseICI;
        end
    end
    psthPara.binsize = 30; % ms
    psthPara.binstep = 1; % ms
    chPSTH = cellfun(@(x) calPsth(x(:, 1), psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "uni", false);
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

%% Plot Figure
% single unit
if ~Exist_Single
    mkdir(FIGPATH);
    TITSParams.FIGPATH = FIGPATH; 
    chPlotFcn = eval(['@MLA_PlotRasterLfp_TITSKiloProcess;']);
    chPlotFcn(chSpikeLfp, TITSParams);
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

end


