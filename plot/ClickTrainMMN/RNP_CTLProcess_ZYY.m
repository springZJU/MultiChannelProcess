ccc;
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration -- data select
ratName = "Rat3_SPR"; % required
ROOTPATH = "F:\MMN\neuroPixels"; % required
project = "CTL_New"; % project, required
dateSel = ""; % blank for all
% protSel = ["RNP_ToneCF", "RNP_Noise2", "RNP_CSD2", "RNP_MMN", "RNP_Click_Tuning"]; % blank for all
protSel = ["RNP_MMN"]; % blank for all

%% TODO : configuration -- process parameters

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

    MATPATH = cellfun(@(x) string([char(protPathMat), x, '\data.mat']), {temp.name}', "UniformOutput", false);
    MATPATH = MATPATH( contains(string(MATPATH), dateSel) & contains(string(MATPATH), protSel) );
    FIGPATH = cellfun(@(x) strcat(rootPathFig, string(x{end-1}), "\", protocolStr), cellfun(@(y) strsplit(y, "\"), MATPATH, "UniformOutput", false), "UniformOutput", false);
    for mIndex = 1 : length(MATPATH)
        try % the function name equals the protocol name
            mFcn = eval(['@', char(protSel(cellfun(@(x) contains(protocolStr, x), protSel))), ';']);
            mFcn(MATPATH{mIndex}, FIGPATH{mIndex});
        catch % temporal binding protocols
            if RNP_IsCTLProt(protocolStr)
                RNP_ClickTrainProcess(MATPATH{mIndex}, FIGPATH{mIndex});
            end
        end
    end
end