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

Areas = ["AC", "MGB"];
MonkeyNames = ["cm", "ddz"];
ArtificialSortChoose = true;

%plot
RowNum = 2;
ColNum = 6;
Step = {0.02, 0.04, 0.02};
margins_Col1_2 = [0.05, 0.05, 0.12, 0.1];
margins_Col3 = [0.3, 0.2, 0.12, 0.1];

%%
for MonkeyIdx = 1 : numel(MonkeyNames)
    Fig = [];
    MonkeyName = MonkeyNames(MonkeyIdx);
    for AreaIdx = 1 : numel(Areas)
        Area = Areas(AreaIdx);
        for SettingParamIdx = 1 : numel(SettingParams)
            clear PsthFFTAmpTemp PsthCSITemp CdrPlot_Fig8popDistribution
            proStrLong = SettingParams(SettingParamIdx);

            % load .mat 
            MatRootPath = strcat(DataRootPath, proStrLong, "\");
            PsthFFTAmpTemp = load(strcat(MatRootPath, "PopData_PsthFFTAmp.mat"));
            PsthCSITemp = load(strcat(MatRootPath, "PopData_PsthCSI.mat"));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            PsthFFTAmpTemp.PsthFFTAmpData(~contains(string({PsthFFTAmpTemp.PsthFFTAmpData.Date})', MonkeyName)) = [];
            PsthCSITemp.PsthCSIData(~contains(string({PsthCSITemp.PsthCSIData.Date})', MonkeyName)) = [];        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            Idx = find(strcmp(string({PsthCSITemp.PsthCSIData.Area}), Area))';
            PsthFFTDataTemp = PsthFFTAmpTemp.PsthFFTAmpData(Idx);
            CSIDataTemp = PsthCSITemp.PsthCSIData(Idx);
            ShanksInfo(SettingParamIdx).protocol = proStrLong;
            ShanksInfo(SettingParamIdx).(strcat(MonkeyName, "_", Area)) = unique([string({PsthFFTDataTemp.Position})'; string({CSIDataTemp.Position})']);
        end
    end
end
%%
clear PsthFFTAmpTemp PsthCSITemp

for MonkeyIdx = 1%1 : numel(MonkeyNames)
    MonkeyName = MonkeyNames(MonkeyIdx);
    for AreaIdx = 1%1 : numel(Areas)
        Area = Areas(AreaIdx);
        ShanksInfoTemp = {ShanksInfo.(strcat(MonkeyName, "_", Area))};
        Shanks = [];
        for Idx = 1 : numel(ShanksInfoTemp)
            Shanks = [Shanks; ShanksInfoTemp{Idx}];
        end
        AllShanks = unique(Shanks);
        for ShankIdx = 1 : numel(AllShanks)
            Fig = figure;
            maximizeFig(Fig);
            TargetShank = AllShanks(ShankIdx);
            SettingParams = {ShanksInfo(1, cellfun(@(x) ismember(TargetShank, x), ShanksInfoTemp)').protocol};
            for SettingParamIdx = 1 : numel(SettingParams)
                clear PsthFFTAmpTemp PsthCSITemp CdrPlot_Fig8popDistribution
                line_click = []; line_clicktrain = []; line_CSI = [];
                proStrLong = SettingParams{SettingParamIdx};
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
                elseif exist(strcat(MatRootPath, "CommentTable.xlsx"), "file") ~= 0 && ArtificialSortChoose
                    SortInfoPath = strcat(MatRootPath, "CommentTable.xlsx");
                    SortIdx = MSTI.tool.CommentTableScreenCell(PsthFFTAmpTemp.PsthFFTAmpData, SortInfoPath);
                    AllExcludeIdx = unique([isnan_CSIIdx; SortIdx]);
                elseif ~ArtificialSortChoose
                    AllExcludeIdx = unique([isnan_CSIIdx]);
                end
                
                PsthFFTAmpTemp.PsthFFTAmpData(AllExcludeIdx) = [];
                PsthCSITemp.PsthCSIData(AllExcludeIdx) = [];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                PsthFFTAmpTemp.PsthFFTAmpData(~contains(string({PsthFFTAmpTemp.PsthFFTAmpData.Date})', MonkeyName)) = [];
                PsthCSITemp.PsthCSIData(~contains(string({PsthCSITemp.PsthCSIData.Date})', MonkeyName)) = [];        
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                Idx = find(strcmp(string({PsthCSITemp.PsthCSIData.Area}), Area))';
                PsthFFTDataTemp = PsthFFTAmpTemp.PsthFFTAmpData(Idx);
                CSIDataTemp = PsthCSITemp.PsthCSIData(Idx);
    
                TargetShankIdxs = contains(string({PsthFFTDataTemp.Position})', TargetShank);
                ClickFFTAmpData = cell2mat({PsthFFTDataTemp(TargetShankIdxs).ClickFFT}');
                ClickTrainFFTAmpData = cell2mat({PsthFFTDataTemp(TargetShankIdxs).ClickTrainFFT}');
                CSIData = cell2mat({CSIDataTemp(TargetShankIdxs).CSI}');
    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% Plot Histogram
                ProtocolStrTemp = strsplit(SettingParams{SettingParamIdx}, "_");
                ProtocolStr = ProtocolStrTemp{2};
                ShowStr = {ProtocolStr, strcat(" ", Area, ": ", string(sum(TargetShankIdxs)))};
                annotation('textbox', [.01 .44 - (SettingParamIdx - 1) * 0.4 .2 .3], 'String', ShowStr, 'EdgeColor', 'none', 'FontSize', 10);
                %%%%%%%%%%%%%%%%%%% Plot------click %%%%%%%%%%%%%%%%%%%
                Edge_click = min(ClickFFTAmpData):Step{1}:max(ClickFFTAmpData);
                
                % Area------All Distribution 
                ClickAx(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 2 + (SettingParamIdx - 1) *  ColNum, [1, 1], "margins", margins_Col1_2);%All Distribution   
                h_click = histogram(ClickFFTAmpData, Edge_click); hold on;
                h_click.FaceColor = 'r'; 
                annotation('textbox', [.22 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("ClickFFTAmp | Mean=", string(roundn(mean(ClickFFTAmpData), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none'); 
                line_click(1).X = mean(ClickFFTAmpData); line_click(1).color = 'r';
                % Area------Sig and Not Sig Distribution 
                ClickAx(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 2 + (SettingParamIdx - 1) * ColNum + 1, [1, 1], "margins", margins_Col1_2);%sig/no sig
                click_SigIdx = find(cell2mat({PsthFFTDataTemp(TargetShankIdxs).sigClickFFT}) == 1);
                click_NotSigIdx = find(cell2mat({PsthFFTDataTemp(TargetShankIdxs).sigClickFFT}) == 0);
                X_clicksig = cell2mat({PsthFFTDataTemp(click_SigIdx).ClickFFT})';
                X_clickNotsig = cell2mat({PsthFFTDataTemp(click_NotSigIdx).ClickFFT})';    
                h_sig_click = histogram(X_clicksig, Edge_click); hold on;
                h_Notsig_click = histogram(X_clickNotsig, Edge_click); hold on;
                h_sig_click.FaceColor = 'k'; h_Notsig_click.FaceColor = 'none';
                h_sig_click.EdgeColor = 'r'; h_Notsig_click.EdgeColor = 'r';
            
                scaleAxes([ClickAx(SettingParamIdx, 1); ClickAx(SettingParamIdx, 2)], "y", "on");
                addLines2Axes(ClickAx(SettingParamIdx, 1), line_click);
                addLines2Axes(ClickAx(SettingParamIdx, 2), line_click);
            
                %%%%%%%%%%%%%%%%%%% Plot------click train %%%%%%%%%%%%%%%%%%%
                Edge_clicktrain = min(ClickTrainFFTAmpData):Step{2}:max(ClickTrainFFTAmpData);
    
                % Area------All Distribution 
                ClicktrainAx(SettingParamIdx, 1) = mSubplot(RowNum, ColNum, 4 + (SettingParamIdx - 1) * ColNum, [1, 1], "margins", margins_Col1_2);
                h_clicktrain = histogram(ClickTrainFFTAmpData, Edge_clicktrain); hold on;
                h_clicktrain.FaceColor = 'r'; 
                annotation('textbox', [.52 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("ClickTrainFFTAmp | Mean=", string(roundn(mean(ClickTrainFFTAmpData), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none');    
                line_clicktrain(1).X = mean(ClickTrainFFTAmpData);line_clicktrain(1).color = 'r';
                % Area------Sig and Not Sig Distribution
                ClicktrainAx(SettingParamIdx, 2) = mSubplot(RowNum, ColNum, 4 + (SettingParamIdx - 1) * ColNum + 1, [1, 1], "margins", margins_Col1_2);
                clicktrain_SigIdx = find(cell2mat({PsthFFTDataTemp(TargetShankIdxs).sigClickTrainFFT}) == 1);
                clicktrain_NotSigIdx = find(cell2mat({PsthFFTDataTemp(TargetShankIdxs).sigClickTrainFFT}) == 0);
                X_cktrainsig = cell2mat({PsthFFTDataTemp(clicktrain_SigIdx).ClickTrainFFT})';
                X_cktrainNotsig = cell2mat({PsthFFTDataTemp(clicktrain_NotSigIdx).ClickTrainFFT})'; 
                h_sig_clicktrain = histogram(X_cktrainsig, Edge_clicktrain); hold on;
                h_Notsig_clicktrain = histogram(X_cktrainNotsig, Edge_clicktrain); hold on;
                h_sig_clicktrain.FaceColor = 'k'; h_Notsig_clicktrain.FaceColor = 'none';
                h_sig_clicktrain.EdgeColor = 'r'; h_Notsig_clicktrain.EdgeColor = 'r';
            
                scaleAxes([ClicktrainAx(SettingParamIdx, 1); ClicktrainAx(SettingParamIdx, 2)], "y", "on");
                addLines2Axes(ClicktrainAx(SettingParamIdx, 1), line_clicktrain);
                addLines2Axes(ClicktrainAx(SettingParamIdx, 2), line_clicktrain);
            
                %%%%%%%%%%%%%%%%%%% Plot------CSI %%%%%%%%%%%%%%%%%%%
                Edge_CSI = min(CSIData):Step{3}:max(CSIData);
    
                % AC------All Distribution 
                CSIAx(SettingParamIdx) = mSubplot(RowNum, ColNum, 6 + (SettingParamIdx - 1) * ColNum, [2, 1], "margins", margins_Col3);
                h_CSI = histogram(CSIData, Edge_CSI, "Normalization", "probability"); hold on;
                h_CSI.FaceColor = 'r'; 
                annotation('textbox', [.8 .66 - (SettingParamIdx - 1) * 0.43 .3 .3], 'String', strcat("CSI | Mean=", string(roundn(mean(CSIData), -3))), 'FitBoxToText', 'on', 'EdgeColor', 'none'); 
                xlim([-0.5, 0.5]);
                line_CSI(1).X = mean(CSIData);line_CSI(1).color = 'r';
            
                scaleAxes(CSIAx(SettingParamIdx), "y", "on");
                addLines2Axes(CSIAx(SettingParamIdx), line_CSI);
            
            end
            annotation(Fig, 'textbox', [.6, .9, .1, .1], 'String', strcat("Monkey: ", MonkeyName, " | ", TargetShank), 'FontSize', 20, 'EdgeColor', "none", 'FitBoxToText', 'on');
            % print(gcf, strcat(DataRootPath, MonkeyName, "_", TargetShank, "_MSTIFig8_AC_MGB_Distribution.jpg"), "-djpeg", "-r200");
            % close;
        end

    end
end