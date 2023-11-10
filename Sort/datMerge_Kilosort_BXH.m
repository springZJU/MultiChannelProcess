ccc
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");
%% TODO:
customInfo.recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
        "Bao_RNP_TBOffset_Recording.xlsx");
%               "SPR_MLA_Recording.xlsx"); 
%     "ZYY_RNP_TBOffset_Recording.xlsx");  

%         "YHT_RNP_Recording.xlsx");        
%           "SPR_MLA_Recording.xlsx");   
%         "XHX_MLA_Recording.xlsx");


customInfo.idSel = [11];
customInfo.MATPATH = "E:\BXH\MAT Data\";
% customInfo.MATPATH = "I:\neuroPixels\MAT Data";
% customInfo.MATPATH = "E:\MonkeyLinearArray\MAT Data\";

% customInfo.MATPATH = "H:\MLA_A1补充\MAT DATA\";

customInfo.thr = [9, 4];                        
% customInfo.thr = [7, 3];

customInfo.reExportSpk = false;
customInfo.exportSpkWave = false;
customInfo.ReSaveMAT = true;


%% %%%%%%%%%%%%%%%%%%%%%%%% datMerge %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%         elseif strcmpi(recTech, "newTech")
%             newTech_TDT_Merge(BLOCKPATH, DATAPATH, MERGEFILE, fs)
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%% kilosortToProcess_TDT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clc;
clearvars -except selInfo recordInfo customInfo MERGEFILE 
parseStruct(customInfo);
for rIndex = 1 : length(selInfo)
    run("process_Kilosort.m");
end

%% %%%%%%%%%%%%%%%%%%%%%% open GUI and save it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except selInfo customInfo
parseStruct(customInfo);
tankSel = unique([selInfo.TANKNAME]');
folders = cellfun(@(x) dir(x), tankSel, "uni", false);
strTemp = cellfun(@(x) char(strcat("Merge", num2str(x))), num2cell(customInfo.idSel)', "UniformOutput", false);
mergeFolder = cell2mat(cellfun(@(x) x(matches({x.name}', strTemp)), folders, "UniformOutput", false));
NPYPATH = string(cellfun(@(x, y) fullfile(x, y, ['th', num2str(thr(1)), '_', num2str(thr(2)), '\']), {mergeFolder.folder}', {mergeFolder.name}', "uni", false));
for nIndex = 1 : length(NPYPATH)
    cd(NPYPATH(nIndex));
    if ~isfile("cluster_info.tsv")%~exist("cluster_info.tsv", "file")
        run("process_TemplateGUI");
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

%% %%%%%%%%%%%%%%%%%%%%%% delete merged file %%%%%%%%%%%%%%%%%%%%%%%%%%%
for rIndex = 1 : length(customInfo.MERGEFILE)
    deleteItem(customInfo.MERGEFILE(rIndex));
    deleteItem(strrep(customInfo.MERGEFILE(rIndex), "Wave.bin", "temp_wh.dat"));
end