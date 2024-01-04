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
Fig = figure;
maximizeFig(Fig);
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

    %% Plot Histogram
    ProtocolStrTemp = strsplit(SettingParams(SettingParamIdx), "_");
    ProtocolStr = ProtocolStrTemp{2};
    ShowStr = {ProtocolStr, strcat(" AC: ", string(length(ACIdx)), " | MGB: ", string(length(MGBIdx)))};
    annotation('textbox', [.01 .44 - (SettingParamIdx - 1) * 0.4 .2 .3], 'String', ShowStr, 'EdgeColor', 'none', 'FontSize', 10);
    %%%%%%%%%%%%%%%%%%% Plot------click %%%%%%%%%%%%%%%%%%%
    Edge_click = [min([ClickFFTAmpData_AC; ClickFFTAmpData_MGB]):Step{1}:max([ClickFFTAmpData_AC; ClickFFTAmpData_MGB])];
    [h_Click, pValue_Click] = ttest2(ClickFFTAmpData_AC, ClickFFTAmpData_MGB);
    [h_AC_Click, pValue_AC_Click] = ttest(ClickFFTAmpData_AC, 0, "Tail", "right");
    [h_MGB_Click, pValue_MGB_Click] = ttest(ClickFFTAmpData_MGB, 0, "Tail", "right");

    % AC------All Distribution 
    ClickCmpAx_AC(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 2 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);%All Distribution   
    h_AC_click = histogram(ClickFFTAmpData_AC, Edge_click); hold on;
    h_AC_click.FaceColor = 'r'; 
    annotation('textbox', [.22 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("ClickFFTAmp p=", string(roundn(pValue_Click, -4)), "| MeanAC=", string(roundn(mean(ClickFFTAmpData_AC), -3)),...
        ";MeanMGB=", string(roundn(mean(ClickFFTAmpData_MGB), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none'); 
    line_clickAC(1).X = mean(ClickFFTAmpData_AC); line_clickAC(1).color = 'r';
    % AC------Sig and Not Sig Distribution 
    ClickCmpAx_AC(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 2 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);%sig/no sig
    ACclick_SigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickFFT}) == 1);
    ACclick_NotSigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickFFT}) == 0);
    X_AC_clicksig = cell2mat({ACPsthFFTDataTemp(ACclick_SigIdx).ClickFFT})';
    X_AC_clickNotsig = cell2mat({ACPsthFFTDataTemp(ACclick_NotSigIdx).ClickFFT})';    
    h_ACsig_click = histogram(X_AC_clicksig, Edge_click); hold on;
    h_ACNotsig_click = histogram(X_AC_clickNotsig, Edge_click); hold on;
    h_ACsig_click.FaceColor = 'k'; h_ACNotsig_click.FaceColor = 'none';
    h_ACsig_click.EdgeColor = 'r'; h_ACNotsig_click.EdgeColor = 'r';

    % MGB------All Distribution
    ClickCmpAx_MGB(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 8 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);
    h_MGB_click = histogram(ClickFFTAmpData_MGB, Edge_click); hold on;
    h_MGB_click.FaceColor = 'b';
    line_clickMGB(1).X = mean(ClickFFTAmpData_MGB);line_clickMGB(1).color = 'b';
    % MGB------Sig and Not Sig Distribution
    ClickCmpAx_MGB(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 8 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);
    MGBclick_SigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickFFT}) == 1);
    MGBclick_NotSigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickFFT}) == 0);
    X_MGB_clicksig = cell2mat({MGBPsthFFTDataTemp(MGBclick_SigIdx).ClickFFT})';
    X_MGB_clickNotsig = cell2mat({MGBPsthFFTDataTemp(MGBclick_NotSigIdx).ClickFFT})';    
    h_MGBsig_click = histogram(X_MGB_clicksig, Edge_click); hold on;
    h_MGBNotsig_click = histogram(X_MGB_clickNotsig, Edge_click); hold on;
    h_MGBsig_click.FaceColor = 'k'; h_MGBNotsig_click.FaceColor = 'none';
    h_MGBsig_click.EdgeColor = 'b'; h_MGBNotsig_click.EdgeColor = 'b';

    scaleAxes([ClickCmpAx_AC(SettingParamIdx, 1);...
        ClickCmpAx_AC(SettingParamIdx, 2);...
        ClickCmpAx_MGB(SettingParamIdx, 1);...
        ClickCmpAx_MGB(SettingParamIdx, 2)], "y", "on");
    addLines2Axes(ClickCmpAx_AC(SettingParamIdx, 1), line_clickAC);
    addLines2Axes(ClickCmpAx_AC(SettingParamIdx, 2), line_clickAC);
    addLines2Axes(ClickCmpAx_MGB(SettingParamIdx, 1), line_clickMGB);
    addLines2Axes(ClickCmpAx_MGB(SettingParamIdx, 2), line_clickMGB);

    %%%%%%%%%%%%%%%%%%% Plot------click train %%%%%%%%%%%%%%%%%%%
    Edge_clicktrain = [min([ClickTrainFFTAmpData_AC; ClickTrainFFTAmpData_MGB]):Step{2}:max([ClickTrainFFTAmpData_AC; ClickTrainFFTAmpData_MGB])];
    [h_Clicktrain, pValue_Clicktrain] = ttest2(ClickTrainFFTAmpData_AC, ClickTrainFFTAmpData_MGB);
    [h_AC_Clicktrain, pValue_AC_Clicktrain] = ttest(ClickTrainFFTAmpData_AC, 0, "Tail", "right");
    [h_MGB_Clicktrain, pValue_MGB_Clicktrain] = ttest(ClickTrainFFTAmpData_MGB, 0, "Tail", "right");

    % AC------All Distribution 
    ClicktrainCmpAx_AC(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 4 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);
    h_AC_clicktrain = histogram(ClickTrainFFTAmpData_AC, Edge_clicktrain); hold on;
    h_AC_clicktrain.FaceColor = 'r'; 
    annotation('textbox', [.52 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("ClickTrainFFTAmp p=", string(roundn(pValue_Clicktrain, -4)), "| MeanAC=", string(roundn(mean(ClickTrainFFTAmpData_AC), -3)),...
        ";MeanMGB=", string(roundn(mean(ClickTrainFFTAmpData_MGB), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none');    
    line_clicktrainAC(1).X = mean(ClickTrainFFTAmpData_AC);line_clicktrainAC(1).color = 'r';
    % AC------Sig and Not Sig Distribution
    ClicktrainCmpAx_AC(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 4 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);
    ACclicktrain_SigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickTrainFFT}) == 1);
    ACclicktrain_NotSigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickTrainFFT}) == 0);
    X_AC_cktrainsig = cell2mat({ACPsthFFTDataTemp(ACclicktrain_SigIdx).ClickTrainFFT})';
    X_AC_cktrainNotsig = cell2mat({ACPsthFFTDataTemp(ACclicktrain_NotSigIdx).ClickTrainFFT})'; 
    h_ACsig_clicktrain = histogram(X_AC_cktrainsig, Edge_clicktrain); hold on;
    h_ACNotsig_clicktrain = histogram(X_AC_cktrainNotsig, Edge_clicktrain); hold on;
    h_ACsig_clicktrain.FaceColor = 'k'; h_ACNotsig_clicktrain.FaceColor = 'none';
    h_ACsig_clicktrain.EdgeColor = 'r'; h_ACNotsig_clicktrain.EdgeColor = 'r';

    % MGB------All Distribution     
    ClicktrainCmpAx_MGB(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 10 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);
    h_MGB_clicktrain = histogram(ClickTrainFFTAmpData_MGB, Edge_clicktrain); hold on;
    h_MGB_clicktrain.FaceColor = 'b';
    line_clicktrainMGB(1).X = mean(ClickTrainFFTAmpData_MGB);line_clicktrainMGB(1).color = 'b';
    % MGB------Sig and Not Sig Distribution
    ClicktrainCmpAx_MGB(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 10 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);
    MGBclicktrain_SigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickTrainFFT}) == 1);
    MGBclicktrain_NotSigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickTrainFFT}) == 0);
    X_MGB_cktrainsig = cell2mat({MGBPsthFFTDataTemp(MGBclicktrain_SigIdx).ClickTrainFFT})';
    X_MGB_cktrainNotsig = cell2mat({MGBPsthFFTDataTemp(MGBclicktrain_NotSigIdx).ClickTrainFFT})';    
    h_MGBsig_clicktrain = histogram(X_MGB_cktrainsig, Edge_clicktrain); hold on;
    h_MGBNotsig_clicktrain = histogram(X_MGB_cktrainNotsig, Edge_clicktrain); hold on;
    h_MGBsig_clicktrain.FaceColor = 'k'; h_MGBNotsig_clicktrain.FaceColor = 'none';
    h_MGBsig_clicktrain.EdgeColor = 'b'; h_MGBNotsig_clicktrain.EdgeColor = 'b';

    scaleAxes([ClicktrainCmpAx_AC(SettingParamIdx, 1);...
        ClicktrainCmpAx_AC(SettingParamIdx, 2);...
        ClicktrainCmpAx_MGB(SettingParamIdx, 1);...
        ClicktrainCmpAx_MGB(SettingParamIdx, 2)], "y", "on");
    addLines2Axes(ClicktrainCmpAx_AC(SettingParamIdx, 1), line_clicktrainAC);
    addLines2Axes(ClicktrainCmpAx_AC(SettingParamIdx, 2), line_clicktrainAC);
    addLines2Axes(ClicktrainCmpAx_MGB(SettingParamIdx, 1), line_clicktrainMGB);
    addLines2Axes(ClicktrainCmpAx_MGB(SettingParamIdx, 2), line_clicktrainMGB);

    %%%%%%%%%%%%%%%%%%% Plot------CSI %%%%%%%%%%%%%%%%%%%
    Edge_CSI = [min([CSIData_AC; CSIData_MGB]):Step{3}:max([CSIData_AC; CSIData_MGB])];
    [h_CSI, pValue_CSI] = ttest2(CSIData_AC, CSIData_MGB);
    [h_AC_CSI, pValue_AC_CSI] = ttest(CSIData_AC, 0, "Tail", "right");
    [h_MGB_CSI, pValue_MGB_CSI] = ttest(CSIData_MGB, 0, "Tail", "right");

    % AC------All Distribution 
    CSICmpAx_AC(SettingParamIdx) = mSubplot(RowNum, ColNum, 6 + (SettingParamIdx - 1) * 2 * ColNum, [2, 1], "margins", margins_Col3);
    h_AC_CSI = histogram(CSIData_AC, Edge_CSI, "Normalization", "probability"); hold on;
    h_AC_CSI.FaceColor = 'r'; 
    annotation('textbox', [.8 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("CSI p=", string(roundn(pValue_CSI, -4)), "| MeanAC=", string(roundn(mean(CSIData_AC), -3)),...
    ";MeanMGB=", string(roundn(mean(CSIData_MGB), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none'); 
    xlim([-0.5, 0.5]);
    line_CSIAC(1).X = mean(CSIData_AC);line_CSIAC(1).color = 'r';

    % MGB------All Distribution 
    CSICmpAx_MGB(SettingParamIdx) = mSubplot(RowNum, ColNum, 12 + (SettingParamIdx - 1) * 2 * ColNum, [2, 1], "margins", margins_Col3);
    h_MGB_CSI = histogram(CSIData_MGB, Edge_CSI, "Normalization", "probability"); hold on;
    h_MGB_CSI.FaceColor = 'b';
    xlim([-0.5, 0.5]);
    line_CSIMGB(1).X = mean(CSIData_MGB);line_CSIMGB(1).color = 'b';

    scaleAxes([CSICmpAx_AC(SettingParamIdx);...
        CSICmpAx_MGB(SettingParamIdx)], "y", "on");
    addLines2Axes(CSICmpAx_AC(SettingParamIdx), line_CSIAC);
    addLines2Axes(CSICmpAx_MGB(SettingParamIdx), line_CSIMGB);

    %% CDR plot 
    %%%%%%%%%%%%%%%%%%% Data cleaning %%%%%%%%%%%%%%%%%%%
    CdrPlot_Fig8popDistribution.ExcludeInfo{1, 1} = isnan_CSIIdx;
    CdrPlot_Fig8popDistribution.ExcludeInfo{1, 2} = "NAN CSI";
    if exist("ArtificialSortIdx", "var")
        CdrPlot_Fig8popDistribution.ExcludeInfo{2, 1} = SortIdx;
        CdrPlot_Fig8popDistribution.ExcludeInfo{2, 2} = "Artificial screen";
    end
    %%%%%%%%%%%%%%%%%%% Basic infomation %%%%%%%%%%%%%%%%%%%
    CdrPlot_Fig8popDistribution.protocol = proStrShort;
    CdrPlot_Fig8popDistribution.ACNumber = length(ACIdx);
    CdrPlot_Fig8popDistribution.MGBNumber = length(MGBIdx);    
    %%%%%%%%%%%%%%%%%%% click %%%%%%%%%%%%%%%%%%%
    CdrPlot_Fig8popDistribution.click.CmppValue = pValue_Click;
    CdrPlot_Fig8popDistribution.click.ACpValue = pValue_AC_Click;
    CdrPlot_Fig8popDistribution.click.MGBpValue = pValue_MGB_Click;    
    CdrPlot_Fig8popDistribution.click.ACClickDis{1, 1} = X_AC_clicksig; 
    CdrPlot_Fig8popDistribution.click.ACClickDis{1, 2} = mean(X_AC_clicksig); 
    CdrPlot_Fig8popDistribution.click.ACClickDis{1, 3} = "Sig";
    CdrPlot_Fig8popDistribution.click.ACClickDis{2, 1} = X_AC_clickNotsig;
    CdrPlot_Fig8popDistribution.click.ACClickDis{2, 2} = mean(X_AC_clickNotsig);
    CdrPlot_Fig8popDistribution.click.ACClickDis{2, 3} = "NotSig";
    CdrPlot_Fig8popDistribution.click.ACClickDis{3, 1} = ClickFFTAmpData_AC;
    CdrPlot_Fig8popDistribution.click.ACClickDis{3, 2} = mean(ClickFFTAmpData_AC);
    CdrPlot_Fig8popDistribution.click.ACClickDis{3, 3} = "All";    
    CdrPlot_Fig8popDistribution.click.MGBClickDis{1, 1} = X_MGB_clicksig; 
    CdrPlot_Fig8popDistribution.click.MGBClickDis{1, 2} = mean(X_MGB_clicksig); 
    CdrPlot_Fig8popDistribution.click.MGBClickDis{1, 3} = "Sig";
    CdrPlot_Fig8popDistribution.click.MGBClickDis{2, 1} = X_MGB_clickNotsig;
    CdrPlot_Fig8popDistribution.click.MGBClickDis{2, 2} = mean(X_MGB_clickNotsig);
    CdrPlot_Fig8popDistribution.click.MGBClickDis{2, 3} = "NotSig";
    CdrPlot_Fig8popDistribution.click.MGBClickDis{3, 1} = ClickFFTAmpData_MGB;
    CdrPlot_Fig8popDistribution.click.MGBClickDis{3, 2} = mean(ClickFFTAmpData_MGB);
    CdrPlot_Fig8popDistribution.click.MGBClickDis{3, 3} = "All";        

    %%%%%%%%%%%%%%%%%%% clicktrain %%%%%%%%%%%%%%%%%%%
    CdrPlot_Fig8popDistribution.cktrian.CmppValue = pValue_Clicktrain;
    CdrPlot_Fig8popDistribution.cktrian.ACpValue = pValue_AC_Clicktrain;
    CdrPlot_Fig8popDistribution.cktrian.MGBpValue = pValue_MGB_Clicktrain;
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{1, 1} = X_AC_cktrainsig; 
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{1, 2} = mean(X_AC_cktrainsig); 
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{1, 3} = "Sig";
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{2, 1} = X_AC_cktrainNotsig;
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{2, 2} = mean(X_AC_cktrainNotsig);
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{2, 3} = "NotSig";
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{3, 1} = ClickTrainFFTAmpData_AC;
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{3, 2} = mean(ClickTrainFFTAmpData_AC);
    CdrPlot_Fig8popDistribution.cktrian.ACcktrianDis{3, 3} = "All";      
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{1, 1} = X_MGB_cktrainsig; 
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{1, 2} = mean(X_MGB_cktrainsig); 
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{1, 3} = "Sig";
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{2, 1} = X_MGB_cktrainNotsig;
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{2, 2} = mean(X_MGB_cktrainNotsig);
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{2, 3} = "NotSig";
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{3, 1} = ClickTrainFFTAmpData_MGB;
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{3, 2} = mean(ClickTrainFFTAmpData_MGB);
    CdrPlot_Fig8popDistribution.cktrian.MGBcktrianDis{3, 3} = "All";

    %%%%%%%%%%%%%%%%%%% CSI %%%%%%%%%%%%%%%%%%%
    CdrPlot_Fig8popDistribution.CSI.CmppValue = pValue_CSI;
    CdrPlot_Fig8popDistribution.CSI.ACpValue = pValue_AC_CSI;
    CdrPlot_Fig8popDistribution.CSI.MGBpValue = pValue_MGB_CSI;
    CdrPlot_Fig8popDistribution.CSI.ACCSIDis{1, 1} = CSIData_AC;
    CdrPlot_Fig8popDistribution.CSI.ACCSIDis{1, 2} = mean(CSIData_AC);    
    CdrPlot_Fig8popDistribution.CSI.ACCSIDis{1, 3} = "All";
    CdrPlot_Fig8popDistribution.CSI.MGBCSIDis{1, 1} = CSIData_MGB;
    CdrPlot_Fig8popDistribution.CSI.MGBCSIDis{1, 2} = mean(CSIData_MGB);
    CdrPlot_Fig8popDistribution.CSI.MGBCSIDis{1, 3} = "All";
    %% save .mat
    save(strcat(MatRootPath, "CdrPlot_Fig8popDistribution.mat"), "CdrPlot_Fig8popDistribution");
end
print(gcf, strcat(DataRootPath, "MSTIFig8_AC_MGB_Distribution.jpg"), "-djpeg", "-r200");
% close;