clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
ArtificialSortChoose = true;
SigTestWinLength = 300;%ms

%% Plot
Fig = figure;
maximizeFig(Fig);
RowNum = 4;
ColNum = 14;

for SettingIdx = 1 : numel(SettingParams)
    clear popPsthData CdrPlot_Fig7popPsth;
    % load spkRes.mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingIdx), "\");
    popPsthData = load(strcat(MatRootPath, "popData_RawPsthAndFFT.mat"));
    % load Params Setting
    protStrLong = SettingParams(SettingIdx);
    proTemp = strsplit(protStrLong, "_");
    protStrShort = proTemp{2};
    MSTIParams = MLA_ParseMSTIParams(protStrLong);
    parseStruct(MSTIParams);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Data cleaning %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %get artificial screen idx
    if exist(strcat(MatRootPath, "ArtificialExcludeCell.xlsx"), "file") ~= 0 && ArtificialSortChoose
        ArtificialSortInfoPath = strcat(MatRootPath, "ArtificialExcludeCell.xlsx");
        ArtificialSortIdx = MSTI.tool.ArtificialScreenCell(popPsthData.PsthData, ArtificialSortInfoPath);
        AllExcludeIdx = ArtificialSortIdx;
    else
        AllExcludeIdx = [];
    end
    popPsthData.PsthData(AllExcludeIdx) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ACIdx = find(matches(string({popPsthData.PsthData.Area}), "AC"))';
    MGBIdx = find(matches(string({popPsthData.PsthData.Area}), "MGB"))';
    for trialTypeIdx = 1 : numel(popPsthData.PsthData(1).rawPsth)
        ACRawPsthTemp{trialTypeIdx} = cellfun(@(x) x(trialTypeIdx).RawPsth, {popPsthData.PsthData(ACIdx).rawPsth}', "UniformOutput", false);
        MGBRawPsthTemp{trialTypeIdx} = cellfun(@(x) x(trialTypeIdx).RawPsth, {popPsthData.PsthData(MGBIdx).rawPsth}', "UniformOutput", false);

        ACMeanFFTPsthTemp{trialTypeIdx} = cellfun(@(x) x(trialTypeIdx).MeanFFTPsth, {popPsthData.PsthData(ACIdx).fftPsth}', "UniformOutput", false);
        MGBMeanFFTPsthTemp{trialTypeIdx} = cellfun(@(x) x(trialTypeIdx).MeanFFTPsth, {popPsthData.PsthData(MGBIdx).fftPsth}', "UniformOutput", false);
    end

    for trialTypeIdx = 1 : numel(popPsthData.PsthData(1).rawPsth)
        trialTypeStr = popPsthData.PsthData(1).rawPsth(trialTypeIdx).Trialtype;
        ICIStr = strrep(MMNcompare(trialTypeIdx).sound, "Std", "ICI");
        ICIStdTrial_Idx = MMNcompare(trialTypeIdx).StdOrder_Lagidx;
        ICIDevTrial_Idx = MMNcompare(trialTypeIdx).DevOrder;

        %%%%%%%%%%%%%%%%%%%%%%%%% AC: 1(S 1,T 1) 3(S 1, T 2) 5(S 2, T 1) 7(S 2, T 2)
        RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, 1) = mSubplot(RowNum, ColNum, 2 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum, [3, 1]);
        X = ACRawPsthTemp{trialTypeIdx}{1}(:, 1)';% Time
        Y_AC = cell2mat(cellfun(@(x) x(:, 2), ACRawPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% Firing Rate
        MeanY_AC = mean(Y_AC);
        SeY_AC = std(Y_AC)/sqrt(size(Y_AC, 1));
        plot(X, Y_AC, 'Color', "#CCCCCC"); hold on;
        fill([X, fliplr(X)], [MeanY_AC + SeY_AC, fliplr(MeanY_AC - SeY_AC)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on; 
        plot(X, MeanY_AC, 'r', "LineWidth", 1); hold on;
        if trialTypeIdx == 1
            title(strcat(protStrShort, " | AC: ", string(length(ACIdx))));
        end

        FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, 1) = mSubplot(RowNum, ColNum, 2 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 2, [1, 1]);
        fftX = ACMeanFFTPsthTemp{trialTypeIdx}{1}(:, 1)';
        fftY_AC = cell2mat(cellfun(@(x) x(:, 2), ACMeanFFTPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% FFTPsth
        MeanfftY_AC = mean(fftY_AC);
        SefftY_AC = std(fftY_AC)/sqrt(size(fftY_AC, 1));
        fill([fftX, fliplr(fftX)], [MeanfftY_AC + SefftY_AC, fliplr(MeanfftY_AC - SefftY_AC)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on; 
        plot(fftX, MeanfftY_AC, 'k', "LineWidth", 1); hold on;
        xlim([1000/max(BaseICI, [], "all") - 10, 1000/min(BaseICI, [], "all") + 10]);

        FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, 2) = mSubplot(RowNum, ColNum, 2 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 3, [1, 1]);
        fftX = ACMeanFFTPsthTemp{trialTypeIdx}{1}(:, 1)';
        fftY_AC = cell2mat(cellfun(@(x) x(:, 2), ACMeanFFTPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% FFTPsth
        MeanfftY_AC = mean(fftY_AC);
        SefftY_AC = std(fftY_AC)/sqrt(size(fftY_AC, 1));
        fill([fftX, fliplr(fftX)], [MeanfftY_AC + SefftY_AC, fliplr(MeanfftY_AC - SefftY_AC)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on; 
        plot(fftX, MeanfftY_AC, 'k', "LineWidth", 1); hold on;
        xlim([0, 8]);

        CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, 1) = mSubplot(RowNum, ColNum, 2 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 4, [1, 1]);
        cmpX_StdLag = ACRawPsthTemp{ICIStdTrial_Idx}{1}(:, 1)' + diff(MSTIsoundinfo(ICIStdTrial_Idx).Std_Dev_Onset(end - 1:end));% Time
        cmpMeanY_AC_Std = mean(cell2mat(cellfun(@(x) x(:, 2), ACRawPsthTemp{ICIStdTrial_Idx}, "UniformOutput", false)')');% Firing Rate
        cmpSeY_AC_Std = std(cell2mat(cellfun(@(x) x(:, 2), ACRawPsthTemp{ICIStdTrial_Idx}, "UniformOutput", false)')')./sqrt(size(ACRawPsthTemp{ICIStdTrial_Idx}, 1));% Firing Rate        
        cmpMeanY_AC_Dev = mean(cell2mat(cellfun(@(x) x(:, 2), ACRawPsthTemp{ICIDevTrial_Idx}, "UniformOutput", false)')');% Firing Rate
        cmpSeY_AC_Dev = std(cell2mat(cellfun(@(x) x(:, 2), ACRawPsthTemp{ICIDevTrial_Idx}, "UniformOutput", false)')')./sqrt(size(ACRawPsthTemp{ICIDevTrial_Idx}, 1));% Firing Rate        
        fill([cmpX_StdLag, fliplr(cmpX_StdLag)], [cmpMeanY_AC_Std + cmpSeY_AC_Std, fliplr(cmpMeanY_AC_Std - cmpSeY_AC_Std)], [153, 204, 255]./255, 'LineStyle', 'none'); hold on;       
        plot(cmpX_StdLag, cmpMeanY_AC_Std, 'b', "LineWidth", 1); hold on;
        fill([X, fliplr(X)], [cmpMeanY_AC_Dev + cmpSeY_AC_Dev, fliplr(cmpMeanY_AC_Dev - cmpSeY_AC_Dev)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on;               
        plot(X, cmpMeanY_AC_Dev, 'r', "LineWidth", 1); hold on;        

        %%%%%%%%%%%%%%%%%%%%%%%%% MGB: 2(S 1,T 1) 4(S 1, T 2) 6(S 2, T 1) 8(S 2, T 2)
        RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, 2) = mSubplot(RowNum, ColNum, 9 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum, [3, 1]);
        X = MGBRawPsthTemp{trialTypeIdx}{1}(:, 1)';% Time
        Y_MGB = cell2mat(cellfun(@(x) x(:, 2), MGBRawPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% Firing Rate
        MeanY_MGB = mean(Y_MGB);
        SeY_MGB = std(Y_MGB)/sqrt(size(Y_MGB, 1));
        plot(X, Y_MGB, 'Color', "#CCCCCC"); hold on;
        fill([X, fliplr(X)], [MeanY_MGB + SeY_MGB, fliplr(MeanY_MGB - SeY_MGB)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on; 
        plot(X, MeanY_MGB, 'r', "LineWidth", 1); hold on;
        if trialTypeIdx == 1
            title(strcat(protStrShort, " | MGB: ", string(length(MGBIdx))));
        end

        FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, 3) = mSubplot(RowNum, ColNum, 9 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 2, [1, 1]);
        fftX = MGBMeanFFTPsthTemp{trialTypeIdx}{1}(:, 1)';
        fftY_MGB = cell2mat(cellfun(@(x) x(:, 2), MGBMeanFFTPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% FFTPsth
        MeanfftY_MGB = mean(fftY_MGB);
        SefftY_MGB = std(fftY_MGB)/sqrt(size(fftY_MGB, 1));
        fill([fftX, fliplr(fftX)], [MeanfftY_MGB + SefftY_MGB, fliplr(MeanfftY_MGB - SefftY_MGB)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on; 
        plot(fftX, MeanfftY_MGB, 'k', "LineWidth", 1); hold on;
        xlim([1000/max(BaseICI, [], "all") - 10, 1000/min(BaseICI, [], "all") + 10]);

        FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, 4) = mSubplot(RowNum, ColNum, 9 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 3, [1, 1]);
        fftX = MGBMeanFFTPsthTemp{trialTypeIdx}{1}(:, 1)';
        fftY_MGB = cell2mat(cellfun(@(x) x(:, 2), MGBMeanFFTPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% FFTPsth
        MeanfftY_MGB = mean(fftY_MGB);
        SefftY_MGB = std(fftY_MGB)/sqrt(size(fftY_MGB, 1));
        fill([fftX, fliplr(fftX)], [MeanfftY_MGB + SefftY_MGB, fliplr(MeanfftY_MGB - SefftY_MGB)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on; 
        plot(fftX, MeanfftY_MGB, 'k', "LineWidth", 1); hold on;
        xlim([0, 8]);

        CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, 2) = mSubplot(RowNum, ColNum, 9 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 4, [1, 1]);
        cmpX_StdLag = MGBRawPsthTemp{ICIStdTrial_Idx}{1}(:, 1)' + diff(MSTIsoundinfo(ICIStdTrial_Idx).Std_Dev_Onset(end - 1:end));% Time
        cmpMeanY_MGB_Std = mean(cell2mat(cellfun(@(x) x(:, 2), MGBRawPsthTemp{ICIStdTrial_Idx}, "UniformOutput", false)')');% Firing Rate
        cmpSeY_MGB_Std = std(cell2mat(cellfun(@(x) x(:, 2), MGBRawPsthTemp{ICIStdTrial_Idx}, "UniformOutput", false)')')./sqrt(size(MGBRawPsthTemp{ICIStdTrial_Idx}, 1));% Firing Rate        
        cmpMeanY_MGB_Dev = mean(cell2mat(cellfun(@(x) x(:, 2), MGBRawPsthTemp{ICIDevTrial_Idx}, "UniformOutput", false)')');% Firing Rate
        cmpSeY_MGB_Dev = std(cell2mat(cellfun(@(x) x(:, 2), MGBRawPsthTemp{ICIDevTrial_Idx}, "UniformOutput", false)')')./sqrt(size(MGBRawPsthTemp{ICIDevTrial_Idx}, 1));% Firing Rate        
        fill([cmpX_StdLag, fliplr(cmpX_StdLag)], [cmpMeanY_MGB_Std + cmpSeY_MGB_Std, fliplr(cmpMeanY_MGB_Std - cmpSeY_MGB_Std)], [153, 204, 255]./255, 'LineStyle', 'none'); hold on;       
        plot(cmpX_StdLag, cmpMeanY_MGB_Std, 'b', "LineWidth", 1); hold on;
        fill([X, fliplr(X)], [cmpMeanY_MGB_Dev + cmpSeY_MGB_Dev, fliplr(cmpMeanY_MGB_Dev - cmpSeY_MGB_Dev)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on;                       
        plot(X, cmpMeanY_MGB_Dev, 'r', "LineWidth", 1); hold on;    

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        scaleAxes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "y", [min([MeanY_AC - SeY_AC; MeanY_MGB - SeY_MGB], [], "all") - 5,...
            max([MeanY_AC + SeY_AC; MeanY_MGB + SeY_MGB], [], "all") + 5]);
        scaleAxes(CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "y", "on");
        scaleAxes(FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, [1,3]), "y", "on");
        scaleAxes(FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, [2,4]), "y", [0, 10]);        
        scaleAxes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "x", plotWin);
        scaleAxes(CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "x", compareWin);
        for lineNum = 1 : numel(MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset)
            timelines(lineNum).X = MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset(lineNum) - MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset(end);
            timelines(lineNum).color = 'k';
        end
        fftlines(1).X = 3.3; fftlines(1).color = 'k';
        fftlines(2).X = 1000/BaseICI(trialTypeIdx, 1); fftlines(2).color = 'k';
        fftlines(3).X = 1000/BaseICI(trialTypeIdx, 2); fftlines(3).color = 'k';
        addLines2Axes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), timelines);
        addLines2Axes(FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, [1,3]), fftlines(2:3));
        addLines2Axes(FFTAxes(2 * (SettingIdx - 1) + trialTypeIdx, [2,4]), fftlines(1));

        %% sig test  
        % fft peak
        InterestFreq = [1000 ./ [BaseICI(trialTypeIdx, 1) BaseICI(trialTypeIdx, 2)], 1000/300];% Background and StdICI
        [~, ACAmp] = cellfun(@(x) MSTI.tool.calFFTAmp(InterestFreq, x(:, 2), x(:, 1)), ACMeanFFTPsthTemp{trialTypeIdx}, "UniformOutput", false);
        [~, MGBAmp] = cellfun(@(x) MSTI.tool.calFFTAmp(InterestFreq, x(:, 2), x(:, 1)), MGBMeanFFTPsthTemp{trialTypeIdx}, "UniformOutput", false);       
        for InterestfreqNum = 1 : numel(InterestFreq)
            TestData(InterestfreqNum).InterestFreq = InterestFreq(InterestfreqNum);
            %AC
            TestData(InterestfreqNum).ACData = cell2mat(cellfun(@(x) [x{2 * InterestfreqNum - 1, 1}(1), x{2 * InterestfreqNum, 1}(1)], ACAmp, "UniformOutput", false));% target VS baseline
            ACTargetAmp = TestData(InterestfreqNum).ACData(:, 1);
            ACBaselineAmp = TestData(InterestfreqNum).ACData(:, 2);
            [FFT_h_AC, FFT_p_AC] = ttest(ACTargetAmp - ACBaselineAmp, 0, 'Tail', 'right');
            TestData(InterestfreqNum).ACsig = FFT_h_AC;
            TestData(InterestfreqNum).ACpvalue = FFT_p_AC;
            %MGB
            TestData(InterestfreqNum).MGBData = cell2mat(cellfun(@(x) [x{2 * InterestfreqNum - 1, 1}(1), x{2 * InterestfreqNum, 1}(1)], MGBAmp, "UniformOutput", false));% target VS baseline
            MGBTargetAmp = TestData(InterestfreqNum).MGBData(:, 1);
            MGBBaselineAmp = TestData(InterestfreqNum).MGBData(:, 2);
            [FFT_h_MGB, FFT_p_MGB] = ttest(MGBTargetAmp - MGBBaselineAmp, 0, 'Tail', 'right');
            TestData(InterestfreqNum).MGBsig = FFT_h_MGB;
            TestData(InterestfreqNum).MGBpvalue = FFT_p_MGB;
        end
        TrialTestData(trialTypeIdx).TrialType = trialTypeStr;
        TrialTestData(trialTypeIdx).TestResult = TestData;
        Fig7_SigTestRes.Protocol = protStrShort;
        Fig7_SigTestRes.FFTSigTestResult = TrialTestData;
        % compare raw psth
        PsthTestWin_Dev = [0,SigTestWinLength];
        tIdx_Dev = find(X > PsthTestWin_Dev(1) & X < PsthTestWin_Dev(2))';
        FindStdLastStdOnset = MSTIsoundinfo(ICIStdTrial_Idx).Std_Dev_Onset(end - 1) - MSTIsoundinfo(ICIStdTrial_Idx).Std_Dev_Onset(end);
        PsthTestWin_Std = [FindStdLastStdOnset, FindStdLastStdOnset + SigTestWinLength];
        tIdx_Std = find(X > PsthTestWin_Std(1) & X < PsthTestWin_Std(2))';
        %AC
        ACCellStdTemp = mean(cell2mat(cellfun(@(x) x(tIdx_Std, 2), ACRawPsthTemp{ICIStdTrial_Idx}, "UniformOutput", false)'));
        ACCellDevTemp = mean(cell2mat(cellfun(@(x) x(tIdx_Dev, 2), ACRawPsthTemp{ICIDevTrial_Idx}, "UniformOutput", false)'));
        [Psth_h_AC(trialTypeIdx), Psth_p_AC(trialTypeIdx)] = ttest(ACCellDevTemp - ACCellStdTemp, 0, "Tail", "right");
        %MGB
        MGBCellStdTemp = mean(cell2mat(cellfun(@(x) x(tIdx_Std, 2), MGBRawPsthTemp{ICIStdTrial_Idx}, "UniformOutput", false)'));
        MGBCellDevTemp = mean(cell2mat(cellfun(@(x) x(tIdx_Dev, 2), MGBRawPsthTemp{ICIDevTrial_Idx}, "UniformOutput", false)'));
        [Psth_h_MGB(trialTypeIdx), Psth_p_MGB(trialTypeIdx)] = ttest(MGBCellDevTemp - MGBCellStdTemp, 0, "Tail", "right");
        Fig7_SigTestRes.PsthSigTestResult(trialTypeIdx).trialType = trialTypeStr;
        Fig7_SigTestRes.PsthSigTestResult(trialTypeIdx).AC = [Psth_h_AC(trialTypeIdx), Psth_p_AC(trialTypeIdx)];
        Fig7_SigTestRes.PsthSigTestResult(trialTypeIdx).MGB = [Psth_h_MGB(trialTypeIdx), Psth_p_MGB(trialTypeIdx)];        


        %% CDR plot
        if exist("ArtificialSortIdx", "var") && ArtificialSortChoose
            CdrPlot_Fig7popPsth.ExcludeInfo{1, 1} = ArtificialSortIdx;
            CdrPlot_Fig7popPsth.ExcludeInfo{1, 2} = "Artificial screen";            
        end
        CdrPlot_Fig7popPsth.AC(trialTypeIdx).trialType = trialTypeStr;
        CdrPlot_Fig7popPsth.AC(trialTypeIdx).popPSTH = [X', Y_AC'];
        CdrPlot_Fig7popPsth.AC(trialTypeIdx).MeanSePSTH = [X', MeanY_AC', X', MeanY_AC' + SeY_AC', X', MeanY_AC'- SeY_AC', SeY_AC'];
        CdrPlot_Fig7popPsth.AC(trialTypeIdx).CmpMeanSePSTH.BlueStd = [cmpX_StdLag', cmpMeanY_AC_Std', cmpX_StdLag', cmpMeanY_AC_Std' + cmpSeY_AC_Std', cmpX_StdLag', cmpMeanY_AC_Std' - cmpSeY_AC_Std', cmpSeY_AC_Std'];
        CdrPlot_Fig7popPsth.AC(trialTypeIdx).CmpMeanSePSTH.RedDev = [X', cmpMeanY_AC_Dev', X', cmpMeanY_AC_Dev' + cmpSeY_AC_Dev', X', cmpMeanY_AC_Dev' - cmpSeY_AC_Dev', cmpSeY_AC_Dev'];        
        CdrPlot_Fig7popPsth.AC(trialTypeIdx).MeanSeFFTPSTH = [fftX', MeanfftY_AC', fftX', MeanfftY_AC' + SefftY_AC', fftX', MeanfftY_AC'- SefftY_AC', SefftY_AC'];
        
        CdrPlot_Fig7popPsth.MGB(trialTypeIdx).trialType = trialTypeStr;
        CdrPlot_Fig7popPsth.MGB(trialTypeIdx).popPSTH = [X', Y_MGB'];
        CdrPlot_Fig7popPsth.MGB(trialTypeIdx).MeanSePSTH = [X', MeanY_MGB', X', MeanY_MGB' + SeY_MGB', X', MeanY_MGB'- SeY_MGB', SeY_MGB'];
        CdrPlot_Fig7popPsth.MGB(trialTypeIdx).CmpMeanSePSTH.BlueStd = [cmpX_StdLag', cmpMeanY_MGB_Std', cmpX_StdLag', cmpMeanY_MGB_Std' + cmpSeY_MGB_Std', cmpX_StdLag', cmpMeanY_MGB_Std' - cmpSeY_MGB_Std', cmpSeY_MGB_Std'];
        CdrPlot_Fig7popPsth.MGB(trialTypeIdx).CmpMeanSePSTH.RedDev = [X', cmpMeanY_MGB_Dev', X', cmpMeanY_MGB_Dev' + cmpSeY_MGB_Dev', X', cmpMeanY_MGB_Dev' - cmpSeY_MGB_Dev', cmpSeY_MGB_Dev']; 
        CdrPlot_Fig7popPsth.MGB(trialTypeIdx).MeanSeFFTPSTH = [fftX', MeanfftY_MGB', fftX', MeanfftY_MGB' + SefftY_MGB', fftX', MeanfftY_MGB'- SefftY_MGB', SefftY_MGB'];

    end
    CdrPlot_Fig7popPsth.Protocol = protStrShort;
    save(strcat(MatRootPath, "CdrPlot_Fig7popPsth.mat"), "CdrPlot_Fig7popPsth", "-mat");
    save(strcat(MatRootPath, "CdrPlot_Fig7SigTestRes.mat"), "Fig7_SigTestRes", "-mat");

end
% Plot Settings
set(RawAxes(1 : 3, :), 'xtick', []);





