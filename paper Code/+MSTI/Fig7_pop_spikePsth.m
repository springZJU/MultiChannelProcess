clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];

%% Plot
% Fig = figure;
% maximizeFig(Fig);
RowNum = 4;
ColNum = 9;

for SettingIdx = 1 : numel(SettingParams)
    clear popRawPsthData;
    % load spkRes.mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingIdx), "\");
    popRawPsthData = load(strcat(MatRootPath, "popData_RawPsth.mat"));
    % load Params Setting
    protStrLong = SettingParams(SettingIdx);
    proTemp = strsplit(protStrLong, "_");
    protStrShort = proTemp{2};
    MSTIParams = MLA_ParseMSTIParams(protStrLong);
    parseStruct(MSTIParams);

    ACIdx = find(matches(string({popRawPsthData.PsthData.AreaInfo}), "AC"))';
    MGBIdx = find(matches(string({popRawPsthData.PsthData.AreaInfo}), "MGB"))';
    for trialTypeIdx = 1 : numel(popRawPsthData.PsthData(1).rawPsth)
        ACTemp{trialTypeIdx} = cellfun(@(x) x(trialTypeIdx).RawPsth, {popRawPsthData.PsthData(ACIdx).rawPsth}', "UniformOutput", false);
        MGBTemp{trialTypeIdx} = cellfun(@(x) x(trialTypeIdx).RawPsth, {popRawPsthData.PsthData(MGBIdx).rawPsth}', "UniformOutput", false);
    end

    for trialTypeIdx = 1 : numel(popRawPsthData.PsthData(1).rawPsth)

        ICIStr = strrep(MMNcompare(trialTypeIdx).sound, "Std", "ICI");
        ICIStdTrial_Idx = MMNcompare(trialTypeIdx).StdOrder_Lagidx;
        ICIDevTrial_Idx = MMNcompare(trialTypeIdx).DevOrder;

        %AC: 1(S 1,T 1) 3(S 1, T 2) 5(S 2, T 1) 7(S 2, T 2)
        RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, 1) = mSubplot(RowNum, ColNum, 2 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum, [3, 1]);
        X = ACTemp{trialTypeIdx}{1}(:, 1)';% Time
        Y_AC = cellfun(@(x) x(:, 2), ACTemp{trialTypeIdx}, "UniformOutput", false)';% Firing Rate
        plot(X, cell2mat(Y_AC)', 'Color', "#CCCCCC"); hold on;
        plot(X, mean(cell2mat(Y_AC)'), 'r', "LineWidth", 2); hold on;
        if trialTypeIdx == 1
            title(strcat(protStrShort, " | AC: ", string(length(ACIdx))));
        end
        CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, 1) = mSubplot(RowNum, ColNum, 2 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 2, [1, 1]);
        cmpX_StdLag = ACTemp{ICIStdTrial_Idx}{1}(:, 1)' + diff(MSTIsoundinfo(ICIStdTrial_Idx).Std_Dev_Onset(end - 1:end));% Time
        cmpY_AC_Std = cellfun(@(x) x(:, 2), ACTemp{ICIStdTrial_Idx}, "UniformOutput", false)';% Firing Rate
        cmpY_AC_Dev = cellfun(@(x) x(:, 2), ACTemp{ICIDevTrial_Idx}, "UniformOutput", false)';% Firing Rate
        plot(cmpX_StdLag, mean(cell2mat(cmpY_AC_Std)'), 'b', "LineWidth", 2); hold on;
        plot(X, mean(cell2mat(cmpY_AC_Dev)'), 'r', "LineWidth", 2); hold on;        

        %MGB: 2(S 1,T 1) 4(S 1, T 2) 6(S 2, T 1) 8(S 2, T 2)
        RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, 2) = mSubplot(RowNum, ColNum, 7 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum, [3, 1]);
        X = MGBTemp{trialTypeIdx}{1}(:, 1)';% Time
        Y_MGB = cellfun(@(x) x(:, 2), MGBTemp{trialTypeIdx}, "UniformOutput", false)';% Firing Rate
        plot(X, cell2mat(Y_MGB)', 'Color', "#CCCCCC"); hold on;
        plot(X, mean(cell2mat(Y_MGB)'), 'r', "LineWidth", 2); hold on; 
        if trialTypeIdx == 1
            title(strcat(protStrShort, " | MGB: ", string(length(MGBIdx))));
        end
        CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, 2) = mSubplot(RowNum, ColNum, 7 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum + 2, [1, 1]);
        cmpX_StdLag = MGBTemp{ICIStdTrial_Idx}{1}(:, 1)' + diff(MSTIsoundinfo(ICIStdTrial_Idx).Std_Dev_Onset(end - 1:end));% Time
        cmpY_MGB_Std = cellfun(@(x) x(:, 2), MGBTemp{ICIStdTrial_Idx}, "UniformOutput", false)';% Firing Rate
        cmpY_MGB_Dev = cellfun(@(x) x(:, 2), MGBTemp{ICIDevTrial_Idx}, "UniformOutput", false)';% Firing Rate
        plot(cmpX_StdLag, mean(cell2mat(cmpY_MGB_Std)'), 'b', "LineWidth", 2); hold on;
        plot(X, mean(cell2mat(cmpY_MGB_Dev)'), 'r', "LineWidth", 2); hold on;     

        scaleAxes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "y", [0, max([mean(cell2mat(Y_AC)'); mean(cell2mat(Y_MGB)')], [], "all") + 5]);
        scaleAxes(CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "y", "on");
        scaleAxes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "x", plotWin);
        scaleAxes(CompareAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), "x", compareWin);
        for lineNum = 1 : numel(MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset)
            lines(lineNum).X = MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset(lineNum) - MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset(end);
            lines(lineNum).color = 'k';
        end
        addLines2Axes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx, :), lines);
    end

end

%% Plot Settings
set(RawAxes(1 : 3, :), 'xtick', []);





