ccc
% add the folder 'RatNeuroPixels' to the top of matlab path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO: configuration -- data select
ratName = "Rat3_ZYY"; % required
ROOTPATH = "I:\neuroPixels"; % required
project = "CTL_New"; % project, required
dateSel = ""; % blank for all
% protSel = ["RNP_ToneCF", "RNP_Noise", "RNP_Precise"]; % blank for all
protSel = ["RNP_Precise"]; % blank for all


%% TODO : configuration -- process parameters
windowParams.Window = [-1000 3000]; % ms
windowParams.accBinsize = 20;
windowParams.accWindow  = [200, 2000];

windowParams.psthPara.binsize = 50; % ms
windowParams.psthPara.binstep = 1; % ms

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