clear; clc;

% DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
% DataRootPath = "H:\MLA_A1补充\Figure\CTL_New_补充\";
% DataRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\Figure\MSTI_Recording1\";
DataRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\Figure\MSTI_Recording2\";

if strcmp(DataRootPath, "H:\MLA_A1补充\Figure\CTL_New\") || contains(DataRootPath, "Recording1")
    SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                    "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
elseif strcmp(DataRootPath, "H:\MLA_A1补充\Figure\CTL_New_补充\") || contains(DataRootPath, "Recording2")
    SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];
end
CommentTable = "2023-12-12CommentTable.xlsx";
DDZ_ExcludeShank = [{[""]}, {[""]}]; % First for AC Shank, Second for MGB Shank
CM_ExcludeShank = [{[""]}, {["A44R31"]}]; % First for AC Shank, Second for MGB Shank
Area = ["AC", "MGB"];
ArtificialSortChoose = true;

%plot
RowNum = 4;
ColNum = 6;
Step = {0.02, 0.04, 0.02};
margins_Col1_2 = [0.05, 0.05, 0.12, 0.1];
margins_Col3 = [0.3, 0.2, 0.12, 0.1];

%%
for SettingParamIdx = 1 : numel(SettingParams)
    clear PsthFFTAmpTemp PsthCSITemp CdrPlot_Fig8popDistribution
    line_click = []; line_clicktrainAC = []; line_CSI = [];
    proStrLong = SettingParams(SettingParamIdx);
    temp = strsplit(proStrLong, "_");
    proStrShort = string(temp{2});
    % load .mat 
    MatRootPath = strcat(DataRootPath, proStrLong, "\");
    PsthFFTAmpTemp = load(strcat(MatRootPath, "PopData_PsthFFTAmp.mat"));
    PsthCSITemp = load(strcat(MatRootPath, "PopData_PsthCSI.mat"));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Data cleaning %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %get NAN CSI
    isnan_CSIIdx = find(isnan(cell2mat({PsthCSITemp.PsthCSIData.CSI}')));
    %get artificial screen idx
    if exist(strcat(MatRootPath, "ArtificialExcludeCell.xlsx"), "file") ~= 0 && ArtificialSortChoose
        SortInfoPath = strcat(MatRootPath, "ArtificialExcludeCell.xlsx");
        SortIdx = MSTI.tool.ArtificialScreenCell(PsthFFTAmpTemp.PsthFFTAmpData, SortInfoPath);
        AllExcludeIdx = unique([isnan_CSIIdx; SortIdx]);
    elseif exist(strcat(MatRootPath, CommentTable), "file") ~= 0 && ArtificialSortChoose
        SortInfoPath = strcat(MatRootPath, CommentTable);
        SortIdx = MSTI.tool.CommentTableScreenCell(PsthFFTAmpTemp.PsthFFTAmpData, SortInfoPath);
        AllExcludeIdx = unique([isnan_CSIIdx; SortIdx]);
    elseif ~ArtificialSortChoose
        AllExcludeIdx = unique([isnan_CSIIdx]);
    end
    
    PsthFFTAmpTemp.PsthFFTAmpData(AllExcludeIdx) = [];
    PsthCSITemp.PsthCSIData(AllExcludeIdx) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ACIdx = find(strcmp(string({PsthCSITemp.PsthCSIData.Area}), "AC")' & ...
        ~ismember(string({PsthCSITemp.PsthCSIData.Position})', DDZ_ExcludeShank{1}) & ...
        ~ismember(string({PsthCSITemp.PsthCSIData.Position})', CM_ExcludeShank{1}));
    ACPsthFFTDataTemp = PsthFFTAmpTemp.PsthFFTAmpData(ACIdx);
    ACCSIDataTemp = PsthCSITemp.PsthCSIData(ACIdx);
    ClickFFTAmpData_AC = cell2mat({ACPsthFFTDataTemp.ClickFFT}');
    ClickTrainFFTAmpData_AC = cell2mat({ACPsthFFTDataTemp.ClickTrainFFT}');
    CSIData_AC = cell2mat({ACCSIDataTemp.CSI}'); 

    MGBIdx = find(strcmp(string({PsthCSITemp.PsthCSIData.Area}), "MGB")' & ...
        ~ismember(string({PsthCSITemp.PsthCSIData.Position})', DDZ_ExcludeShank{2}) & ...
        ~ismember(string({PsthCSITemp.PsthCSIData.Position})', CM_ExcludeShank{2}));
    MGBPsthFFTDataTemp = PsthFFTAmpTemp.PsthFFTAmpData(MGBIdx);
    MGBCSIDataTemp = PsthCSITemp.PsthCSIData(MGBIdx);
    ClickFFTAmpData_MGB = cell2mat({MGBPsthFFTDataTemp.ClickFFT}');
    ClickTrainFFTAmpData_MGB = cell2mat({MGBPsthFFTDataTemp.ClickTrainFFT}');
    CSIData_MGB = cell2mat({MGBCSIDataTemp.CSI}');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cal regress %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AC
    [ACslope12, ACintercept12, ~, ~, ACr12, ACp12] = regress_perp(ClickFFTAmpData_AC, ClickTrainFFTAmpData_AC);
    [ACslope13, ACintercept13, ~, ~, ACr13, ACp13] = regress_perp(ClickFFTAmpData_AC, CSIData_AC);
    [ACslope23, ACintercept23, ~, ~, ACr23, ACp23] = regress_perp(ClickTrainFFTAmpData_AC, CSIData_AC);
    %MGB
    [MGBslope12, MGBintercept12, ~, ~, MGBr12, MGBp12] = regress_perp(ClickFFTAmpData_MGB, ClickTrainFFTAmpData_MGB);
    [MGBslope13, MGBintercept13, ~, ~, MGBr13, MGBp13] = regress_perp(ClickFFTAmpData_MGB, CSIData_MGB);
    [MGBslope23, MGBintercept23, ~, ~, MGBr23, MGBp23] = regress_perp(ClickTrainFFTAmpData_MGB, CSIData_MGB);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AC
    subplot(2, 3, 1);
    ACfit12 = ACslope12 * ClickFFTAmpData_AC + ACintercept12;
    ACrsquare12 = rsquare(ClickTrainFFTAmpData_AC, ACfit12);
    plot(ClickFFTAmpData_AC, ClickTrainFFTAmpData_AC, '.', 'MarkerSize', 15, 'Color', 'r');hold on;
    xlabel("AC ClickInterval");
    ylabel("AC ClickDuration");
    title(strcat("AC Interval-Duration | ", "r^2 = ", string(roundn(ACrsquare12, -4)), " | r=", string(roundn(ACr12, -4)), " | p=", string(roundn(ACp12, -4))));

    subplot(2, 3, 2);
    ACfit13 = ACslope13 * ClickFFTAmpData_AC + ACintercept13;
    ACrsquare13 = rsquare(CSIData_AC, ACfit13);
    plot(ClickFFTAmpData_AC, CSIData_AC, '.', 'MarkerSize', 15, 'Color', 'r');hold on;
    xlabel("AC ClickInterval");
    ylabel("AC CSI");
    title(strcat("AC Interval-CSI | ", "r^2 = ", string(roundn(ACrsquare13, -4)), " | r=", string(roundn(ACr13, -4)), " | p=", string(roundn(ACp13, -4))));

    subplot(2, 3, 3);
    ACfit23 = ACslope23 * ClickTrainFFTAmpData_AC + ACintercept23;
    ACrsquare23 = rsquare(CSIData_AC, ACfit23);
    plot(ClickTrainFFTAmpData_AC, CSIData_AC, '.', 'MarkerSize', 15, 'Color', 'r');hold on;
    xlabel("AC ClickDuration");
    ylabel("AC CSI");    
    title(strcat("AC Duration-CSI | ", "r^2 = ", string(roundn(ACrsquare23, -4)), " | r=", string(roundn(ACr23, -4)), " | p=", string(roundn(ACp23, -4))));

    % MGB
    subplot(2, 3, 4);
    MGBfit12 = MGBslope12 * ClickFFTAmpData_MGB + MGBintercept12;
    MGBrsquare12 = rsquare(ClickTrainFFTAmpData_MGB, MGBfit12);
    plot(ClickFFTAmpData_MGB, ClickTrainFFTAmpData_MGB, '.', 'MarkerSize', 15, 'Color', 'b');hold on;
    xlabel("MGB ClickInterval");
    ylabel("MGB ClickDuration");
    title(strcat("MGB Interval-Duration | ", "r^2 = ", string(roundn(MGBrsquare12, -4)), " | r=", string(roundn(MGBr12, -4)), " | p=", string(roundn(MGBp12, -4))));

    subplot(2, 3, 5);
    MGBfit13 = MGBslope13 * ClickFFTAmpData_MGB + MGBintercept13;
    MGBrsquare13 = rsquare(CSIData_MGB, MGBfit13);
    plot(ClickFFTAmpData_MGB, CSIData_MGB, '.', 'MarkerSize', 15, 'Color', 'b');hold on;
    xlabel("MGB ClickInterval");
    ylabel("MGB CSI");
    title(strcat("MGB Interval-CSI | ", "r^2 = ", string(roundn(MGBrsquare13, -4)), " | r=", string(roundn(MGBr13, -4)), " | p=", string(roundn(MGBp13, -4))));

    subplot(2, 3, 6);
    MGBfit23 = MGBslope23 * ClickTrainFFTAmpData_MGB + MGBintercept23;
    MGBrsquare23 = rsquare(CSIData_MGB, MGBfit23);
    plot(ClickTrainFFTAmpData_MGB, CSIData_MGB, '.', 'MarkerSize', 15, 'Color', 'b');hold on;
    xlabel("MGB ClickDuration");
    ylabel("MGB CSI"); 
    title(strcat("MGB Duration-CSI | ", "r^2 = ", string(roundn(MGBrsquare23, -4)), " | r=", string(roundn(MGBr23, -4)), " | p=", string(roundn(MGBp23, -4))));


end
