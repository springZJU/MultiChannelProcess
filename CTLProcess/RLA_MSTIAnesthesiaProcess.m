clear; clc; close all
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");
set(0, 'DefaultFigureWindowState', 'maximized');
%% TODO: configuration
recordPath = "I:\neuroPixels\MultiChannelProcess\utils\recordingExcel\KXK_RLA_Recording.xlsx";
protSel = ["MSTIWake-0.3s-BG-5ms-Si-4ms-Sii-6.3ms",...
           "MSTIAnesthesia20-0.3s-BG-5ms-Si-4ms-Sii-6.3ms",...
           "MSTIAnesthesia40-0.3s-BG-5ms-Si-4ms-Sii-6.3ms",...
           "MSTIAnesthesia80-0.3s-BG-5ms-Si-4ms-Sii-6.3ms",...
           "MSTIRecover-0.3s-BG-5ms-Si-4ms-Sii-6.3ms"]; % required
MATROOTPATH = "J:\RatLA\MAT DATA";
project = "MSTI_RAT"; % project, required

[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts, 'Sheet', 'Sheet1'));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

FigSaveROOTPATH = "J:\RatLA"; % required, for save figures

%% BATCH
FigRootPATH = strcat(FigSaveROOTPATH, "\Figure\", project, "\");
for pIndex = 1 : length(protSel)
    clear idx
    idx = find(cellfun(@(x) contains(x, protSel(pIndex)), {recordInfo.paradigm}'));
    for dataNum = 1 : numel(idx)
        BLOCKPATH = recordInfo(idx(dataNum)).BLOCKPATH;
        strtemp = strsplit(BLOCKPATH, "\");
        animalName = strtemp(3);
        AreaAndPosition = strsplit(recordInfo(idx(dataNum)).sitePos, "_");
        savedirname_Str = strcat(strtemp(4), "_", recordInfo(idx(dataNum)).sitePos);
        FIGPATH = strcat(FigRootPATH, protSel(pIndex), "\", savedirname_Str, "\");
        MATPATH = strcat(MATROOTPATH, "\", animalName, "\CTL_New\", protSel(pIndex), "\", savedirname_Str, "\");
        mkdir(FIGPATH);
        RLA_MSTIAnesthesia(MATPATH, FIGPATH);

    end
end

%% Plot Figure
clear;clc;
ProcessRootPath = "J:\RatLA\Figure\MSTI_RAT\";
Date = "RAT19_20240409_A30D42_LAC";
ProtocolStr = "MSTIAnesthesia-0.3s-BG-5ms-Si-4ms-Sii-6.3ms";
FIGPATH = strcat("J:\RatLA\Figure\MSTI_RAT\", ProtocolStr, "\", Date);
mkdir(FIGPATH);
[MSTIWake, PlotSettingRes] = RLA_MSTIAnesthesia_Analysis("MSTIWake-0.3s-BG-5ms-Si-4ms-Sii-6.3ms", ProcessRootPath, Date);
[MSTIAnesthesia20, ~] = RLA_MSTIAnesthesia_Analysis("MSTIAnesthesia20-0.3s-BG-5ms-Si-4ms-Sii-6.3ms", ProcessRootPath, Date);
[MSTIAnesthesia40, ~] = RLA_MSTIAnesthesia_Analysis("MSTIAnesthesia40-0.3s-BG-5ms-Si-4ms-Sii-6.3ms", ProcessRootPath, Date);
[MSTIAnesthesia80, ~] = RLA_MSTIAnesthesia_Analysis("MSTIAnesthesia80-0.3s-BG-5ms-Si-4ms-Sii-6.3ms", ProcessRootPath, Date);
[MSTIRecover, ~] = RLA_MSTIAnesthesia_Analysis("MSTIRecover-0.3s-BG-5ms-Si-4ms-Sii-6.3ms", ProcessRootPath, Date);
getAllCells = intersect(intersect(intersect(intersect(string({MSTIWake.CH}'), string({MSTIAnesthesia20.CH}')), string({MSTIAnesthesia40.CH}')),...
    string({MSTIAnesthesia80.CH}')), string({MSTIRecover.CH}'));

% plot settings
rowNum     = 5; % see below for details
colNum     = 10; % see below for details
stateNum   = 5; % wake--A20--A40--A80--Recover
devType    = length(MSTIWake(1).spkRes);
parseStruct(PlotSettingRes);
MSTIParams = RLA_ParseMSTIAnesthesiaParams("MSTIWake-0.3s-BG-5ms-Si-4ms-Sii-6.3ms");
parseStruct(MSTIParams);
cmpGroup   = {[1, 2]; [2, 1]}; % [dev std]
% Raster       wake--A20--A40--A80--Recover
% Psth         wake--A20--A40--A80--Recover
% PsthFFT(Lv1) wake--A20--A40--A80--Recover
% PsthFFT(Lv2) wake--A20--A40--A80--Recover
% PsthSSA(Lv3) compare
for cIndex = 1 : length(getAllCells)
    figure;
    for stateTypeIdx = 1 : stateNum
        switch stateTypeIdx
            case 1
                chSpkRes = MSTIWake;
            case 2
                chSpkRes = MSTIAnesthesia20;
            case 3
                chSpkRes = MSTIAnesthesia40;
            case 4
                chSpkRes = MSTIAnesthesia80;
            case 5
                chSpkRes = MSTIRecover;
        end
        cellIdx = strcmp(getAllCells(cIndex), string({chSpkRes.CH})');
        for dIndex = 1 : devType
            spkTemp = chSpkRes(cellIdx).spkRes(dIndex);
            FFTCursor  = 1000./double(strrep(regexpi(spkTemp.stimStr, "\d*o?\d", "match"), "o", "."));
            syncWin    = {[1, 6], [min(FFTCursor)-30, max(FFTCursor)+30]}; % {[freqBand for change rate], [freqBand for single click]}
            TrialChar   = char(erase(strrep(spkTemp.stimStr, "o", "."), "ms"));
            % column 1-2: raster plots
            rasterAxes(dIndex + (stateTypeIdx - 1) * devType) = mSubplot(rowNum, colNum, dIndex + (stateTypeIdx - 1) * 2, [1, 1], "alignment", "bottom-left");
            col1_2_X = spkTemp.raster(:, 1); col1_2_Y = spkTemp.raster(:, 2);
            scatter(col1_2_X, col1_2_Y, 5, "black", "filled"); hold on
            xlim(plotWin);xticklabels(""); title(TrialChar);
    
            % column 3-4: PSTH
            PSTHAxes(dIndex + (stateTypeIdx - 1) * devType) = mSubplot(rowNum, colNum, colNum + dIndex + (stateTypeIdx - 1) * 2, [1, 1], "alignment", "bottom-left");
            col3_4_X = tPSTH; col3_4_Y = spkTemp.PSTH;
            plot(col3_4_X, col3_4_Y, "k-"); hold on
            xlim(plotWin);title(TrialChar);
    
            % column 5: synchronization of single clicks (FFT, level 1)
            FFTSingleAxes(dIndex + (stateTypeIdx - 1) * devType) = mSubplot(rowNum, colNum, colNum * 2 + dIndex + (stateTypeIdx - 1) * 2, "margin_left", 0.1);
            col5_6_X = fFFT; col5_6_Y = spkTemp.trialsPsthFFT_Mean;        
            plot(col5_6_X, col5_6_Y, "k-"); hold on
            xlim(syncWin{2});xticklabels("");
            if stateTypeIdx == 1; title("FFT, level 1");end
    
            % column 6: syschronization of change responses (FFT, level 2)
            FFTChangeAxes(dIndex + (stateTypeIdx - 1) * devType) = mSubplot(rowNum, colNum, colNum * 3 + dIndex + (stateTypeIdx - 1) * 2, "margin_left", 0.1);
            plot(col5_6_X, col5_6_Y, "k-"); hold on
            xlim(syncWin{1});xticklabels("");
            if stateTypeIdx == 1; title("FFT, level 2");end
        end
        % text axes for CSI
        textAxes = mSubplot(1, stateNum, stateTypeIdx,  "padding_top", 0);
        set(textAxes, "Visible", "off");
        spkTemp = chSpkRes(cellIdx).spkRes;
        text(0.1, 1.03, ['CSI = ', num2str((sum([spkTemp.devFR]) - sum([spkTemp.stdFR])) / (sum([spkTemp.devFR]) + sum([spkTemp.stdFR])))], ...
                         "FontSize", 12);
        for gIndex = 1 : numel(cmpGroup)
            % Row 5: SSA compare(Lv3)        
            SSAAxes(gIndex + (stateTypeIdx - 1) * devType) = mSubplot(rowNum, colNum, colNum * 4 + gIndex + (stateTypeIdx - 1) * 2, "margin_left", 0.1);
            devRes = chSpkRes(cellIdx).spkRes(cmpGroup{gIndex}(1)); stdRes = chSpkRes(cellIdx).spkRes(cmpGroup{gIndex}(2));
            col7_devX = tPSTH; col7_devY = devRes.PSTH;
            col7_stdX = tPSTH + tStdToDev(cmpGroup{gIndex}(2)); col7_stdY = stdRes.PSTH;
            plot(col7_devX, col7_devY, "r-"); hold on % as dev
            plot(col7_stdX, col7_stdY, "k-"); hold on % as std
            xlim(compareWin);
            title(strcat("SSA:", regexpi(string(chSpkRes(cellIdx).spkRes(cmpGroup{gIndex}(1)).stimStr), 'Dev.*?ms', 'match'), ...
                ", SI:", num2str(roundn((devRes.devFR-stdRes.stdFR)/(devRes.devFR+stdRes.stdFR), -4))));
            [~, p_SSA] = ttest2(devRes.devTrialFR, stdRes.stdTrialFR, "Tail", "right");
            text("string", strcat("p=", string(roundn(p_SSA, -4))), 'Units', 'normalized', 'position', [0.45,0.85]);
            
        end
    end
    % scale axes
    scaleAxes(rasterAxes, "y");    scaleAxes(rasterAxes, "y"); 
    scaleAxes(PSTHAxes, "y");      scaleAxes(FFTSingleAxes, "y"); 
    scaleAxes(FFTChangeAxes, "y"); scaleAxes(SSAAxes, "y");

    % add vertical lines
    addLines2Axes(FFTSingleAxes, cell2struct(num2cell(FFTCursor)', "X", 2));
    addLines2Axes(FFTChangeAxes, cell2struct(num2cell(1000./300)', "X", 2));
    for dIndex = 1 : devType
        addLines2Axes([rasterAxes, PSTHAxes], cell2struct(num2cell((-StdNum:1:0)' * tStdToDev(dIndex)), "X", 2));
    end

    print(gcf, strcat(FIGPATH, strrep(string(chSpkRes(cellIdx).CH), "CH", "ID"), ".jpg"), "-djpeg", "-r200");
    close;
end
