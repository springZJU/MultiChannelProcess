clear; clc; close all
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "XHX_MLA_Recording.xlsx");
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);
protSel = ["f01000_SingleDur300_dev0.01_change30period_pos3-33-267ms",...
           "f06000_SingleDur300_dev0.0001_change4period_pos3-29.3-296ms"]; % required
FigSaveROOTPATH = "H:\MLA_A1补充"; % required, for save figures
MATROOTPATH = "H:\MLA_A1补充\MAT DATA";
project = "CTL_New"; % project, required

%% BATCH
FigRootPATH = strcat(FigSaveROOTPATH, "\Figure\", project, "\");
for pIndex = 2 : length(protSel)
    clear idx
    idx = find(cellfun(@(x) strcmp(x, protSel(pIndex)), {recordInfo.paradigm}'));
    for dataNum = 1 : numel(idx)
        BLOCKPATH = recordInfo(idx(dataNum)).BLOCKPATH;
        strtemp = strsplit(BLOCKPATH, "\");
        animalName = strtemp(3);
        savedirname_Str = strcat(strtemp(4), "_", recordInfo(idx(dataNum)).sitePos);
        FIGPATH = strcat(FigRootPATH, protSel(pIndex), "\", savedirname_Str, "\");
        MATPATH = strcat(MATROOTPATH, "\", animalName, "\", project, "\", protSel(pIndex), "\", savedirname_Str, "\");

        MLA_SEeffectKiloProcess(BLOCKPATH, MATPATH, FIGPATH);

    end
end