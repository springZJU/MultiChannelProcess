clc; clear
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");
%% TODO:
customInfo.recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "SPR_MLA_Recording.xlsx");
customInfo.dateSel = "";
customInfo.MATPATH = "E:\MonkeyLinearArray\MAT Data\";
customInfo.animal = "MLA"; % MLA/RNP/RLA
customInfo.thr = [7, 6];
customInfo.exportSpkWave = true;
customInfo.ReSaveMAT = false;
customInfo.reExportSpk = false;

%% %%%%%%%%%%%%%%%%%%%%%%%% datMerge_TDT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parseStruct(customInfo);
run("process_LoadExcel.m");
for rIndex = 1 : length(recID)
    run("process_Merge.m");
    if isempty(selIdx)
        continue
    end
    
    if ~exist(strcat(MERGEPATH, "\mergePara.mat"),'file')
        mkdir(MERGEPATH);
        % load data depends on recording tech
        if strcmpi(recTech, "TDT")
            TDT2binMerge(BLOCKPATH,MERGEFILE);
        elseif strcmpi(recTech, "NeuroPixel")
            NP_TDT_Merge(BLOCKPATH, DATAPATH, MERGEFILE, fs)
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%% kilosortToProcess_TDT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clc;
clearvars -except selInfo recordInfo customInfo    
parseStruct(customInfo);
for rIndex = 1 : length(selInfo)
    run("process_Kilosort.m");
end

%% %%%%%%%%%%%%%%%%%%%%%% open GUI and save it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except selInfo customInfo
parseStruct(customInfo);
tankSel = unique([selInfo.TANKNAME]');
folders = cellfun(@(x) dir(x), tankSel, "uni", false);
mergeFolder = cell2mat(cellfun(@(x) x(contains({x.name}', "Merge")), folders, "UniformOutput", false));
NPYPATH = string(cellfun(@(x, y) fullfile(x, y, 'th7_6\'), {mergeFolder.folder}', {mergeFolder.name}', "uni", false));
for nIndex = 1 : length(NPYPATH)
    cd(NPYPATH(nIndex));
    if ~exist("cluster_info.tsv", "file")
        system("phy template-gui params.py");
    end
end

%% %%%%%%%%%%%%%%%%%%%%%% selectKilosortResult %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for nIndex = 1 : length(NPYPATH)
    run("process_ExportSpike.m");
end
 
%% %%%%%%%%%%%%%%%%%%%%%% save MAT file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except  customInfo
parseStruct(customInfo);
run("process_SaveMAT.m");