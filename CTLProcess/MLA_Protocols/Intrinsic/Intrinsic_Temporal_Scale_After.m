function Intrinsic_Temporal_Scale_After(MATPATH, FIGPATH)
%% Parameter setting
params.processFcn = @PassiveProcess_clickTrainIntrinsic;
temp = string(strsplit(MATPATH, "\"));
% dateStr = temp(end - 1);
protStr = temp(end - 2);
DATAPATH = MATPATH;
FIGPATH = strcat(FIGPATH, "\");
try
    shankNum = evalin("caller", "shankNum");
catch
    shankNum = 1;
end
temp = dir(FIGPATH);
Exist_LFP_By_Ch = any(contains(string({temp.name}), "LFP_ch"));
% Exist_LFP_By_Ch = 1;
% Exist_LFP_Acorss_Ch = any(contains(string({temp.name}), "LFP_Compare_Chs"));
Exist_LFP_Acorss_Ch = 1;
if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch])
    return
end


%% load data and click train params
[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(DATAPATH, params);

try  protStr = evalin("base", "protStr"); end
CTLParams = MLA_ParseCTLParams(protStr);
parseStruct(CTLParams);

% cut null trials
dataLength = size(lfpDataset.data, 2) / lfpDataset.fs;
trialAll([trialAll.soundOnsetSeq]' > dataLength * 1000) = [];
%% set trialAll
devType  = unique([trialAll.devOrdr]');
%% split data
trialsLFP = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
tIdx = excludeTrials(trialsLFP, 0.1);
trialsLFP(tIdx) = [];
trialAll(tIdx) = [];

% spike
trialsSpike = selectSpike(spikeDataset, trialAll, CTLParams, "dev onset");

%% classify by devTypes

% initialize
t = linspace(Window(1), Window(2), size(trialsLFP{1}, 2))';
chMean = cell(length(devType), 1);
temp = cell(length(devType), 1);
trialInfo = struct("stimStr", temp);
lfpRes = struct("stimStr", temp);
spkRes = struct("stimStr", temp);
% diff stims
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    trialsToFFT = trialsLFP(tIndex);
    trialsLFP = trialsLFP(tIndex);
    trialsSPK = trialsSpike(tIndex);
    LFP = [];
    for ch = 1 : size(trialsLFP{1}, 1)
        LFP(ch).info = strcat("CH", num2str(ch));
    end
    %% LFP

    % raw wave
    chMean{dIndex, 1} = cell2mat(cellfun(@mean , changeCellRowNum(trialsLFP), 'UniformOutput', false));
    rawLFP.t = t';
    rawLFP.rawWave = trialsToFFT;

    % lfp acg
    tLfpACG = (1:length(t)-1)*1000/lfpDataset.fs;
    normLfpACG = cellfun(@(y) mean(cell2mat(cellfun(@(x) mXcorr(x, "binSize", 1, "maxLag", maxLag), num2cell(y, 2), "UniformOutput", false))), changeCellRowNum(trialsToFFT), "UniformOutput", false);

    %     normLfpACG = cellfun(@(y) mean(cell2mat(cellfun(@(x) mapminmax(xcorr(x, 'normalized'), 0, 1), num2cell(y, 2), "UniformOutput", false))), changeCellRowNum(trialsToFFT), "UniformOutput", false);
    acgIdx = cellfun(@(x) rowFcn(@(y) find(y<=1/exp(1), 1, "first"), x), normLfpACG, "UniformOutput", false);
    acgLfpTime = cellfun(@(x) mean(tLfpACG(x)), acgIdx, "UniformOutput", false);
    lfpACG = cellfun(@(x) [tLfpACG(1:length(x))', x'], normLfpACG, "UniformOutput", false);

    for ch = 1 : size(chMean{dIndex, 1}, 1)
        LFP(ch).Wave(:, 1) = t';
        LFP(ch).Wave(:, 2) = chMean{dIndex, 1}(ch, :)';
        LFP(ch).acgLfpTime = acgLfpTime{ch};
        LFP(ch).lfpACG = lfpACG{ch};
    end
    %% spike
    % get channels with significant auditory responses
    load(fullfile(strrep(FIGPATH, regexp(FIGPATH, "\\Intrinsic_Temporal_Scale_After\\", "match"), "\Noise-ITI-2s\"), "sigRes.mat"));

    spikeCell =  num2cell(struct2cell(trialsSPK)', 1)';
    spikePlot = cellfun(@(x) cell2mat(x), num2cell(struct2cell(trialsSPK)', 1), "UniformOutput", false);

    trialsSpk = num2cell(struct2cell(trialsSPK)', 1)';
    pooledSpk = cellfun(@(x) cell2mat(x), changeCellRowNum(trialsSpk), "UniformOutput", false);
    spikeCell = [spikeCell; {pooledSpk}];
    % spike count
    binsize = 2; binstep = 2; % ms
    psth = cellfun(@(x) calPSTH(x, [0, segLength * 1000], binsize, binstep), spikeCell, "UniformOutput", false);
    % spike acg
    tSpkACG = (binstep : binstep : Window(2)-binstep)';
    normSpkACG = cellfun(@(x) mXcorr(x, "binSize", binstep, "maxLag", maxLag), psth, "UniformOutput", false);
    
    acgIdx = cellfun(@(x) find(x<=1/exp(1), 1, "first"), normSpkACG);
    acgSpkTime = tSpkACG(acgIdx)';
    spkACG = cellfun(@(x) [tSpkACG(1:length(x)), x'], normSpkACG, "UniformOutput", false)';
    spkACGMean = [tSpkACG(1:length(normSpkACG{1})), mean(cell2mat(normSpkACG), 1)'];

%     % psth
%     binsize = 30; % ms
%     binstep = 1; % ms
%     chPSTH = cellfun(@(x) calPsth(x, psthPara, 1e3, 'EDGE', Window, 'NTRIAL', sum(tIndex)), spikePlot, "uni", false);
    chStr  = fields(trialsSPK)';
    chSPK  = cell2struct([chStr; spikePlot], ["info", "spikePlot"]);
    ACGRes.acgSpkTime = acgSpkTime;
    ACGRes.spkACG     = spkACG;
    ACGRes.spkACGMean = spkACGMean;

    %% integration
    trialInfo(dIndex).trials = trialAll(tIndex)';
    trialInfo(dIndex).trialNum = sum(tIndex);
    trialInfo(dIndex).stimStr = stimStr(dIndex);

    spkRes(dIndex).info   = stimStr(dIndex);
    spkRes(dIndex).chSPK  = chSPK;
    spkRes(dIndex).ACGRes = ACGRes;
    spkRes(dIndex).trialsSpk = trialsSpk;
    spkRes(dIndex).sigRes = sigRes;
    
    lfpRes(dIndex).info = stimStr(dIndex);
    lfpRes(dIndex).chLFP = LFP;
    lfpRes(dIndex).rawLFP = rawLFP;
    lfpRes(dIndex).acgLFP = cell2struct([acgLfpTime'; lfpACG'], ["acgLfpTime", "lfpACG"]);

end

%% Plot Figure
mkdir(FIGPATH);

% lfp of whole period
if ~Exist_LFP_By_Ch
    if shankNum == 2
        FigLFP = MLA_PlotLfpByCh_Intrinsic_2Shanks(lfpRes, spkRes, CTLParams);
    elseif shankNum == 4
        FigLFP = MLA_PlotLfpByCh_Intrinsic_4Shanks(lfpRes, spkRes, CTLParams);
    else
        FigLFP = MLA_PlotLfpByCh_Intrinsic(lfpRes, spkRes, CTLParams);
    end
    print(FigLFP, strcat(FIGPATH, "LFP_ch"), "-djpeg", "-r300");
end
% lfp comparison acorss channels
if ~Exist_LFP_Acorss_Ch
    FigLFPCompare = MLA_PlotLfpAcrossCh(lfpRes, CTLParams);
    scaleAxes(FigLFPCompare, "x", [-50, 500]);
    scaleAxes(FigLFPCompare, "y", "on");
    print(FigLFPCompare, strcat(FIGPATH, "LFP_Compare_Chs"), "-djpeg", "-r300");
end

% spikeRes
SAVENAME = strcat(FIGPATH, "spkRes.mat");
save(SAVENAME, "trialInfo", "trialAll", "spkRes", "-mat");

% lfpRes
SAVENAME = strcat(FIGPATH, "lfpRes.mat");
save(SAVENAME, "trialInfo", "trialAll", "lfpRes", "-mat");

close all;
end


