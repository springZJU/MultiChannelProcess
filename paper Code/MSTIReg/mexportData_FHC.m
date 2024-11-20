% only for FHC(one channel)
clear; clc;
IDs = [15];
SAVEMATPATH = '..\MAT DATA';
% RecordingExcelPATH = '..\..\RecordingInfo202403.xlsx';
RecordingExcelPATH = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
        "YHT_MLA_Recording.xlsx");
RecordingInfo = table2struct(readtable(RecordingExcelPATH));
Project = 'MSTIReg';
TargetIdx = find(contains({RecordingInfo.paradigm}, Project) & ismember([RecordingInfo.ID], IDs));

%% Export spkData.mat & lfpData.mat
for Idx = 1 : numel(TargetIdx)
    BLOCKPATH = RecordingInfo(TargetIdx(Idx)).BLOCKPATH;
    ProjectStr = RecordingInfo(TargetIdx(Idx)).paradigm;
    NameTemp = strsplit(string(BLOCKPATH), "\");
    MonkeyName = NameTemp(end - 2);
    Date = NameTemp(end - 1);
    sitePos = string(RecordingInfo(TargetIdx(Idx)).sitePos);

    % sort
    selectCh = input('Input selected channels:');
    data = TDTbin2mat(BLOCKPATH);
    sortData = mysort(data,selectCh,'reselect',"preview");

    dataCopy = data;
    clear data;    
    mkdir(fullfile(SAVEMATPATH, MonkeyName, ProjectStr, strcat(Date, "_", sitePos), strcat("k_", num2str(sortData.K))));

    % export spike data
    data.epocs    = dataCopy.epocs;
    data.spikeRaw.snips = dataCopy.snips;
    data.sortdata = [sortData.spikeTimeAll(sortData.clusterIdx ~=0), (sortData.clusterIdx(sortData.clusterIdx ~=0) - 1)*1000 + selectCh];
    data.spkWave  = [];
    save(fullfile(SAVEMATPATH, MonkeyName, ProjectStr, strcat(Date, "_", sitePos), strcat("k_", num2str(sortData.K)), "spkData.mat"), "data", "-mat");
    
    % export lfp data
    data = [];
    data.epocs    = dataCopy.epocs;
    data.lfp      = dataCopy.streams.Llfp;
    data.lfp.data = data.lfp.data(selectCh, :);
    data.lfp.channels = selectCh;
    save(fullfile(SAVEMATPATH, MonkeyName, ProjectStr, strcat(Date, "_", sitePos), strcat("k_", num2str(sortData.K)), "lfpData.mat"), "data", "-mat");
end

