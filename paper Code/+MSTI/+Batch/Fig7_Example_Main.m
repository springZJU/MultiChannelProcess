clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];
Area = ["AC", "MGB"];

% Plot
RowNum = 4;
ColNum = 7;
Colors_fft = ["#000000", "#999999"]; %black;gray;

%%
for SettingParamIdx = [1, 3]%1 : numel(SettingParams)
    % load .mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    MatDirsInfo = dir(MatRootPath);
    MatDirsInfo(~(contains(string({MatDirsInfo.name}'), "cm") | contains(string({MatDirsInfo.name}'), "ddz"))) = [];
    for AreaIdx = 1%1 : numel(Area)
        TargetDirIdx = find(contains(string({MatDirsInfo.name}'), Area(AreaIdx)));
        % load params
        MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
        parseStruct(MSTIParams);
    
        for MatDirIdx = 1 : numel(TargetDirIdx)
            clear KiloSpkData LfpData ProcessPsthFFTData;
            MatPath = strcat(MatRootPath, MatDirsInfo(TargetDirIdx(MatDirIdx)).name, "\");
            %kiloSpike
            KiloSpkData = load(strcat(MatPath, "spkRes.mat"), "chSpikeLfp");
            LfpData = load(strcat(MatPath, "lfpRes.mat"), "chSpikeLfp");        
            ProcessPsthFFTData = load(strcat(MatPath, "ProcessData_ReDoPsthFFT.mat"), "PsthFFTData");
    
            for IDIdx = 1 : numel(KiloSpkData.chSpikeLfp(1).chSPK)
                Fig(IDIdx) = figure;
                maximizeFig(Fig(IDIdx));
                IDNum = double(string(regexpi(string(KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).info), "CH(\d+)", "tokens")));
                CHNum = double(string(cellfun(@(x) regexpi(x, "CH(\d+)", "tokens"), {LfpData.chSpikeLfp(1).chLFP.info}')));
                IDStr = strrep(string(KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).info), "CH", "ID");
                CdrPlot(IDIdx).ID = IDStr;
                LFPAxesCount = 0; PSTHAxesCount = 0; PSTHFFTAxesCount = 0;
    
                for subAxesNum = 1 : 10
                    clear X Y;
                    line = [];
                    if subAxesNum == 1 || subAxesNum == 2 %lfp
                        LFPAxesCount = LFPAxesCount + 1;
                        LFPAxes(LFPAxesCount) = mSubplot(RowNum, ColNum, 1 + (subAxesNum - 1) * ColNum, [1, 1]);
                        if IDNum >= 1000; ID_CH = mod(IDNum, 1000); else; ID_CH = IDNum; end
                        CHidx = find(ID_CH == unique(CHNum));
                        if ~isempty(CHidx)
                            CHidx_plot = CHidx;
                        else
                            disp("No corresponding CH, find neighbor Channel......");
                            [~, NeighborCHIdx] = min(abs(CHNum - ID_CH));
                            CHidx_plot = NeighborCHIdx;
                        end
                        CHStr = strcat("CH", string(CHidx_plot));
                        CdrPlot(IDIdx).CH = CHStr;
                        for lineNum = 1 : numel(LfpData.chSpikeLfp)
                            X = LfpData.chSpikeLfp(lineNum).chLFP(CHidx_plot).FFT(:, 1);
                            Y = LfpData.chSpikeLfp(lineNum).chLFP(CHidx_plot).FFT(:, 2);
                            plot(X, Y, "LineWidth", 1, "Color", Colors_fft(lineNum)); hold on;
                            CdrPlot(IDIdx).LfpFFT(lineNum).TrialType = LfpData.chSpikeLfp(lineNum).stimStr;
                            CdrPlot(IDIdx).LfpFFT(lineNum).Plot = [X Y];    
                        end
    
                        if subAxesNum == 1
                            title(strcat("LFP: ", CHStr));
                            legend([LfpData.chSpikeLfp(1).stimStr, LfpData.chSpikeLfp(2).stimStr]);
                            scaleAxes(LFPAxes(LFPAxesCount), "x", [1000/max(unique(BaseICI)) - 10, 1000/min(unique(BaseICI)) + 10], "cutoffRange", [0, 350]);
                            scaleAxes(LFPAxes(LFPAxesCount), "y", "on");
                            line(1).X = 1000/max(unique(BaseICI));
                            line(2).X = 1000/min(unique(BaseICI));
                            addLines2Axes(LFPAxes(LFPAxesCount), line);
                        elseif subAxesNum == 2
                            xlim([0, 8]);
                            scaleAxes(LFPAxes(LFPAxesCount), "y", "on");
                            line(1).X = 1000/300;
                            addLines2Axes(LFPAxes(LFPAxesCount), line);
                        end
    
                    elseif subAxesNum == 3 %raw---PSTH
                        clear X Y;
                        PSTHAxesCount = PSTHAxesCount + 1;
                        PSTHAxes(PSTHAxesCount) = mSubplot(RowNum, ColNum, 3, [3, 1]);
                        TrialTypeStr = KiloSpkData.chSpikeLfp(1).stimStr;
                        X = KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).PSTH(:, 1);
                        RawY = KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).PSTH(:, 2);
                        Y = smoothdata(RawY,'gaussian',25);
                        plot(X, Y, "LineWidth", 1, "Color", Colors_fft(1)); hold on;
    
                        title(strcat("PSTH: ", IDStr, " | ", TrialTypeStr));
                        xlim(plotWin);
                        set(PSTHAxes(PSTHAxesCount), "XTickLabel", {});
                        scaleAxes(PSTHAxes(PSTHAxesCount), "y", "on");
                        for lineNum = 1 : numel(MSTIsoundinfo(1).Std_Dev_Onset)
                            line(lineNum).X = MSTIsoundinfo(1).Std_Dev_Onset(lineNum) - MSTIsoundinfo(1).Std_Dev_Onset(end);
                            addLines2Axes(PSTHAxes(PSTHAxesCount), line);
                        end
    
                        CdrPlot(IDIdx).SmoothRawPSTH(1).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).SmoothRawPSTH(1).Plot = [X Y];
    
                    elseif subAxesNum == 4 %raw---PSTH
                        clear X Y;
                        PSTHAxesCount = PSTHAxesCount + 1;
                        PSTHAxes(PSTHAxesCount) = mSubplot(RowNum, ColNum, 10, [3, 1]);
                        TrialTypeStr = KiloSpkData.chSpikeLfp(2).stimStr;
                        X = KiloSpkData.chSpikeLfp(2).chSPK(IDIdx).PSTH(:, 1);
                        RawY = KiloSpkData.chSpikeLfp(2).chSPK(IDIdx).PSTH(:, 2);
                        Y = smoothdata(RawY,'gaussian',25);
                        plot(X, Y, "LineWidth", 1, "Color", Colors_fft(2)); hold on;
    
                        title(TrialTypeStr);
                        xlim(plotWin);
                        scaleAxes(PSTHAxes(PSTHAxesCount), "y", "on");
                        for lineNum = 1 : numel(MSTIsoundinfo(1).Std_Dev_Onset)
                            line(lineNum).X = MSTIsoundinfo(2).Std_Dev_Onset(lineNum) - MSTIsoundinfo(2).Std_Dev_Onset(end);
                            addLines2Axes(PSTHAxes(PSTHAxesCount), line);
                        end
    
                        CdrPlot(IDIdx).SmoothRawPSTH(2).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).SmoothRawPSTH(2).Plot = [X Y];
    
                    elseif subAxesNum == 5 %fft---PSTH
                        clear X Y;
                        PSTHFFTAxesCount = PSTHFFTAxesCount + 1;
                        PSTHFFTAxes(PSTHFFTAxesCount) = mSubplot(RowNum, ColNum, 5, [1, 1]);
                        TrialTypeStr = ProcessPsthFFTData.PsthFFTData(1).trialType;
                        X = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).MeanFFT(:, 1);
                        Y = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).MeanFFT(:, 2);
                        plot(X, Y, "LineWidth", 1, "Color", Colors_fft(1)); hold on;
    
                        title("PSTH-FFT");
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "x", [1000/max(unique(BaseICI)) - 10, 1000/min(unique(BaseICI)) + 10], "cutoffRange", [0, 350]);
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "y", "on");
                        line(1).X = 1000/max(unique(BaseICI));
                        line(2).X = 1000/min(unique(BaseICI));
                        addLines2Axes(PSTHFFTAxes(PSTHFFTAxesCount), line);
    
                        CdrPlot(IDIdx).RawPSTHFFT(1).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).RawPSTHFFT(1).Plot = [X Y];
    
                    elseif subAxesNum == 6 %fft---PSTH
                        clear X Y;
                        PSTHFFTAxesCount = PSTHFFTAxesCount + 1;
                        PSTHFFTAxes(PSTHFFTAxesCount) = mSubplot(RowNum, ColNum, 12, [1, 1]);
                        TrialTypeStr = ProcessPsthFFTData.PsthFFTData(2).trialType;
                        X = ProcessPsthFFTData.PsthFFTData(2).PsthFFTEachTrial(IDIdx).MeanFFT(:, 1);
                        Y = ProcessPsthFFTData.PsthFFTData(2).PsthFFTEachTrial(IDIdx).MeanFFT(:, 2);
                        plot(X, Y, "LineWidth", 1, "Color", Colors_fft(2)); hold on;
    
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "x", [1000/max(unique(BaseICI)) - 10, 1000/min(unique(BaseICI)) + 10], "cutoffRange", [0, 350]);
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "y", "on");
                        line(1).X = 1000/max(unique(BaseICI));
                        line(2).X = 1000/min(unique(BaseICI));
                        addLines2Axes(PSTHFFTAxes(PSTHFFTAxesCount), line);
    
                        CdrPlot(IDIdx).RawPSTHFFT(2).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).RawPSTHFFT(2).Plot = [X Y];
    
                    elseif subAxesNum == 7 %fft---PSTH
                        clear X Y;
                        PSTHFFTAxesCount = PSTHFFTAxesCount + 1;
                        PSTHFFTAxes(PSTHFFTAxesCount) = mSubplot(RowNum, ColNum, 6, [1, 1]);
                        TrialTypeStr = ProcessPsthFFTData.PsthFFTData(1).trialType;
                        X = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).MeanFFT(:, 1);
                        Y = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).MeanFFT(:, 2);
                        plot(X, Y, "LineWidth", 1, "Color", Colors_fft(1)); hold on;
    
                        title("PSTH-FFT");
                        xlim([0, 8]);
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "y", "on");
                        line(1).X = 1000 / 300;
                        addLines2Axes(PSTHFFTAxes(PSTHFFTAxesCount), line);
    
                    elseif subAxesNum == 8 %fft---PSTH
                        clear X Y;
                        PSTHFFTAxesCount = PSTHFFTAxesCount + 1;
                        PSTHFFTAxes(PSTHFFTAxesCount) = mSubplot(RowNum, ColNum, 13, [1, 1]);
                        TrialTypeStr = ProcessPsthFFTData.PsthFFTData(2).trialType;
                        X = ProcessPsthFFTData.PsthFFTData(2).PsthFFTEachTrial(IDIdx).MeanFFT(:, 1);
                        Y = ProcessPsthFFTData.PsthFFTData(2).PsthFFTEachTrial(IDIdx).MeanFFT(:, 2);
                        plot(X, Y, "LineWidth", 1, "Color", Colors_fft(2)); hold on;
    
                        xlim([0, 8]);
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "y", "on");
                        line(1).X = 1000 / 300;
                        addLines2Axes(PSTHFFTAxes(PSTHFFTAxesCount), line);
    
                    elseif subAxesNum == 9 || subAxesNum == 10 %Compare raw---PSTH
                        clear X_Std Y_Std X_Dev Y_Dev
                        PSTHAxesCount = PSTHAxesCount + 1;
                        if subAxesNum == 9
                            PSTHAxes(PSTHAxesCount) = mSubplot(RowNum, ColNum, 7, [1, 1]);
                            DevIdx = MMNcompare(1).DevOrder;
                            StdIdx = MMNcompare(1).StdOrder_Lagidx;
                        elseif subAxesNum == 10
                            PSTHAxes(PSTHAxesCount) = mSubplot(RowNum, ColNum, 14, [1, 1]);
                            DevIdx = MMNcompare(2).DevOrder;
                            StdIdx = MMNcompare(2).StdOrder_Lagidx;
                        end
    
                        for ComparelineNum = 1 : 2
                            if ComparelineNum == 1 %Std KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).PSTH(:, 1)
                                X_Std = KiloSpkData.chSpikeLfp(StdIdx).chSPK(IDIdx).PSTH(:, 1) + diff(MSTIsoundinfo(StdIdx).Std_Dev_Onset(end-1:end));
                                RawY = KiloSpkData.chSpikeLfp(StdIdx).chSPK(IDIdx).PSTH(:, 2);
                                Y_Std = smoothdata(RawY,'gaussian',25);
                                plot(X_Std, Y_Std, "LineWidth", 1, "Color", 'b'); hold on;
                            elseif ComparelineNum == 2 %Dev                     
                                X_Dev = KiloSpkData.chSpikeLfp(DevIdx).chSPK(IDIdx).PSTH(:, 1);
                                RawY = KiloSpkData.chSpikeLfp(DevIdx).chSPK(IDIdx).PSTH(:, 2);
                                Y_Dev = smoothdata(RawY,'gaussian',25);
                                plot(X_Dev, Y_Dev, "LineWidth", 1, "Color", 'r'); hold on;
                            end              
                        end
    
                        if subAxesNum == 9
                            ICIStr = strrep(MMNcompare(1).sound, "Std", "ICI");
                            set(PSTHAxes(PSTHAxesCount), "XTickLabel", {})
                            CdrPlot(IDIdx).RawPSTHCompare(1).CompareICI = ICIStr;
                            CdrPlot(IDIdx).RawPSTHCompare(1).BlueStd = [X_Std Y_Std];
                            CdrPlot(IDIdx).RawPSTHCompare(1).RedDev = [X_Dev Y_Dev];
                        elseif subAxesNum == 10
                            ICIStr = strrep(MMNcompare(2).sound, "Std", "ICI");
                            CdrPlot(IDIdx).RawPSTHCompare(2).CompareICI = ICIStr;
                            CdrPlot(IDIdx).RawPSTHCompare(2).BlueStd = [X_Std Y_Std];
                            CdrPlot(IDIdx).RawPSTHCompare(2).RedDev = [X_Dev Y_Dev];
                        end
                        title(ICIStr);
                        xlim(compareWin);
                        scaleAxes(PSTHAxes(PSTHAxesCount), "y", "on");
                        line(1).X = 0;
                        addLines2Axes(PSTHAxes(PSTHAxesCount), line);
    
                    end
                end
                save(strcat(MatPath, "CdrPlot.mat"), "CdrPlot", "-mat");
                print(Fig(IDIdx), strcat(MatPath, strrep(string(KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).info), "CH", "ID"), "_Fig7_SingleUnit_Example.jpg"), "-djpeg", "-r200");
            end
            close all;
        end
    end

end