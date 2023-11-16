function trialsLfp = lfpProcessMMN(trialAll, lfpDataset, windowParams)  % mei xie wan =.=
parseStruct(windowParams);



lfpDatasetCopy = lfpDataset;
if ~isempty(lfpDataset)
    fs0 = lfpDataset.fs;
end

%% exclude trials
%  [trialslfpRaw, ~, ~] = selectEcog(lfpDatasetCopy, trialAll, "trial onset", lfpWindow);  % dev as standard
%    
% %     trialslfpFiltered = ECOGFilter(trialslfpRaw, 0.1, 200, fs);  
% % tIdx = excludeTrials(trialslfpFiltered, 0.03);
% trialslfpFiltered(tIdx) = [];
% trialslfpRaw(tIdx) = [];
% trialAll = trialAll(idx);

%% get lfp
mkdir(SAVEPATH);
stitype = unique([trialAll.TypeOrd]);
stitype(end) = [];
temp = cell(length(stitype), 1);
trialsLfp = struct("stimStr", temp);
for iIndex = 1:length(stitype)
    trials = trialAll([trialAll.TypeOrd] ==  stitype(iIndex));  
    trialspair = trialAll([trialAll.stdOrdr] == unique([trials.devOrdr])&[trialAll.devOrdr] == unique([trials.stdOrdr]));
    [lfp, ~, ~] = selectEcog(lfpDatasetCopy, [trials; trialspair], unique([trials.devOrdr]), "trial onset", [-100 2500]);  % dev as standard
    lfpdata = changeCellRowNum(lfp);
    t = linspace(-100, 2500, size(lfpdata{1}, 2));
    tIdx = find(t > -100 & t < 2500);
    fftdata = cellfun(@(x) cell2mat(cellfun(@(y) mfft(y(tIdx), fs0), mat2cell(x, ones(size(x, 1), 1)), "UniformOutput", false)), lfpdata, "UniformOutput", false);
    Meanfft = cellfun(@(x) mean(x, 1), fftdata, "UniformOutput", false);
    [~, fftfreq0, ~] = mfft(lfpdata{1}, fs0);
    fftfreq = num2cell(repmat(fftfreq0, size(Meanfft, 1), 1), 2);
    [devlfp, ~, ~] = selectEcog(lfpDatasetCopy, [trials; trialspair], unique([trials.devOrdr]), "dev onset", selWin);
    devlfpdata = changeCellRowNum(devlfp);
    devMeanlfp = cellfun(@mean , devlfpdata, 'UniformOutput', false);
    devStdlfp = cellfun(@(x) std(x)/sqrt(size(x, 1)), devlfpdata, 'UniformOutput', false);
    [stdlfp, ~, ~] = selectEcog(lfpDatasetCopy, [trials; trialspair], unique([trials.devOrdr]),  "last std", selWin);
    stdlfpdata = changeCellRowNum(stdlfp);
    stdMeanlfp = cellfun(@mean , stdlfpdata, 'UniformOutput', false);
    stdStdlfp = cellfun(@(x) std(x)/sqrt(size(x, 1)), stdlfpdata, 'UniformOutput', false);
    [strlfp, ~, ~] = selectEcog(lfpDatasetCopy, trialAll, unique([trials.devOrdr]), "control", selWin);
    ctrlfpdata = changeCellRowNum(strlfp);
    ctrMeanlfp = cellfun(@mean , ctrlfpdata, 'UniformOutput', false);
    ctrStdlfp = cellfun(@(x) std(x)/sqrt(size(x, 1)), ctrlfpdata, 'UniformOutput', false);
    %%
    devBRI = cellfun(@(x) mean(x(:, tIdxBRI), 2)./mean(x(:, tIdxBase), 'all'), devlfpdata, 'UniformOutput', false);
    stdBRI = cellfun(@(x) mean(x(:, tIdxBRI), 2)./mean(x(:, tIdxBase), 'all'), stdlfpdata, 'UniformOutput', false);
    %     devBRIbase = cellfun(@(x) mean(x(:, tIdxBase), 2), devlfpdata, 'UniformOutput', false);
    %     stdBRIbase = cellfun(@(x) mean(x(:, tIdxBase), 2), stdlfpdata, 'UniformOutput', false);
    %     devBRI = cellfun(@(x) mean(x(:, tIdxBRI), 2), devlfpdata, 'UniformOutput', false);
    %     stdBRI = cellfun(@(x) mean(x(:, tIdxBRI), 2), stdlfpdata, 'UniformOutput', false);
    [~, pvalue] = cellfun(@(x, y) ttest2(x, y), devBRI, stdBRI, 'UniformOutput', false);
    chLFP = cell2struct([fftdata, Meanfft, fftfreq, devlfpdata, devMeanlfp, devStdlfp, stdlfpdata, stdMeanlfp, stdStdlfp, ctrlfpdata, ctrMeanlfp, ctrStdlfp, pvalue], ...
        ["fftdata", "Meanfft", "fftfreq", "devlfpdata", "devMeanlfp", "devStdlfp", "stdlfpdata", "stdMeanlfp", "stdStdlfp", "ctrlfpdata", "ctrMeanlfp", "ctrStdlfp", "pvalue"], 2);
    
    devchMeanAvg = mean(cell2mat(devMeanlfp(schs, :)), 1);
    stdchMeanAvg = mean(cell2mat(stdMeanlfp(schs, :)), 1);
    ctrchMeanAvg = mean(cell2mat(ctrMeanlfp(schs, :)), 1);
    trialsLfp(iIndex).chLFP = chLFP;
    trialsLfp(iIndex).devchMeanAvg = devchMeanAvg;
    trialsLfp(iIndex).stdchMeanAvg = stdchMeanAvg;
    trialsLfp(iIndex).ctrchMeanAvg = ctrchMeanAvg;
    trialsLfp(iIndex).stimStr = strcat(stimStr{unique([trials.devOrdr])}, ' | ',  stimStr{unique([trials.stdOrdr])}, '-', stimStr{unique([trials.devOrdr])});
    trialsLfp(iIndex).color = colors{1};
end
%% plot
if ~dataOnlyOpt
    for iIndex = 1:length(stitype)
        Fig = plotRawWaveMulti_RatECOG4(trialsLfp(iIndex), Window);
        scaleAxes(Fig,"y",[-150 150]);
        scaleAxes(Fig, "x", [-100 400]);
        lines2(1).X = S1Duration(1); lines2(2).X = 0;
        addLines2Axes(Fig, lines2);
        legend;
        %     scaleAxes(Fig, "uiOpt", "show");
%         setAxes(Fig, "Visible", "off");
        % plotLayoutEEG(Fig, 0.3);
            print(Fig, strcat(SAVEPATH, strrep(trialsLfp(iIndex).stimStr, '|', '_'), '_200ms_7_250' ), "-djpeg", "-r300");
    end
end
close all

%% average chs
if dataOnlyOpt
    Fig1 = figure;
    maximizeFig;
    t = linspace(Window(1), Window(2), size(trialsLfp(1).chLFP(1).devMeanlfp, 2));
    for ic = 1:size(trialsLfp, 1)
        subplot(size(trialsLfp, 1), 1, ic)
        plot(t, trialsLfp(ic).devchMeanAvg, "Color", 'r', "LineWidth", 2, "DisplayName", 'deviant' ); hold on;
        plot(t, trialsLfp(ic).stdchMeanAvg, "Color", 'b', "LineWidth", 2, "DisplayName", 'standard' ); hold on;
        plot(t, trialsLfp(ic).ctrchMeanAvg, "Color", 'k', "LineWidth", 2, "DisplayName", 'control' ); hold on;
        set(gca, "FontSize", 15);
        title(trialsLfp(ic).stimStr);
        xlabel("Time from onset point (ms)");
        ylabel("ERP (\muV)");
    end
    legend;
    lines3(1).X = S1Duration(1); lines3(2).X = Offset(1);lines3(3).X = 0;
    addLines2Axes(Fig1, lines3);
    %     scaleAxes("y",  [-100, 80] );
    scaleAxes("x",  plotWin);
    mPrint(Fig1, fullfile(SAVEPATH, strcat('Mean_MMN', ".jpg")));
end
