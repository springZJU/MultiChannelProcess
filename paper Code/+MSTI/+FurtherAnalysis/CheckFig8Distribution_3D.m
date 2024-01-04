clear; clc;

params.DataRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\Figure\MSTI_Recording2\";

if strcmp(params.DataRootPath, "H:\MLA_A1补充\Figure\CTL_New\") || contains(params.DataRootPath, "Recording1")
    params.SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                    "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
elseif strcmp(params.DataRootPath, "H:\MLA_A1补充\Figure\CTL_New_补充\") || contains(params.DataRootPath, "Recording2")
    params.SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];
end
params.CommentTable = "2023-12-12CommentTable.xlsx";

params.MonkeyName = "cm"; % "cm", "ddz"
params.Area = "MGB"; % "AC", "MGB"
params.CheckContent = "CSI"; % "ClickFFT", "ClickTrainFFT", "CSI"
params.Indicator = "Mean"; % "Median", "Mean"
params.ArtificialSortChoose = true;
params.PlotTypes = ["Scatter"]; % "Scatter", "Surf"

Son_CheckFig8Distribution(params);

%% 
function Son_CheckFig8Distribution(params)
    parseStruct(params);
    path = strsplit(string(fullfile(mfilename("fullpath"))), "\");
    depthInfo = table2struct(readtable(fullfile(join(path(1:end-2), "\"), "depthInfo.xlsx")));
    depthInfo = depthInfo(contains(string({depthInfo.Animal})', MonkeyName) & contains(string({depthInfo.Area})', Area));
    for PlotTypeIdx = 1 : numel(PlotTypes) 
        PlotType = PlotTypes(PlotTypeIdx);
        Fig = figure;
        maximizeFig(Fig);
        for SettingParamIdx = 1 : numel(SettingParams)
            clear PsthFFTAmpTemp PsthCSITemp CdrPlot_Fig8popDistribution
            proStrLong = SettingParams(SettingParamIdx);
            temp = strsplit(proStrLong, "_");
            proStrShort = string(temp{2});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%% load .mat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%% classifying data %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % for monkey
            PsthFFTAmpTemp.PsthFFTAmpData(~contains(string({PsthFFTAmpTemp.PsthFFTAmpData.Date})', MonkeyName)) = [];
            PsthCSITemp.PsthCSIData(~contains(string({PsthCSITemp.PsthCSIData.Date})', MonkeyName)) = [];        
            % for area and content
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% choose dataset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if contains(CheckContent, "FFT")
                eval(strcat("DataTemp = ", Area, "PsthFFTDataTemp"));
            elseif contains(CheckContent, "CSI")
                eval(strcat("DataTemp = ", Area, "CSIDataTemp"));
%                 DataTemp = DataTemp([DataTemp.CSI]' < 0.03);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ShankInfo = unique(string({DataTemp.Position})');
            ShankNum = 0;Shank = [];
            for ShankIdx = 1 : numel(ShankInfo)
                ShankNum = ShankNum + 1;
                Shank(ShankNum).Strs = ShankInfo(ShankIdx);
                Shank(ShankNum).Position(1, 1) = double(string(regexpi(Shank(ShankNum).Strs, 'A(\d*)', 'tokens')));
                Shank(ShankNum).Position(1, 2) = double(string(regexpi(Shank(ShankNum).Strs, 'R(\d*)', 'tokens')));
                TargetShankIdxs = contains(string({DataTemp.Position})', ShankInfo(ShankIdx));
                Shank(ShankNum).Value(:, 1) = [DataTemp(TargetShankIdxs).(CheckContent)]';
                Shank(ShankNum).Value(:, 2) = mod(double(strrep(string({DataTemp(TargetShankIdxs).ID})', 'CH', '')), 1000);
                ChannelDepth = calDepth(Shank(ShankNum).Strs, depthInfo);
                Shank(ShankNum).Value(:, 3) = ChannelDepth(rowFcn(@(x) find(x == ChannelDepth(:, 1)), Shank(ShankNum).Value(:, 2)), 2);
                Shank(ShankNum).Median = median(Shank(ShankNum).Value(:, 1)');
                Shank(ShankNum).Mean = mean(Shank(ShankNum).Value(:, 1)');
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            params.SettingParamIdx = SettingParamIdx;
            params.proStrShort = proStrShort;
            if strcmp(PlotType, "Scatter")
                GrandSon_CheckFig8Distribution_PlotScatter(params, Shank);
            elseif strcmp(PlotType, "Surf")
                GrandSon_CheckFig8Distribution_PlotSurf(params, Shank);
            end
        end
        print(Fig, strcat(params.DataRootPath, "Monkey", MonkeyName, "_", Area, "_", CheckContent, ".jpg"), "-djpeg", "-r200");
    end
end

%%
function GrandSon_CheckFig8Distribution_PlotScatter(params, Shank)
    parseStruct(params);
    subplot(1, 2, SettingParamIdx);
    ShankNum = 0;
    Cmap = colormap("jet");
    for ShankIdx = 1 : numel(Shank)
        ShankNum = ShankNum + 1;
        XValue{ShankIdx, 1} = repmat(Shank(ShankNum).Position(1, 1), [numel(Shank(ShankNum).Value(:, 1)), 1]); % A
        YValue{ShankIdx, 1} = repmat(Shank(ShankNum).Position(1, 2), [numel(Shank(ShankNum).Value(:, 1)), 1]); % R
        [sortCValue, sortIdx] = sort(Shank(ShankNum).Value(:, 1), 1, "ascend");
        interpCValue = interp1(1:numel(sortCValue), sortCValue, linspace(1, numel(sortCValue), size(Cmap, 1)))';
        [~, ColorIdx] = cellfun(@(y) min(abs(y)), rowFcn(@(x) interpCValue - x, sortCValue, "UniformOutput", false));
        ZValue{ShankIdx, 1} = Shank(ShankNum).Value(sortIdx, 3);
        IdxValue{ShankIdx, 1} = Shank(ShankNum).Value(sortIdx, 1);
%         scatter3(XValue{ShankIdx, 1}, YValue{ShankIdx, 1}, ZValue{ShankIdx, 1}, 100, Cmap(ColorIdx, :), "filled"); hold on;
        scatter3(XValue{ShankIdx, 1}, YValue{ShankIdx, 1}, ZValue{ShankIdx, 1}, 100, IdxValue{ShankIdx, 1}, "filled"); hold on;
    end
    Chandle = colorbar;
    set(gca, "ZDir", "reverse");
    annotation('textbox', [.42, .9, .1, .1], 'String', strcat("Monkey: ", MonkeyName, " | ", Area, " | ", CheckContent, "(", Indicator, ")"), 'EdgeColor', 'none', 'FontSize', 15);
    title(proStrShort, "FontSize", 15);
    scaleAxes(gca, "x", [min(cell2mat(XValue)) - 0.5, max(cell2mat(XValue)) + 0.5]);
    scaleAxes(gca, "y", [min(cell2mat(YValue)) - 0.5, max(cell2mat(YValue)) + 0.5]);
    scaleAxes(gca, "c", "on", "cutoffRange", [-0.04, 0.1]);
    xticks(1 : max(cell2mat(XValue)));
    yticks(1 : max(cell2mat(YValue)));
    xlabel("Anterior to Posterior");
    ylabel("Interaural to Lateral");
    zlabel("Deep to Surface");
end
%%
function GrandSon_CheckFig8Distribution_PlotSurf(params, Shank)

    parseStruct(params);
    mSubplot(1, 2, SettingParamIdx);
    ShankNum = 0;
    for ShankIdx = 1 : numel(Shank)
        ShankNum = ShankNum + 1;        
        XValue{ShankIdx, 1} = repmat(Shank(ShankNum).Position(1, 1), [numel(Shank(ShankNum).Value(:, 1)), 1]); % A
        YValue{ShankIdx, 1} = repmat(Shank(ShankNum).Position(1, 2), [numel(Shank(ShankNum).Value(:, 1)), 1]); % R
        ZValue{ShankIdx, 1} = Shank(ShankNum).Value(:, 1);
    end
    [X, Y] = meshgrid(min(cell2mat(XValue)) : max(cell2mat(XValue)), min(cell2mat(YValue)) : max(cell2mat(YValue)));
    Z = zeros(size(X));
    Z(cellfun(@(x) find(x(1) == X & x(2) == Y), {Shank.Position})') = [Shank.(Indicator)]';
    [Xq, Yq] = meshgrid(linspace(min(cell2mat(XValue)), max(cell2mat(XValue))), linspace(min(cell2mat(YValue)), max(cell2mat(YValue))));
    Vq = interp2(X, Y, Z, Xq, Yq);
    surf(Xq, Yq, Vq);

    annotation('textbox', [.42, .9, .1, .1], 'String', strcat("Monkey: ", MonkeyName, " | ", Area, " | ", CheckContent, "(", Indicator, ")"), 'EdgeColor', 'none', 'FontSize', 15);
    title(proStrShort, "FontSize", 15);
    scaleAxes(gca, "x", [min(cell2mat(XValue)) - 0.5, max(cell2mat(XValue)) + 0.5]);
    scaleAxes(gca, "y", [min(cell2mat(YValue)) - 0.5, max(cell2mat(YValue)) + 0.5]);
    xticks(1 : max(cell2mat(XValue)));
    yticks(1 : max(cell2mat(YValue)));
    xlabel("Anterior-Posterior");
    ylabel("Interaural");
    zlabel(strcat(CheckContent, " Value"));
end

%%
function ChannelDepth = calDepth(ShankStr, DepthInfo)
    Deepest = double(string(DepthInfo(contains(string({DepthInfo.Position}), ShankStr)).Depth));
    ChannelNum = double(string(DepthInfo(contains(string({DepthInfo.Position}), ShankStr)).Channel));
    Interval = double(string(DepthInfo(contains(string({DepthInfo.Position}), ShankStr)).Interval));

    for CIdx = 1 : ChannelNum
        ChannelDepth(CIdx, 1) = CIdx;
        ChannelDepth(CIdx, 2) = Deepest - Interval * (ChannelNum - CIdx);
    end
end