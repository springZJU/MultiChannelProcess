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

Area = ["AC", "MGB"];
PSTHDevWindow = [0, 300];
PSTHLastStdWindow = [-600, -300];
% Plot
RowNum = 4;
ColNum = 7;
Colors_fft = ["#000000", "#999999"]; %black;gray;

%%
for SettingParamIdx = 1%1 : numel(SettingParams)
    % load .mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    MatDirsInfo = dir(MatRootPath);
    MatDirsInfo(~(contains(string({MatDirsInfo.name}'), "cm") | contains(string({MatDirsInfo.name}'), "ddz"))) = [];
    PsthCSITemp = load(strcat(MatRootPath, "PopData_PsthCSI.mat"));

    for AreaIdx = 1%1 : numel(Area)
        TargetDirIdx = find(contains(string({MatDirsInfo.name}'), Area(AreaIdx)));
        % load params
        MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
        parseStruct(MSTIParams);
    
        for MatDirIdx = 8%1 : numel(TargetDirIdx)
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

                % PSTH campare significant test
                for trialTypeIdx = 1 : numel(KiloSpkData.chSpikeLfp)
                    trialNum = [KiloSpkData.chSpikeLfp(trialTypeIdx).trials];
                    IDtrialFR(trialTypeIdx).stimStr = KiloSpkData.chSpikeLfp(trialTypeIdx).stimStr;
                    IDspkieTemp = KiloSpkData.chSpikeLfp(trialTypeIdx).chSPK(IDIdx).spikePlot;
                    for trialIdx = 1 : numel(trialNum)
                        IDTrialSpikes = IDspkieTemp(IDspkieTemp(:, 2) == trialNum(trialIdx), 1);
                        IDtrialFR(trialTypeIdx).LastStdFR(trialIdx, 1) = length(find(IDTrialSpikes > PSTHLastStdWindow(1) & IDTrialSpikes <= PSTHLastStdWindow(2))) / (diff(PSTHLastStdWindow) / 1000);
                        IDtrialFR(trialTypeIdx).DevFR(trialIdx, 1) = length(find(IDTrialSpikes > PSTHDevWindow(1) & IDTrialSpikes <= PSTHDevWindow(2))) / (diff(PSTHDevWindow) / 1000);
                    end
                end

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
                        CdrPlot(IDIdx).RawPSTH(1).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).RawPSTH(1).Plot = [X RawY];
    
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
                        CdrPlot(IDIdx).RawPSTH(2).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).RawPSTH(2).Plot = [X RawY];
   
                    elseif subAxesNum == 5 %fft---PSTH
                        clear X Y cellTestTemp InterestFreq Amp sigtest;
                        PSTHFFTAxesCount = PSTHFFTAxesCount + 1;
                        PSTHFFTAxes(PSTHFFTAxesCount) = mSubplot(RowNum, ColNum, 5, [1, 1]);
                        TrialTypeStr = ProcessPsthFFTData.PsthFFTData(1).trialType;
                        X = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).MeanFFT(:, 1);
                        Y = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).MeanFFT(:, 2);
                        plot(X, Y, "LineWidth", 1, "Color", Colors_fft(1)); hold on;
    
                        title("PSTH-FFT");
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "x", [1000/max(unique(BaseICI)) - 10, 1000/min(unique(BaseICI)) + 10], "cutoffRange", [0, 350]);
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "y", "on");
                        line(1).X = 1000 / max(unique(BaseICI));
                        line(2).X = 1000 / min(unique(BaseICI));
                        addLines2Axes(PSTHFFTAxes(PSTHFFTAxesCount), line);

                        % FFT during successive sound
                        InterestFreq = [1000 ./ BaseICI(1, 1 : 2), 1000 / 300]; % BG and stdICI 
                        cellTestTemp = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).FFT;
                        % Significant test
                        [~, Amp] = cellfun(@(x) MSTI.tool.calFFTAmp(InterestFreq, x(:, 2), x(:, 1)), cellTestTemp, 'UniformOutput', false);
                        IDtestTemp = cellfun(@(y) cell2mat(y), cellfun(@(x) x(:, 1), Amp, 'UniformOutput', false), 'UniformOutput', false);

                        for freqIdx = 1 : numel(InterestFreq)
                            Targetfreq = InterestFreq(freqIdx);
                            Value = cell2mat(cellfun(@(x) x(Targetfreq == x(:, 2), 1)', IDtestTemp, 'UniformOutput', false));% col1:response; col2:baseline
                            [h, p] = ttest(Value(:, 1) - Value(:, 2), 0, "Tail", "right");
                            sigtest{1}{freqIdx, 1} = [h, p, Targetfreq];
                        end

                        CdrPlot(IDIdx).RawPSTHFFT(1).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).RawPSTHFFT(1).Plot = [X Y];
                        CdrPlot(IDIdx).FFTSigtest{1, 1} = sigtest{1}(:, 1);

                    elseif subAxesNum == 6 %fft---PSTH
                        clear X Y cellTestTemp InterestFreq Amp sigtest;
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

                        % FFT during successive sound
                        InterestFreq = [1000 ./ BaseICI(2, 1 : 2), 1000 / 300]; % BG and stdICI 
                        cellTestTemp = ProcessPsthFFTData.PsthFFTData(2).PsthFFTEachTrial(IDIdx).FFT;
                        % Significant test
                        [~, Amp] = cellfun(@(x) MSTI.tool.calFFTAmp(InterestFreq, x(:, 2), x(:, 1)), cellTestTemp, 'UniformOutput', false);
                        IDtestTemp = cellfun(@(y) cell2mat(y), cellfun(@(x) x(:, 1), Amp, 'UniformOutput', false), 'UniformOutput', false);

                        for freqIdx = 1 : numel(InterestFreq)
                            Targetfreq = InterestFreq(freqIdx);
                            Value = cell2mat(cellfun(@(x) x(Targetfreq == x(:, 2), 1)', IDtestTemp, 'UniformOutput', false));% col1:response; col2:baseline
                            [h, p] = ttest(Value(:, 1) - Value(:, 2), 0, "Tail", "right");
                            sigtest{2}{freqIdx, 1} = [h, p, Targetfreq];
                        end

                        CdrPlot(IDIdx).RawPSTHFFT(2).TrialType = TrialTypeStr;
                        CdrPlot(IDIdx).RawPSTHFFT(2).Plot = [X Y];
                        CdrPlot(IDIdx).FFTSigtest{2, 1} = sigtest{2}(:, 1);

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
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "y", "on", "cutoffRange", [0, 30]);
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
                        scaleAxes(PSTHFFTAxes(PSTHFFTAxesCount), "y", "on", "cutoffRange", [0, 30]);
                        line(1).X = 1000 / 300;
                        addLines2Axes(PSTHFFTAxes(PSTHFFTAxesCount), line);
    
                    elseif subAxesNum == 9 || subAxesNum == 10 %Compare raw---PSTH
                        clear X_Std Y_Std X_Dev Y_Dev h p;
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
                            if ComparelineNum == 1 %Std 
                                X_Std = KiloSpkData.chSpikeLfp(StdIdx).chSPK(IDIdx).PSTH(:, 1) + diff(MSTIsoundinfo(StdIdx).Std_Dev_Onset(end-1:end));
                                RawY_Std = KiloSpkData.chSpikeLfp(StdIdx).chSPK(IDIdx).PSTH(:, 2);
                                Y_Std = smoothdata(RawY_Std,'gaussian',25);
                                plot(X_Std, Y_Std, "LineWidth", 1, "Color", 'b'); hold on;

                            elseif ComparelineNum == 2 %Dev                     
                                X_Dev = KiloSpkData.chSpikeLfp(DevIdx).chSPK(IDIdx).PSTH(:, 1);
                                RawY_Dev = KiloSpkData.chSpikeLfp(DevIdx).chSPK(IDIdx).PSTH(:, 2);
                                Y_Dev = smoothdata(RawY_Dev,'gaussian',25);
                                plot(X_Dev, Y_Dev, "LineWidth", 1, "Color", 'r'); hold on;
                            end   

                        end
    
                        if subAxesNum == 9
                            ICIStr = strrep(MMNcompare(1).sound, "Std", "ICI");
                            set(PSTHAxes(PSTHAxesCount), "XTickLabel", {});
                            [h, p] = ttest2(IDtrialFR(DevIdx).DevFR, IDtrialFR(StdIdx).LastStdFR, "Tail", "right");
                            CdrPlot(IDIdx).RawPSTHCompare(1).CompareICI = ICIStr;
                            CdrPlot(IDIdx).RawPSTHCompare(1).BlueStd = [X_Std RawY_Std];
                            CdrPlot(IDIdx).RawPSTHCompare(1).RedDev = [X_Dev RawY_Dev];
                            CdrPlot(IDIdx).RawPSTHCompare(1).Sigtest = [h, p];
                            CdrPlot(IDIdx).SmoothPSTHCompare(1).BlueStd = [X_Std Y_Std];
                            CdrPlot(IDIdx).SmoothPSTHCompare(1).RedDev = [X_Dev Y_Dev];                            

                        elseif subAxesNum == 10
                            ICIStr = strrep(MMNcompare(2).sound, "Std", "ICI");
                            CdrPlot(IDIdx).RawPSTHCompare(2).CompareICI = ICIStr;
                            [h, p] = ttest2(IDtrialFR(DevIdx).DevFR, IDtrialFR(StdIdx).LastStdFR, "Tail", "right");
                            CdrPlot(IDIdx).RawPSTHCompare(2).BlueStd = [X_Std RawY_Std];
                            CdrPlot(IDIdx).RawPSTHCompare(2).RedDev = [X_Dev RawY_Dev];
                            CdrPlot(IDIdx).RawPSTHCompare(2).Sigtest = [h, p];
                            CdrPlot(IDIdx).SmoothPSTHCompare(1).BlueStd = [X_Std Y_Std];
                            CdrPlot(IDIdx).SmoothPSTHCompare(1).RedDev = [X_Dev Y_Dev];  
                        end
                        title(ICIStr);
                        xlim(compareWin);
                        scaleAxes(PSTHAxes(PSTHAxesCount), "y", "on");
                        line(1).X = 0;
                        addLines2Axes(PSTHAxes(PSTHAxesCount), line);
    
                    end
                end

                print(Fig(IDIdx), strcat(MatPath, strrep(string(KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).info), "CH", "ID"), "_Fig7_SingleUnit_Example.jpg"), "-djpeg", "-r200");
            end
            save(strcat(MatPath, "CdrPlot.mat"), "CdrPlot", "-mat");
            close all;
        end
    end

end