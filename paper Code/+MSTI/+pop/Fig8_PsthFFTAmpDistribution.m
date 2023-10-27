clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
Area = ["AC", "MGB"];

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
    clear PsthFFTAmpTemp PsthCSITemp
    line_click = []; line_clicktrainAC = []; line_CSI = [];
    % load .mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    PsthFFTAmpTemp = load(strcat(MatRootPath, "PopData_PsthFFTAmp.mat"));
    PsthCSITemp = load(strcat(MatRootPath, "PopData_PsthCSI.mat"));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Data cleaning %%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    isnan_CSIIdx = find(isnan(cell2mat({PsthCSITemp.PsthCSIData.CSI}')));
    DataAll = {cell2mat({PsthFFTAmpTemp.PsthFFTAmpData.ClickFFT}');...
        cell2mat({PsthFFTAmpTemp.PsthFFTAmpData.ClickTrainFFT}');...
        cell2mat({PsthCSITemp.PsthCSIData.CSI}')};
    OutlierIdx = cellfun(@(x) find((x > nanmean(x) + 3 * nanstd(x)) | (x < nanmean(x) - 3 * nanstd(x))), DataAll, "UniformOutput", false);
    for Idx = 1 : numel(DataAll)
        DataAll{Idx}(OutlierIdx{Idx}) = [];
    end
    AllExcludeIdx = unique([cell2mat(OutlierIdx); isnan_CSIIdx]);
    PsthFFTAmpTemp.PsthFFTAmpData(AllExcludeIdx) = [];
    PsthCSITemp.PsthCSIData(AllExcludeIdx) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ACIdx = find(strcmp(string({PsthCSITemp.PsthCSIData.Area}), "AC"))';
    ACPsthFFTDataTemp = PsthFFTAmpTemp.PsthFFTAmpData(ACIdx);
    ACCSIDataTemp = PsthCSITemp.PsthCSIData(ACIdx);
    ClickFFTAmpData_AC = cell2mat({ACPsthFFTDataTemp.ClickFFT}');
    ClickTrainFFTAmpData_AC = cell2mat({ACPsthFFTDataTemp.ClickTrainFFT}');
    CSIData_AC = cell2mat({ACCSIDataTemp.CSI}'); 

    MGBIdx = find(strcmp(string({PsthCSITemp.PsthCSIData.Area}), "MGB"))';
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
    % AC------All Distribution 
    ClickCmpAx_AC(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 2 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);%All Distribution   
    h_AC_click = histogram(ClickFFTAmpData_AC, Edge_click); hold on;
    h_AC_click.FaceColor = 'r'; 
    annotation('textbox', [.22 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("ClickFFTAmp p=", string(roundn(pValue_Click, -4)), "| MeanAC=", string(roundn(mean(ClickFFTAmpData_AC), -3)),...
        ";MeanMGB=", string(roundn(mean(ClickFFTAmpData_MGB), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none'); 
    scaleAxes(ClickCmpAx_AC(SettingParamIdx, 1), "y", "on");
    line_clickAC(1).X = mean(ClickFFTAmpData_AC); line_clickAC(1).color = 'r';
    addLines2Axes(ClickCmpAx_AC(SettingParamIdx, 1), line_clickAC);
    % AC------Sig and Not Sig Distribution 
    ClickCmpAx_AC(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 2 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);%sig/no sig
    ACclick_SigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickFFT}) == 1);
    ACclick_NotSigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickFFT}) == 0);
    X_sig = cell2mat({ACPsthFFTDataTemp(ACclick_SigIdx).ClickFFT})';
    X_Notsig = cell2mat({ACPsthFFTDataTemp(ACclick_NotSigIdx).ClickFFT})';    
    h_ACsig_click = histogram(X_sig, Edge_click); hold on;
    h_ACNotsig_click = histogram(X_Notsig, Edge_click); hold on;
    h_ACsig_click.FaceColor = 'k'; h_ACNotsig_click.FaceColor = 'none';
    h_ACsig_click.EdgeColor = 'r'; h_ACNotsig_click.EdgeColor = 'r';
    scaleAxes(ClickCmpAx_AC(SettingParamIdx, 2), "y", "on");
    addLines2Axes(ClickCmpAx_AC(SettingParamIdx, 2), line_clickAC);

    % MGB------All Distribution
    ClickCmpAx_MGB(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 8 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);
    h_MGB_click = histogram(ClickFFTAmpData_MGB, Edge_click); hold on;
    h_MGB_click.FaceColor = 'b';
    line_clickMGB(1).X = mean(ClickFFTAmpData_MGB);line_clickMGB(1).color = 'b';
    addLines2Axes(ClickCmpAx_MGB(SettingParamIdx, 1), line_clickMGB);
    % MGB------Sig and Not Sig Distribution
    ClickCmpAx_MGB(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 8 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);
    MGBclick_SigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickFFT}) == 1);
    MGBclick_NotSigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickFFT}) == 0);
    X_sig = cell2mat({MGBPsthFFTDataTemp(MGBclick_SigIdx).ClickFFT})';
    X_Notsig = cell2mat({MGBPsthFFTDataTemp(MGBclick_NotSigIdx).ClickFFT})';    
    h_MGBsig_click = histogram(X_sig, Edge_click); hold on;
    h_MGBNotsig_click = histogram(X_Notsig, Edge_click); hold on;
    h_MGBsig_click.FaceColor = 'k'; h_MGBNotsig_click.FaceColor = 'none';
    h_MGBsig_click.EdgeColor = 'b'; h_MGBNotsig_click.EdgeColor = 'b';
    scaleAxes(ClickCmpAx_MGB(SettingParamIdx, 2), "y", "on");
    addLines2Axes(ClickCmpAx_MGB(SettingParamIdx, 2), line_clickMGB);

    %%%%%%%%%%%%%%%%%%% Plot------click train %%%%%%%%%%%%%%%%%%%
    Edge_clicktrain = [min([ClickTrainFFTAmpData_AC; ClickTrainFFTAmpData_MGB]):Step{2}:max([ClickTrainFFTAmpData_AC; ClickTrainFFTAmpData_MGB])];
    [h_Clicktrain, pValue_Clicktrain] = ttest2(ClickTrainFFTAmpData_AC, ClickTrainFFTAmpData_MGB);
    % AC------All Distribution 
    ClicktrainCmpAx_AC(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 4 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);
    h_AC_clicktrain = histogram(ClickTrainFFTAmpData_AC, Edge_clicktrain); hold on;
    h_AC_clicktrain.FaceColor = 'r'; 
    annotation('textbox', [.52 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("ClickTrainFFTAmp p=", string(roundn(pValue_Clicktrain, -4)), "| MeanAC=", string(roundn(mean(ClickTrainFFTAmpData_AC), -3)),...
        ";MeanMGB=", string(roundn(mean(ClickTrainFFTAmpData_MGB), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none');    
    scaleAxes(ClicktrainCmpAx_AC(SettingParamIdx, 1), "y", "on");
    line_clicktrainAC(1).X = mean(ClickTrainFFTAmpData_AC);line_clicktrainAC(1).color = 'r';
    addLines2Axes(ClicktrainCmpAx_AC(SettingParamIdx, 1), line_clicktrainAC);
    % AC------Sig and Not Sig Distribution
    ClicktrainCmpAx_AC(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 4 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);
    ACclicktrain_SigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickTrainFFT}) == 1);
    ACclicktrain_NotSigIdx = find(cell2mat({ACPsthFFTDataTemp.sigClickTrainFFT}) == 0);
    X_sig = cell2mat({ACPsthFFTDataTemp(ACclicktrain_SigIdx).ClickTrainFFT})';
    X_Notsig = cell2mat({ACPsthFFTDataTemp(ACclicktrain_NotSigIdx).ClickTrainFFT})'; 
    h_ACsig_clicktrain = histogram(X_sig, Edge_clicktrain); hold on;
    h_ACNotsig_clicktrain = histogram(X_Notsig, Edge_clicktrain); hold on;
    h_ACsig_clicktrain.FaceColor = 'k'; h_ACNotsig_clicktrain.FaceColor = 'none';
    h_ACsig_clicktrain.EdgeColor = 'r'; h_ACNotsig_clicktrain.EdgeColor = 'r';
    scaleAxes(ClicktrainCmpAx_AC(SettingParamIdx, 2), "y", "on");
    addLines2Axes(ClicktrainCmpAx_AC(SettingParamIdx, 2), line_clicktrainAC);

    % MGB------All Distribution     
    ClicktrainCmpAx_MGB(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 10 + (SettingParamIdx - 1) * 2 * ColNum, [1, 1], "margins", margins_Col1_2);
    h_MGB_clicktrain = histogram(ClickTrainFFTAmpData_MGB, Edge_clicktrain); hold on;
    h_MGB_clicktrain.FaceColor = 'b';
    line_clicktrainMGB(1).X = mean(ClickTrainFFTAmpData_MGB);line_clicktrainMGB(1).color = 'b';
    addLines2Axes(ClicktrainCmpAx_MGB(SettingParamIdx, 1), line_clicktrainMGB);
    % MGB------Sig and Not Sig Distribution
    ClicktrainCmpAx_MGB(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 10 + (SettingParamIdx - 1) * 2 * ColNum + 1, [1, 1], "margins", margins_Col1_2);
    MGBclicktrain_SigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickTrainFFT}) == 1);
    MGBclicktrain_NotSigIdx = find(cell2mat({MGBPsthFFTDataTemp.sigClickTrainFFT}) == 0);
    X_sig = cell2mat({MGBPsthFFTDataTemp(MGBclicktrain_SigIdx).ClickFFT})';
    X_Notsig = cell2mat({MGBPsthFFTDataTemp(MGBclicktrain_NotSigIdx).ClickFFT})';    
    h_MGBsig_clicktrain = histogram(X_sig, Edge_clicktrain); hold on;
    h_MGBNotsig_clicktrain = histogram(X_Notsig, Edge_clicktrain); hold on;
    h_MGBsig_clicktrain.FaceColor = 'k'; h_MGBNotsig_clicktrain.FaceColor = 'none';
    h_MGBsig_clicktrain.EdgeColor = 'b'; h_MGBNotsig_clicktrain.EdgeColor = 'b';
    scaleAxes(ClicktrainCmpAx_MGB(SettingParamIdx, 2), "y", "on");
    addLines2Axes(ClicktrainCmpAx_MGB(SettingParamIdx, 2), line_clicktrainMGB);

    %%%%%%%%%%%%%%%%%%% Plot------CSI %%%%%%%%%%%%%%%%%%%
    Edge_CSI = [min([CSIData_AC; CSIData_MGB]):Step{3}:max([CSIData_AC; CSIData_MGB])];
    [h_CSI, pValue_CSI] = ttest2(CSIData_AC, CSIData_MGB);
    % AC------All Distribution 
    CSICmpAx_AC(SettingParamIdx) = mSubplot(RowNum, ColNum, 6 + (SettingParamIdx - 1) * 2 * ColNum, [2, 1], "margins", margins_Col3);
    h_AC_CSI = histogram(CSIData_AC, Edge_CSI); hold on;
    h_AC_CSI.FaceColor = 'r'; 
    annotation('textbox', [.8 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("CSI p=", string(roundn(pValue_CSI, -4)), "| MeanAC=", string(roundn(mean(CSIData_AC), -3)),...
    ";MeanMGB=", string(roundn(mean(CSIData_MGB), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none'); 
    xlim([-0.5, 0.5]);
    scaleAxes(CSICmpAx_AC(SettingParamIdx), "y", "on");
    line_CSIAC(1).X = mean(CSIData_AC);line_CSIAC(1).color = 'r';
    addLines2Axes(CSICmpAx_AC(SettingParamIdx), line_CSIAC);

    % MGB------All Distribution 
    CSICmpAx_MGB(SettingParamIdx) = mSubplot(RowNum, ColNum, 12 + (SettingParamIdx - 1) * 2 * ColNum, [2, 1], "margins", margins_Col3);
    h_MGB_CSI = histogram(CSIData_MGB,Edge_CSI); hold on;
    h_MGB_CSI.FaceColor = 'b';
    xlim([-0.5, 0.5]);
    scaleAxes(CSICmpAx_MGB(SettingParamIdx), "y", "on");
    line_CSIMGB(1).X = mean(CSIData_MGB);line_CSIMGB(1).color = 'b';
    addLines2Axes(CSICmpAx_MGB(SettingParamIdx), line_CSIMGB);

end
