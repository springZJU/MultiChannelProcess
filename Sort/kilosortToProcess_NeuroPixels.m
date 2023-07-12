close all; clc; clear;
cd(fileparts(mfilename("fullpath")));
for mIndex = 1
%% load data
MERGEPATH = strcat("I:\neuroPixels\TDTTank\Rat2_SPR\Rat2SPR20230708\Merge", num2str(mIndex));
binFile = strcat(MERGEPATH, "\Wave.bin");

%% kilosort
run('config\configFile385.m');

% treated as linear probe if no chanMap file
ops.chanMap = 'config\neuropix385_kilosortChanMap.mat';

% total number of channels in your recording
ops.NchanTOT = 385; %384 CHs + 1 sync
% sample rate, Hz 
ops.fs = 30000;
for th2 = [7 ]
    ops.Th = [9 th2];
    savePath = fullfile(MERGEPATH, ['th', num2str(ops.Th(1))  , '_', num2str(ops.Th(2))]);
    if ~exist(strcat(savePath, "\params.py"), "file")
        mKilosort(binFile, ops, savePath);
    end
end
end