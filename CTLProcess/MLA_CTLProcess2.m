clc; close all
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration
monkeyName = "DDZ"; % required
ROOTPATH = "E:\MonkeyLinearArray"; % required
project = "CTL_New"; % project, required
dateSel = ["20231108", "20231109"]; % blank for all
% protSel = ["TB_BaseICI_4_8_16", "TB_Ratio_4_4o04", "Offset_Duration_Effect_4ms_Reg_New", "Offset_Variance_Last_N4_8_16_32"]; % blank for all
% protSel = ["TB_BaseICI_4_8_16"]; % blank for all

protSel = ["Tone_CF"]; % blank for all

%% load protocols
rootPathMat = strcat(ROOTPATH, "\MAT Data\", monkeyName, "\", project, "\");
rootPathFig = strcat(ROOTPATH, "\Figure\", project, "\");
temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];
protocols = string({temp.name}');

%% BATCH
for rIndex = 1 : length(protocols)
    protPathMat = strcat(rootPathMat, protocols(rIndex), "\");
    protocolStr = protocols(rIndex);
    temp = dir(protPathMat);
    temp(ismember(string({temp.name}'), [".", ".."])) = [];

    MATPATH = cellfun(@(x) string([char(protPathMat), x, '\data.mat']), {temp.name}', "UniformOutput", false);
    MATPATH = MATPATH( contains(string(MATPATH), dateSel) & contains(string(MATPATH), protSel) );
    FIGPATH = cellfun(@(x) strcat(rootPathFig, protocolStr, "\", string(x{end-1})), cellfun(@(y) strsplit(y, "\"), MATPATH, "UniformOutput", false), "UniformOutput", false);
    for mIndex = 1 : length(MATPATH)
        try % the function name equals the protocol name
            mFcn = eval(['@', char(protocolStr), ';']);
            mFcn(MATPATH{mIndex}, FIGPATH{mIndex});
        catch % temporal binding protocols
            if MLA_IsCTLProt(protocolStr)
                MLA_ClickTrainProcess(MATPATH{mIndex}, FIGPATH{mIndex});
            end
        end
    end
end