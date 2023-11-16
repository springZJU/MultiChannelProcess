function chSpikeLfp = spkProcessMMN(trialAll, spikeDataset, windowParams, ProcessFlag)

if ~ProcessFlag    
    return
end
parseStruct(windowParams);
stitype = unique([trialAll.TypeOrd]);
stitype(end) = []; % end: many std
temp = cell(length(stitype), 1);
chSpikeLfp = struct("stimStr", temp, ...
    'chSPK', temp);

for dIndex = 1:length(stitype)
    clear trials
    chStr = cellfun(@(x) char(strcat("CH", string(num2str(x)))), {spikeDataset.ch}', "uni", false);
    %  std dev ctr
    trials = trialAll([trialAll.TypeOrd] == stitype(dIndex));
    trialspair = trialAll([trialAll.stdOrdr] == unique([trials.devOrdr])&[trialAll.devOrdr] == unique([trials.stdOrdr]));

    [Devspike, DevtrialNum] = selectSpikeMMN(spikeDataset, [trials; trialspair], windowParams, 'dev onset', unique([trials.devOrdr]));
    [Stdspike, StdtrialNum] = selectSpikeMMN(spikeDataset, [trials; trialspair], windowParams, 'last std', unique([trials.devOrdr]) );
    DevspikePlot = cellfun(@(x) cell2mat(x), num2cell(Devspike', 1), "UniformOutput", false);
    StdspikePlot = cellfun(@(x) cell2mat(x), num2cell(Stdspike', 1), "UniformOutput", false);
    DevspkPSTH = cellfun(@(x) calOriPsth(x, spkPsthBin, 1e3, 'EDGE', spkWindow, 'NTRIAL', length(DevtrialNum)), DevspikePlot, "uni", false);
    StdspkPSTH = cellfun(@(x) calOriPsth(x, spkPsthBin, 1e3, 'EDGE', spkWindow, 'NTRIAL', length(StdtrialNum)), StdspikePlot, "uni", false);
    [Ctrspike, CtrtrialNum] = selectSpikeMMN(spikeDataset, trialAll, windowParams, 'control', unique([trials.devOrdr]));
    CtrspikePlot = cellfun(@(x) cell2mat(x), num2cell(Ctrspike', 1), "UniformOutput", false);
    CtrspkPSTH = cellfun(@(x) calOriPsth(x, spkPsthBin, 1e3, 'EDGE', spkWindow, 'NTRIAL', length(CtrtrialNum)), CtrspikePlot, "uni", false);
    if length(Ctrspike) == 1 % ...for pure tone
        Ctrspike = cell(1, numel(chStr)); Ctrspike(:) = {[]};
        CtrspikePlot = cell(1, numel(chStr)); CtrspikePlot(:) = {[]};
        CtrspkPSTH = cell(1, numel(chStr)); CtrspkPSTH(:) = {[]};
    end
    chSPK = cell2struct([chStr, DevspikePlot', DevspkPSTH', num2cell(ones(length(chStr), 1).* length(DevtrialNum)), ...
        StdspikePlot', StdspkPSTH', num2cell(ones(length(chStr), 1).* length(StdtrialNum)), ...
        CtrspikePlot', CtrspkPSTH', num2cell(ones(length(chStr), 1).* length(CtrtrialNum))], ...
        ["info", "DevSpikePlot", "DevSpkPSTH", "DevTrialNum", "StdSpikePlot", "StdSpkPSTH", ...
        "StdTrialNum", "CtrSpikePlot", "CtrSpkPSTH", "CtrTrialNum"], 2);

    % sti order for dev in this stitype
    [ordtrials, ~] = cellfun(@(x) selectSpikeMMN(spikeDataset, trialAll, windowParams, 'all trial', 'segIndex', x), changeCellRowNum({trialspair.soundOnsetSeq}'), "UniformOutput", false);
    for i = 1:length(ordtrials)
        chSPK = addFieldToStruct(chSPK, [num2cell(ordtrials{i}', 1)]', ['Sti' num2str(i)]);
    end
    %% calculate Firingrate and CSI -- temp here
    for wIndex = 1 : length(winStr)
        FrTemp = cellfun(@(y) cell2mat(cellfun(@(x) calOriFirate(x, spkFrWin{wIndex}, 0), y, "UniformOutput", false )), num2cell(Devspike', 1), "UniformOutput", false);
        chSPK = addFieldToStruct(chSPK, FrTemp', strcat("Dev", winStr(wIndex), labelStr(wIndex)));
        FrTemp = cellfun(@(y) cell2mat(cellfun(@(x) calOriFirate(x, spkFrWin{wIndex}, 0), y, "UniformOutput", false )), num2cell(Stdspike', 1), "UniformOutput", false);
        chSPK = addFieldToStruct(chSPK, FrTemp', strcat("Std", winStr(wIndex), labelStr(wIndex)));
        FrTemp = cellfun(@(y) cell2mat(cellfun(@(x) calOriFirate(x, spkFrWin{wIndex}, 0), y, "UniformOutput", false )), num2cell(Ctrspike', 1), "UniformOutput", false);
        if length(FrTemp) == 1   % ... for pure tone, bacause no control 
            FrTemp = num2cell([cell2mat(FrTemp)]');
        end
        chSPK = addFieldToStruct(chSPK, FrTemp', strcat("Ctr", winStr(wIndex), labelStr(wIndex)));
    end
    CSI = cellfun(@(x, y) (x-y)/(x+y), cellfun(@mean,{chSPK.DevfrWin0_250}, "uni", false), cellfun(@mean,{chSPK.StdfrWin0_250}, "uni", false), "uni", false);
    chSPK = addFieldToStruct(chSPK, CSI', "CSI");

    %%
    chSpikeLfp(dIndex).stimStr = strcat(stimStr(unique([trials.devOrdr])), ' [', unique({trials.oddballType}), ']');
    chSpikeLfp(dIndex).chSPK = chSPK;

end
disp('classify data from MAT sucess.');