clc; clear;close all
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration -- data select
ratName = "RatKC"; % required
ROOTPATH = "D:\Lab members\BXH\"; % required
project = "CTL_New"; % project, required
dateSel = ["251119","251120"]; % blank for all
% protSel = ["RNP_ToneCF", "RNP_Noise", "RNP_TB_Ratio", "RNP_TB_Basic_2_3"...
%     "RNP_TB_BaseICI_2_3", "RNP_Precise", "RNP_ToneCF_Late"]; % blank for all
% protSel = ["RNP_ToneCF", "RNP_Noise"]; % blank for all
% protSel = ["RNP_ToneCF"]; % blank for all
% protSel = [ "NewBaseICI","TrainDurTBChange S1","TrainDurTBChange S2",...
%     "LocalChangeReg2-3 N0-16","LocalChangeReg2-4 N0-16","TrainDurToneChange S1","TrainDurToneChange S2"]; % blank for all
% protSel = ["JCD"];
% protSel = ["RNP_ToneCF","RNP_Noise"];
protSel = ["SSA1"];

%% TODO : configuration -- process parameters
psthPara.binsize = 20; % ms
psthPara.binstep = 1; % ms

%% load protocols
temp = strsplit(ratName, "_");
% humanName = temp(2);
rootPathMat = strcat(ROOTPATH, "\MAT Data\", ratName, "\", project, "\");
rootPathFig = strcat(ROOTPATH, "\Figure\", project, "\");
temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];
protocols = string({temp.name}');

%% BATCH
% for rIndex = 5
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
            mFcn(MATPATH{mIndex}, FIGPATH{mIndex});ToneCF
        catch % temporal binding protocols
            if RNP_IsCTLProt(protocolStr)
                RNP_ClickTrainProcess(MATPATH{mIndex}, FIGPATH{mIndex});
            end
        end
    end
end
