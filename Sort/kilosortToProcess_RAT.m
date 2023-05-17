close all; clc; clear;
cd(fileparts(mfilename("fullpath")));
parentFolder = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(parentFolder));

%% generate .bin file
% TANKPATH = 'F:\spr\TBOffsetRat1_SPR\rat1-20230228';  %tank路径
% TANKPATH = 'F:\spr\TBOffsetRat1_DXY\dxy1-20230219';  %tank路径
TANKPATH = 'I:\F2RatLinearArray\DATA\TBOffsetRat1_ZYY\zyy1-20230314';  %tank路径
MergeFolder = 'Merge3'; %在tank路径下生成Merge1文件夹，存放ks结果
BLOCKNUM = num2cell([28:36]); %选择要sort的block number
Block = 'Block-1';
BLOCKPATH = cellfun(@(x) fullfile(TANKPATH,['Block-' num2str(x)]),BLOCKNUM,'UniformOutput',false);
MERGEPATH = fullfile(TANKPATH,MergeFolder);


% data = TDTbin2mat(fullfile(TANKPATH,Block),'TYPE' ,{'EPOCS'});
% display(['the first sound of ' Block ' is: '  num2str(data.epocs.ordr.onset(1))]);

binPath = [MERGEPATH '\Wave.bin']; 
if ~exist(binPath,'file')
    TDT2binMerge(BLOCKPATH,MergeFolder);
end



%% kilosort
run('config\configFileRat.m');
% treated as linear probe if no chanMap file
ops.chanMap = 'config\chan16_2_kilosortChanMap.mat';
% total number of channels in your recording
ops.NchanTOT = 32;
% sample rate, Hz 
ops.fs = 12207.03125;
for th2 = [6 ]
    ops.Th = [7 th2];
    savePath = fullfile(MERGEPATH, ['th', num2str(ops.Th(1))  , '_', num2str(ops.Th(2))]);
    if ~exist([savePath '\params.py'])
        mKilosort(binPath, ops, savePath);
    end
%     display(['the first sound of ' Block ' is: '  num2str(data.epocs.ordr.onset(1))]);
    %     system('phy template-gui params.py');
end
