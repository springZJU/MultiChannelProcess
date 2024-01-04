clear; clc;

% DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
% DataRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\Figure\MSTI_Recording1\";
DataRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\Figure\MSTI_Recording2\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];

CommentTable = "2023-12-12CommentTable.xlsx";
DDZ_ExcludeShank = [{[""]}, {[""]}]; % First for AC Shank, Second for MGB Shank
CM_ExcludeShank = [{[""]}, {["A44R31"]}]; % First for AC Shank, Second for MGB Shank
Area = ["AC", "MGB"];
ArtificialSortChoose = true;
%%
for SettingParamIdx = 1 : numel(SettingParams)
    PsthCSIData = [];
    PsthFFTSigData = [];
    AllCellInfo = [];
    % load .mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    if ~exist(MatRootPath, "dir")
        continue;
    end
    PsthCSIData = load(strcat(MatRootPath, "PopData_PsthCSI.mat"));
    PsthFFTSigData = load(strcat(MatRootPath, "PopData_PsthFFTAmp.mat"));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Data cleaning %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %get NAN CSI
    isnan_CSIIdx = find(isnan(cell2mat({PsthCSIData.PsthCSIData.CSI}')));
    %get artificial screen idx
    if exist(strcat(MatRootPath, CommentTable), "file") ~= 0 && ArtificialSortChoose
        SortInfoPath = strcat(MatRootPath, CommentTable);
        SortIdx = MSTI.tool.CommentTableScreenCell(PsthFFTSigData.PsthFFTAmpData, SortInfoPath);
        AllExcludeIdx = unique([isnan_CSIIdx; SortIdx]);
    elseif ~ArtificialSortChoose
        AllExcludeIdx = unique([isnan_CSIIdx]);
    end
    
    PsthFFTSigData.PsthFFTAmpData(AllExcludeIdx) = [];
    PsthCSIData.PsthCSIData(AllExcludeIdx) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load params
    MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
    parseStruct(MSTIParams);

    [PsthFFTSigData.PsthFFTAmpData([PsthFFTSigData.PsthFFTAmpData.sigClickFFT]' ~= 1).ClickTag] = deal("NoSig");
    [PsthFFTSigData.PsthFFTAmpData([PsthFFTSigData.PsthFFTAmpData.sigClickFFT]' == 1).ClickTag] = deal("Sig");

    [PsthFFTSigData.PsthFFTAmpData([PsthFFTSigData.PsthFFTAmpData.sigClickTrainFFT]' ~= 1).ClickTrainTag] = deal("NoSig");
    [PsthFFTSigData.PsthFFTAmpData([PsthFFTSigData.PsthFFTAmpData.sigClickTrainFFT]' == 1).ClickTrainTag] = deal("Sig");

    [PsthCSIData.PsthCSIData([PsthCSIData.PsthCSIData.CSI]' > 0).CSITag] = deal('Dev');
    [PsthCSIData.PsthCSIData(~([PsthCSIData.PsthCSIData.CSI]' > 0)).CSITag] = deal('Std');
    
    AllCellInfo = struct('Date', {PsthFFTSigData.PsthFFTAmpData.Date},...
        'Position', {PsthFFTSigData.PsthFFTAmpData.Position},...
        'Area', {PsthFFTSigData.PsthFFTAmpData.Area},...
        'ID', {PsthFFTSigData.PsthFFTAmpData.ID},...
        'ClickTag', {PsthFFTSigData.PsthFFTAmpData.ClickTag},...
        'ClickTrainTag', {PsthFFTSigData.PsthFFTAmpData.ClickTrainTag},...
        'CSITag', {PsthCSIData.PsthCSIData.CSITag});

    ACcellIdx = find(contains(string({AllCellInfo.Area}'), "AC") & ...
        ~ismember(string({AllCellInfo.Position})', DDZ_ExcludeShank{1}) & ...
        ~ismember(string({AllCellInfo.Position})', CM_ExcludeShank{1}));
    AC_CellInfo = AllCellInfo(ACcellIdx);
    MGBcellIdx = find(contains(string({AllCellInfo.Area}'), "MGB") & ...
        ~ismember(string({AllCellInfo.Position})', DDZ_ExcludeShank{2}) & ...
        ~ismember(string({AllCellInfo.Position})', CM_ExcludeShank{2}));
    MGB_CellInfo = AllCellInfo(MGBcellIdx);

    AC_StasticTable = CellClasses(AC_CellInfo);
    MGB_StasticTable = CellClasses(MGB_CellInfo);
    All_StasticTable = CellClasses(AllCellInfo);


    save(strcat(MatRootPath, "CdrPlot_Alluvial.mat"), "AC_CellInfo", "MGB_CellInfo", "AC_StasticTable", "MGB_StasticTable", "All_StasticTable", "-mat");

end

%%
function StasticTable = CellClasses(CellInfo)
    SSD = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["Sig", "Sig", "Dev"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));
    SSS = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["Sig", "Sig", "Std"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));
    SND = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["Sig", "NoSig", "Dev"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));
    SNS = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["Sig", "NoSig", "Std"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));
    NSD = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["NoSig", "Sig", "Dev"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));
    NSS = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["NoSig", "Sig", "Std"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));
    NND = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["NoSig", "NoSig", "Dev"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));
    NNS = numel(find(cellfun(@(x, y, z) all(strcmp([x, y, z], ["NoSig", "NoSig", "Std"])), {CellInfo.ClickTag}, {CellInfo.ClickTrainTag}, {CellInfo.CSITag})));   
    TypeGroups = {["Sig", "Sig", "Dev"], ["Sig", "Sig", "Std"], ["Sig", "NoSig", "Dev"], ["Sig", "NoSig", "Std"],...
        ["NoSig", "Sig", "Dev"], ["NoSig", "Sig", "Std"], ["NoSig", "NoSig", "Dev"], ["NoSig", "NoSig", "Std"]};
    GroupsWeight = {SSD, SSS, SND, SNS, NSD, NSS, NND, NNS};
    for TypeIdx = 1 : numel(TypeGroups)
        StasticTable(TypeIdx).Click = TypeGroups{TypeIdx}(1);
        StasticTable(TypeIdx).ClickTrain = TypeGroups{TypeIdx}(2);
        StasticTable(TypeIdx).CSI = TypeGroups{TypeIdx}(3);
        StasticTable(TypeIdx).Weight = GroupsWeight{TypeIdx};
    end
end