clc; close all
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration
ratName = "Rat2_SPR"; % required
ROOTPATH = "I:\neuroPixels"; % required
project = "CTL_New"; % project, required
dateSel = ""; % blank for all
protSel = ["RNP_ToneCF", "RNP_Noise", "RNP_TB_Ratio", "RNP_TB_Basic_2_3"...
    "RNP_TB_BaseICI_2_3", "RNP_TB_Ratio_4", "RNP_Precise"]; % blank for all

%% load protocols
temp = strsplit(ratName, "_");
humanName = temp(2);
rootPathMat = strcat(ROOTPATH, "\MAT Data\", ratName, "\", project, "\");
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
    FIGPATH = cellfun(@(x) strcat(rootPathFig, string(x{end-1}), "\", protocolStr), cellfun(@(y) strsplit(y, "\"), MATPATH, "UniformOutput", false), "UniformOutput", false);
    for mIndex = 1 : length(MATPATH)
        try % the function name equals the protocol name
            mFcn = eval(['@', char(protocolStr), ';']);
            mFcn(MATPATH{mIndex}, FIGPATH{mIndex});
        catch % temporal binding protocols
            if RNP_IsCTLProt(protocolStr)
                RNP_ClickTrainProcess(MATPATH{mIndex}, FIGPATH{mIndex});
            end
        end
    end
end