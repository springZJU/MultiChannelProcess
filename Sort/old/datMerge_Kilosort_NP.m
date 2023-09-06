clc; clear
% add path to the top
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");
%% TODO:
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "ZYY_RNP_TBOffset_Recording.xlsx");
dateSel = "";
run("process_LoadExcel.m");

%%%%%%%%%%%%%%%%%%%%%%%% datMerge_NP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for rIndex = 1 : length(recSite)
    run("process_Merge.m");
    if isempty(selIdx)
        continue
    end

    % merge
    if ~exist(MERGEFILE,'file')
        NP_TDT_Merge(BLOCKPATH, DATAPATH, MERGEFILE, fs)
    end
end

%%%%%%%%%%%%%%%%%%%%%% kilosortToProcess_NeuroPixels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clc;
clearvars -except selInfo recordInfo recordPath
for rIndex = 1 : length(selInfo)
    run("process_Kilosort.m");
end
