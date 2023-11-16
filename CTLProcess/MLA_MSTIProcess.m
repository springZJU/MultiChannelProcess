clear; clc; close all
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
        "SPR_MLA_Recording.xlsx");
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);
protSel = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
           "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s",...
           "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"]; % required
FigSaveROOTPATH = "H:\MLA_A1补充"; % required, for save figures
MATROOTPATH = "H:\MLA_A1补充\MAT DATA";
project = "CTL_New"; % project, required

%% BATCH
FigRootPATH = strcat(FigSaveROOTPATH, "\Figure\", project, "\");
for pIndex = [3]%1 : length(protSel)
    clear idx
    idx = find(cellfun(@(x) strcmp(x, protSel(pIndex)), {recordInfo.paradigm}'));
    for dataNum = 1 : numel(idx)
        BLOCKPATH = recordInfo(idx(dataNum)).BLOCKPATH;
        strtemp = strsplit(BLOCKPATH, "\");
        animalName = strtemp(3);
        savedirname_Str = strcat(strtemp(4), "_", recordInfo(idx(dataNum)).sitePos);
        FIGPATH = strcat(FigRootPATH, protSel(pIndex), "\", savedirname_Str, "\");
        MATPATH = strcat(MATROOTPATH, "\", animalName, "\", project, "\", protSel(pIndex), "\", savedirname_Str, "\");

        MLA_MSTIKiloProcess(MATPATH, FIGPATH);

    end
end