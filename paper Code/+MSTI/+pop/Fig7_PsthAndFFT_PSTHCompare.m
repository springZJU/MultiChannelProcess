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
CM_ExcludeShank = [{["A40R16"]}, {["A44R31"]}]; % First for AC Shank, Second for MGB Shank
ArtificialSortChoose = true;
SigTestWinLength = 300;%ms

%% Plot
Fig = figure;
maximizeFig(Fig);
RowNum = 4;
ColNum = 4;

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
    if exist(strcat(MatRootPath, CommentTable), "file") ~= 0 && ArtificialSortChoose
        SortInfoPath = strcat(MatRootPath, CommentTable);
        SortIdx = MSTI.tool.CommentTableScreenCell(popPsthData.PsthData, SortInfoPath);
        AllExcludeIdx = SortIdx;
    elseif ~ArtificialSortChoose
        AllExcludeIdx = [];
    end

    popPsthData.PsthData(AllExcludeIdx) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ACIdx = find(matches(string({popPsthData.PsthData.Area}), "AC")' & ...
        ~ismember(string({popPsthData.PsthData.Position})', DDZ_ExcludeShank{1}) & ...
        ~ismember(string({popPsthData.PsthData.Position})', CM_ExcludeShank{1}));
    MGBIdx = find(matches(string({popPsthData.PsthData.Area}), "MGB")' & ...
        ~ismember(string({popPsthData.PsthData.Position})', DDZ_ExcludeShank{2}) & ...
        ~ismember(string({popPsthData.PsthData.Position})', CM_ExcludeShank{2}));
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
        RawAxes(2 * (SettingIdx - 1) + trialTypeIdx) = mSubplot(RowNum, ColNum, 2 + (2 * (SettingIdx - 1) + trialTypeIdx - 1) * ColNum, [3, 1]);
        X = ACRawPsthTemp{trialTypeIdx}{1}(:, 1)';% Time
        Y_AC = cell2mat(cellfun(@(x) x(:, 2), ACRawPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% Firing Rate
        MeanY_AC = mean(Y_AC);
        SeY_AC = std(Y_AC)/sqrt(size(Y_AC, 1));
        fill([X, fliplr(X)], [MeanY_AC + SeY_AC, fliplr(MeanY_AC - SeY_AC)], [255, 204, 204]./255, 'LineStyle', 'none'); hold on; 
        plot(X, MeanY_AC, 'r', "LineWidth", 1); hold on;    

        %%%%%%%%%%%%%%%%%%%%%%%%% MGB: 2(S 1,T 1) 4(S 1, T 2) 6(S 2, T 1) 8(S 2, T 2)
        X = MGBRawPsthTemp{trialTypeIdx}{1}(:, 1)';% Time
        Y_MGB = cell2mat(cellfun(@(x) x(:, 2), MGBRawPsthTemp{trialTypeIdx}, "UniformOutput", false)')';% Firing Rate
        MeanY_MGB = mean(Y_MGB);
        SeY_MGB = std(Y_MGB)/sqrt(size(Y_MGB, 1));
        fill([X, fliplr(X)], [MeanY_MGB + SeY_MGB, fliplr(MeanY_MGB - SeY_MGB)], [153, 204, 255]./255, 'LineStyle', 'none'); hold on; 
        plot(X, MeanY_MGB, 'b', "LineWidth", 1); hold on;

        title(strcat(trialTypeStr, " | AC: ", string(length(ACIdx)), " MGB: ", string(length(MGBIdx))));   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        scaleAxes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx), "y", [min([MeanY_AC - SeY_AC; MeanY_MGB - SeY_MGB], [], "all") - 5,...
            max([MeanY_AC + SeY_AC; MeanY_MGB + SeY_MGB], [], "all") + 5]);
        scaleAxes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx), "x", plotWin);
        for lineNum = 1 : numel(MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset)
            timelines(lineNum).X = MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset(lineNum) - MSTIsoundinfo(trialTypeIdx).Std_Dev_Onset(end);
            timelines(lineNum).color = 'k';
        end
        addLines2Axes(RawAxes(2 * (SettingIdx - 1) + trialTypeIdx), timelines);

    end

end
% Plot Settings
set(RawAxes(1, 1:3), 'xtick', []);
% print(gcf, strcat(DataRootPath, "MSTIFig7Cmp_AC_MGB_population.jpg"), "-djpeg", "-r200");
% close;






