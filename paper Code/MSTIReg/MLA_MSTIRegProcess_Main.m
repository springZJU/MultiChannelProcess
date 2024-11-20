clear; clc; close all
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration
% recordPath = "J:\YHT\RecordingInfo202403.xlsx";
recordPath = strcat(getRootDirPath(mfilename("fullpath"), 3), "utils\recordingExcel\", "KXK_MLA_Recording.xlsx");
protSel = "MSTIRegularity-0.3s-BG-10.8ms-Si-9ms-Sii-13.0ms"; % required
MATROOTPATH = "O:\MonkeyLA\MAT DATA\CM\CTL_New";
project = "MSTI_Reg"; % project, required
protStr = "MSTIRegularity-0.3s-BG-10.8ms-Si-9ms-Sii-13.0ms-StdNum-6"; % for params

[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts, 'Sheet', 'Sheet1'));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

FigSaveROOTPATH = "O:\Project\ANALYSIS_202312_MonkeyLA_MSTIReg"; % required, for save figures

%% BATCH
FigRootPATH = strcat(FigSaveROOTPATH, "\Figure\", project, "\");
for pIndex = 1 : length(protSel)
    clear idx
    idx = find(cellfun(@(x) strcmp(x, protSel(pIndex)), {recordInfo.paradigm}'));
    for dataNum = 29 : numel(idx)
        BLOCKPATH = recordInfo(idx(dataNum)).BLOCKPATH;
        strtemp = strsplit(BLOCKPATH, "\");
        animalName = strtemp(3);
        AreaAndPosition = strsplit(recordInfo(idx(dataNum)).sitePos, "_");
        savedirname_Str = strcat(strtemp(4), "_", recordInfo(idx(dataNum)).sitePos);
        FIGPATH = strcat(FigRootPATH, protSel(pIndex), "\", savedirname_Str, "\");
%         MATPATH = strcat(MATROOTPATH, "\", AreaAndPosition{2}, "\", protSel(pIndex), "\", savedirname_Str, "\");
        MATPATH = strcat(MATROOTPATH, "\", protSel(pIndex), "\", savedirname_Str, "\");
        mkdir(FIGPATH);
        MLA_MSTIRegProcess(MATPATH, FIGPATH);

    end
end