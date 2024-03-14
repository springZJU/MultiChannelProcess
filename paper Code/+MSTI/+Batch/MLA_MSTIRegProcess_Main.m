clear; clc; close all
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration
recordPath = "J:\YHT\DATA_202312_MonkeyLA_MSTIReg\RecordingInfo.xlsx";
animal = "ddz"; % ddz, cm
protSel = "MSTIRegularity-0.3s-BG-8.4ms-Si-7ms-Sii-10.1ms"; % required
MATROOTPATH = "J:\YHT\DATA_202312_MonkeyLA_MSTIReg\DATA\MAT DATA";
project = "MSTI_Reg"; % project, required

[~, opts] = getTableValType(recordPath, "0");
if strcmp(animal, "ddz")
    recordInfo = table2cell(readtable(recordPath, opts, 'Sheet', 'Sheet1'));
elseif strcmp(animal, "cm")
    recordInfo = table2cell(readtable(recordPath, opts, 'Sheet', 'Sheet2'));
end
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

FigSaveROOTPATH = "J:\YHT\ANALYSIS_202312_MonkeyLA_MSTIReg"; % required, for save figures

%% BATCH
FigRootPATH = strcat(FigSaveROOTPATH, "\Figure\", project, "\");
for pIndex = 1 : length(protSel)
    clear idx
    idx = find(cellfun(@(x) strcmp(x, protSel(pIndex)), {recordInfo.paradigm}'));
    for dataNum = 1 : numel(idx)
        BLOCKPATH = recordInfo(idx(dataNum)).BLOCKPATH;
        strtemp = strsplit(BLOCKPATH, "\");
        animalName = strtemp(3);
        AreaAndPosition = strsplit(recordInfo(idx(dataNum)).sitePos, "_");
        savedirname_Str = strcat(strtemp(4), "_", recordInfo(idx(dataNum)).sitePos);
        FIGPATH = strcat(FigRootPATH, protSel(pIndex), "\", savedirname_Str, "\");
        MATPATH = strcat(MATROOTPATH, "\", AreaAndPosition{2}, "\", protSel(pIndex), "\", savedirname_Str, "\");
        mkdir(FIGPATH);
        MLA_MSTIRegProcess(MATPATH, FIGPATH);

    end
end