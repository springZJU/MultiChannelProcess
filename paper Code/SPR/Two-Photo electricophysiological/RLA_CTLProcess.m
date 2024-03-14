clc; clear;close all
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration -- data select
ratName = "Mouse_SPR"; % required
ROOTPATH = "H:\SPR Paper\Two-Photo Imaging\electrophysiological\"; % required
project = "CTL_New"; % project, required
dateSel = "0131"; % blank for all
protSel = ["Noise", "ToneCF" ,"TB_JingChangDu", "Offset_ICI_1_64"]; % blank for all   "Anesthesia_Ratio_4_01234""MMN" 
% protSel = ["Noise"];

%% TODO : configuration -- process parameters
psthPara.binsize = 20; % ms
psthPara.binstep = 1; % ms

%% load protocols
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

    MATPATH = cellfun(@(x) string([char(protPathMat), x, '\spkData.mat']), {temp.name}', "UniformOutput", false);
    MATPATH = MATPATH( contains(string(MATPATH), dateSel) & contains(string(MATPATH), protSel) );
    FIGPATH = cellfun(@(x) strcat(rootPathFig, protocolStr, "\", string(x{end-1})), cellfun(@(y) strsplit(y, "\"), MATPATH, "UniformOutput", false), "UniformOutput", false);
    for mIndex = 1 : length(MATPATH)
        if exist(protocolStr, "file") % the function name equals the protocol name
            mFcn = eval(['@', char(protocolStr), ';']);
            mFcn(MATPATH{mIndex}, FIGPATH{mIndex});
        else % temporal binding protocols
            if RNP_IsCTLProt(protocolStr)
                RNP_ClickTrainProcess(MATPATH{mIndex}, FIGPATH{mIndex});
            end
        end
    end
end