clc; close all
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: Set ratName and rootpath
ratName = "Rat2_SPR"; %% Custom
ROOTPATH = "I:\neuroPixels"; %% Custom

%% load protocols
temp = strsplit(ratName, "_");
humanName = temp(2);
rootPathMat = strcat(ROOTPATH, "\MAT Data\", ratName, "\CTL_New\");
rootPathFig = strcat(ROOTPATH, "\Figure\CTL_New\");
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", humanName, "_RNP_TBOffset_Recording.xlsx");
temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];
protocols = string({temp.name}');

%% TODO: select date and protocol (default: empty for all)
dateSel = "";
% protSel = "RNP_ToneCF";
% protSel = ["RNP_TB_Basic", "RNP_TB_BaseICI", "RNP_TB_Ratio", "RNP_TB_Jitter"];
protSel = "RNP_TB_Oscillation";
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
            if MLA_IsCTLProt(protocolStr)
                RNP_ClickTrainProcess(MATPATH{mIndex}, FIGPATH{mIndex});
            end
        end
    end
end