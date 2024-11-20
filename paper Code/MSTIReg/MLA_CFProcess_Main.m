clear; clc; close all
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration
% recordPath = "J:\YHT\RecordingInfo202403.xlsx";
recordPath = strcat(getRootDirPath(mfilename("fullpath"), 3), "utils\recordingExcel\", "KXK_MLA_Recording.xlsx");
protSel = "Tone_CF"; % required
MATROOTPATH = "O:\MonkeyLA\MAT DATA\CM\CTL_New";
project = []; % project, required

[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts, 'Sheet', 'Sheet1'));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

FigSaveROOTPATH = "O:\Project\ANALYSIS_202312_MonkeyLA_MSTIReg"; % required, for save figures

%% BATCH
FigRootPATH = strcat(FigSaveROOTPATH, "\Figure\", project);
for pIndex = 1 : length(protSel)
    clear idx
    idx = find(cellfun(@(x) strcmp(x, protSel(pIndex)), {recordInfo.paradigm}'));
    for dataNum = 43 : numel(idx)
        BLOCKPATH = recordInfo(idx(dataNum)).BLOCKPATH;
        strtemp = strsplit(BLOCKPATH, "\");
        animalName = strtemp(3);
        AreaAndPosition = strsplit(recordInfo(idx(dataNum)).sitePos, "_");
        savedirname_Str = strcat(strtemp(4), "_", recordInfo(idx(dataNum)).sitePos);
        FIGPATH = fullfile(FigRootPATH, protSel(pIndex), savedirname_Str, "\");
%         MATPATH = strcat(MATROOTPATH, "\", AreaAndPosition{2}, "\", protSel(pIndex), "\", savedirname_Str, "\");
        MATPATH = fullfile(MATROOTPATH, protSel(pIndex), savedirname_Str, "data.mat");
        mkdir(FIGPATH);
        sFRA_RNP(MATPATH, FIGPATH);
        close all;
    end
end