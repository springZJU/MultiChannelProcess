function Intrinsic(MATPATH, FIGPATH)
%% Parameter setting
params.processFcn = @PassiveProcess_clickTrainRNP;

temp = string(strsplit(MATPATH, "\"));
% dateStr = temp(end - 1);
protStr = temp(end - 2);
DATAPATH = MATPATH;
FIGPATH = strcat(FIGPATH, "\");

temp = dir(FIGPATH);
Exist_Single = any(contains(string({temp.name}), "CH"));
% Exist_LFP_By_Ch = any(contains(string({temp.name}), "LFP_ch"));
Exist_LFP_By_Ch = 1;
% Exist_LFP_Acorss_Ch = any(contains(string({temp.name}), "LFP_Compare_Chs"));
Exist_LFP_Acorss_Ch = 1;
% if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_Single])
%     return
% end

%% load data and click train params
[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(DATAPATH, params);

try
    protStr = evalin("base", "protStr");
end
CTLParams = MLA_ParseCTLParams(protStr);
parseStruct(CTLParams);
fd = 1000;
if ~isequal(lfpDataset.fs, fd)
    lfpDataset = ECOGResample(lfpDataset, fd);
end
%% set trialAll
trialAll([trialAll.devOrdr] == 0) = [];
if ~isequal(segPoint, 0)
    cellStart = cellfun(@(x, y) num2cell([[trialAll.soundOnsetSeq]'+x, [trialAll.devOnset]'+x, [trialAll.ordrSeq]'+y, [trialAll.stdOrdr]'+y, [trialAll.devOrdr]'+y]), num2cell(segPoint), num2cell(1:length(segPoint)), "UniformOutput", false);
    trialAllStart = cellfun(@(x) mRepFields(trialAll, x, ["soundOnsetSeq", "devOnset", "ordrSeq", "stdOrdr", "devOrdr"]), cellStart, "UniformOutput", false);
    trialAll = cell2mat(trialAllStart');
    stimStr = cellfun(@(x) strcat("dataWin: [", strjoin(string(x+Window+ordr2Onset), " "), "]"), num2cell(segPoint));
    BaseICI = repmat(BaseICI(1), length(segPoint), 1);
    ICI2 = repmat(ICI2(1), length(segPoint), 1);
    CTLParams.stimStr = stimStr;
end
devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
[~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
S1Duration = repmat(S1Duration, length(segPoint), 1);
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");

%% split data
[trialsLFPRaw, ~, ~, ~, trialAll] = selectEcog(lfpDataset, trialAll, "dev onset", Window(1, :)); % "dev onset"; "trial onset"
trialsLFPFiltered = ECOGFilter(trialsLFPRaw, 0.1, 200, fd);
tIdx = excludeTrials(trialsLFPFiltered, 0.1);
trialsLFPFiltered(tIdx) = [];
trialsLFPRaw(tIdx) = [];
trialAllRaw = trialAll;
trialAll(tIdx) = [];

% spike
chSelect = [spikeDataset.realCh]';
trialsSpike = selectSpike(spikeDataset, trialAllRaw, CTLParams, "dev onset");

%% classify by devTypes

% initialize
t = linspace(Window(1), Window(2), size(trialsLFPFiltered{1}, 2))';
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
    trialsSPK = trialsSpike(tIndexRaw);
    LFP = [];
    for ch = 1 : size(trialsLFPFiltered{1}, 1)
        LFP(ch).info = strcat("CH", num2str(ch));
    end
    %% LFP
    
    % raw wave
    chMean{dIndex, 1} = cell2mat(cellfun(@mean , changeCellRowNum(trialsLFP), 'UniformOutput', false));
    rawLFP.t = t';
    rawLFP.rawWave = trialsToFFT;

    % lfp acg
    tLfpACG = (1:length(t)-1)*1000/lfpDataset.fs;
    normLfpACG = cellfun(@(y) mean(cell2mat(cellfun(@(x) mXcorr(x, "binSize", 1000/lfpDataset.fs, "maxLag", maxLag), num2cell(y, 2), "UniformOutput", false))), changeCellRowNum(trialsToFFT), "UniformOutput", false);
    %     normLfpACG = cellfun(@(y) mean(cell2mat(cellfun(@(x) mapminmax(xcorr(x, 'normalized'), 0, 1), num2cell(y, 2), "UniformOutput", false))), changeCellRowNum(trialsToFFT), "UniformOutput", false);
    acgIdx = cellfun(@(x) find(x<=1/exp(1), 1, "first"), normLfpACG);
    acgLfpTime = num2cell(tLfpACG(acgIdx));
    lfpACG = cellfun(@(x) [tLfpACG(1:length(x))', x'], normLfpACG, "UniformOutput", false);

    for ch = 1 : size(chMean{dIndex, 1}, 1)
        LFP(ch).Wave(:, 1) = t';
        LFP(ch).Wave(:, 2) = chMean{dIndex, 1}(ch, :)';
        LFP(ch).acgLfpTime = acgLfpTime{ch};
        LFP(ch).lfpACG = lfpACG{ch};
    end
    %% spike
    spikePlot = cellfun(@(x) cell2mat(x), num2cell(struct2cell(trialsSPK)', 1), "UniformOutput", false);
    chRS = cellfun(@(x) RayleighStatistic(x(:, 1), BaseICI(dIndex), sum(tIndexRaw)), spikePlot, "UniformOutput", false);


    % spike acg
    psthPara.binsize = 2; % ms
    psthPara.binstep = 2; % ms
    [~, chSpikeCount] = cellfun(@(x) calPsth(x, psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "uni", false);
    tSpkACG = (psthPara.binstep : psthPara.binstep : Window(2)-psthPara.binstep)';
    normSpkACG = cellfun(@(y) mean(cell2mat(cellfun(@(x) mXcorr(x, "binSize", psthPara.binsize, "maxLag", maxLag), num2cell(y, 2), "UniformOutput", false))), chSpikeCount', "UniformOutput", false);
    acgIdx = cellfun(@(x) find(x<=1/exp(1), 1, "first"), normSpkACG);
    acgSpkTime = num2cell(tSpkACG(acgIdx)');
    spkACG = cellfun(@(x) [tSpkACG(1:length(x)), x'], normSpkACG, "UniformOutput", false)';

%     % psth
%     psthPara.binsize = 30; % ms
%     psthPara.binstep = 1; % ms
%     chPSTH = cellfun(@(x) calPsth(x, psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "uni", false);
    chStr = fields(trialsSPK)';
    chSPK = cell2struct([chStr; spikePlot; chRS; spkACG; acgSpkTime], ["info", "spikePlot", "chRS", "spkACG", "acgSpkTime"]);


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
    chAll(dIndex).rawLFP = rawLFP;
    chAll(dIndex).acgLFP = cell2struct([acgLfpTime; lfpACG'], ["acgLfpTime", "lfpACG"]);
end

%% Plot Figure

% single unit
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
close all;
end


