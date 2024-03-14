clear; clc;
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
CommentTable = "2023-12-12CommentTable.xlsx";
DDZ_ExcludeShank = [{[""]}, {[""]}]; % First for AC Shank, Second for MGB Shank
CM_ExcludeShank = [{[""]}, {["A44R31"]}]; % First for AC Shank, Second for MGB Shank
ArtificialSortChoose = true;
SelectChoice = "mean"; % "mean", "max", "median"

%% Collect dataset
for MonkeyIdx = 1 : numel(MonkeyNames)
    MonkeyName = MonkeyNames(MonkeyIdx);
    for AreaIdx = 1 : numel(Areas)
        Area = Areas(AreaIdx);
        for SettingParamIdx = 1 : numel(SettingParams)
            clear PsthFFTAmpTemp PsthCSITemp ShanksStr Position CellInfo
            proStrLong = SettingParams(SettingParamIdx);

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
            PsthFFTAmpTemp.PsthFFTAmpData(~contains(string({PsthFFTAmpTemp.PsthFFTAmpData.Date})', MonkeyName)) = [];
            PsthCSITemp.PsthCSIData(~contains(string({PsthCSITemp.PsthCSIData.Date})', MonkeyName)) = [];
            if strcmp(Area, "AC") & strcmp(MonkeyName, "ddz")
                PsthFFTAmpTemp.PsthFFTAmpData(ismember(string({PsthFFTAmpTemp.PsthFFTAmpData.Position})', DDZ_ExcludeShank{1})) = [];
                PsthCSITemp.PsthCSIData(ismember(string({PsthCSITemp.PsthCSIData.Position})', DDZ_ExcludeShank{1})) = [];
               
            elseif strcmp(Area, "AC") & strcmp(MonkeyName, "cm")
                PsthFFTAmpTemp.PsthFFTAmpData(ismember(string({PsthFFTAmpTemp.PsthFFTAmpData.Position})', CM_ExcludeShank{1})) = [];
                PsthCSITemp.PsthCSIData(ismember(string({PsthCSITemp.PsthCSIData.Position})', CM_ExcludeShank{1})) = [];

            elseif strcmp(Area, "MGB") & strcmp(MonkeyName, "ddz")
                PsthFFTAmpTemp.PsthFFTAmpData(ismember(string({PsthFFTAmpTemp.PsthFFTAmpData.Position})', DDZ_ExcludeShank{2})) = [];
                PsthCSITemp.PsthCSIData(ismember(string({PsthCSITemp.PsthCSIData.Position})', DDZ_ExcludeShank{2})) = [];

            elseif strcmp(Area, "MGB") & strcmp(MonkeyName, "cm")
                PsthFFTAmpTemp.PsthFFTAmpData(ismember(string({PsthFFTAmpTemp.PsthFFTAmpData.Position})', CM_ExcludeShank{2})) = [];
                PsthCSITemp.PsthCSIData(ismember(string({PsthCSITemp.PsthCSIData.Position})', CM_ExcludeShank{2})) = [];

            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            Idx = find(strcmp(string({PsthCSITemp.PsthCSIData.Area}), Area))';
            PsthFFTDataTemp = PsthFFTAmpTemp.PsthFFTAmpData(Idx);
            CSIDataTemp = PsthCSITemp.PsthCSIData(Idx);
            Data(SettingParamIdx).protocol = proStrLong;
            ShanksStr = unique(string({PsthFFTDataTemp.Position})');
            Position = cellfun(@(x) [double(x{1}(1)), double(x{1}(2))], regexpi(ShanksStr, 'A(\d*)R(\d*)', 'tokens'), "UniformOutput", false);
            for ShankIdx = 1 : numel(ShanksStr)
                ShankStr = ShanksStr(ShankIdx);
                IDNum = double(string(rowFcn(@(x)regexpi(x, 'CH(\d*)', 'tokens'), string({PsthFFTDataTemp(contains(string({PsthFFTDataTemp.Position})', ShankStr)).ID}'))));
                ClickFFT = [PsthFFTDataTemp(contains(string({PsthFFTDataTemp.Position})', ShankStr)).ClickFFT]';
                ClickTrainFFT = [PsthFFTDataTemp(contains(string({PsthFFTDataTemp.Position})', ShankStr)).ClickTrainFFT]';
                CSI = [CSIDataTemp(contains(string({CSIDataTemp.Position})', ShankStr)).CSI]';
                CellInfo{ShankIdx, 1} = vertcat([IDNum, ClickFFT, ClickTrainFFT, CSI]);

            end
            Data(SettingParamIdx).(strcat(MonkeyName, "_", Area)) = [Position, CellInfo];
        end
    end
end
%% Plot topo
Protocols = {Data.protocol}';
n = 0;
for MonkeyIdx = 1 : numel(MonkeyNames)
    for AreaIdx = 1 : numel(Areas)
        clear DataSet;
        n = n + 1;
        AnimalAndAreaStr = strcat(MonkeyNames(MonkeyIdx), "_", Areas(AreaIdx));
        DataSet.(AnimalAndAreaStr) = {Data.(AnimalAndAreaStr)}';
        PjHorzAndVert = GetPjHorzAndVertInfo(DataSet, Protocols, SelectChoice);
        PjHorzAndVertData(n).Info = AnimalAndAreaStr;
        PjHorzAndVertData(n).Data = PjHorzAndVert;

        PlotPjHorzAndVert(PjHorzAndVert, AnimalAndAreaStr);
    end
end
SAVEPATH = strsplit(string(fullfile(mfilename("fullpath"))), "\");
SAVEPATH = strjoin(SAVEPATH(1:end-1), "\");
save(strcat(SAVEPATH, "\MSTITopo.mat"), "PjHorzAndVertData");
%%
function PjHorzAndVert = GetPjHorzAndVertInfo(DataSet, Protocols, SelectChoice)
    GetfieldNames = fieldnames(DataSet);
    FieldNamesTemp = strsplit(string(GetfieldNames), "_");
    Monkey = string(FieldNamesTemp{1});
    Area = string(FieldNamesTemp{2});
    Temp = DataSet.(string(GetfieldNames));
    for ProtocolIdx = 1 : numel(Protocols)
        clear ProjectData
        ProjectData = Temp{ProtocolIdx};
        % Horz
        for ShankIdx = 1 : size(ProjectData, 1)
            if strcmp(SelectChoice, "mean")
                PjHorz_Click(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = mean(ProjectData{ShankIdx, 2}(:, 2));
                PjHorz_ClickTrain(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = mean(ProjectData{ShankIdx, 2}(:, 3));
                PjHorz_CSI(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = mean(ProjectData{ShankIdx, 2}(:, 4));
            elseif strcmp(SelectChoice, "max")
                PjHorz_Click(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = max(ProjectData{ShankIdx, 2}(:, 2));
                PjHorz_ClickTrain(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = max(ProjectData{ShankIdx, 2}(:, 3));
                PjHorz_CSI(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = max(ProjectData{ShankIdx, 2}(:, 4));
            elseif strcmp(SelectChoice, "median")
                PjHorz_Click(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = median(ProjectData{ShankIdx, 2}(:, 2));
                PjHorz_ClickTrain(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = median(ProjectData{ShankIdx, 2}(:, 3));
                PjHorz_CSI(ProjectData{ShankIdx, 1}(1), ProjectData{ShankIdx, 1}(2)) = median(ProjectData{ShankIdx, 2}(:, 4));
            end      
        end

        % Vert
        AllPositionR = unique(cellfun(@(x) x(2), [ProjectData(:, 1)]));
        SamePositionR_Idxs = rowFcn(@(y) find(ismember(cellfun(@(x) x(2), [ProjectData(:, 1)]), y)), AllPositionR, "UniformOutput", false);
        SamePositionR_Cells = cellfun(@(z) [mod(z(:, 1), 1000), z(:, 2:end)], ...
                                        cellfun(@(y) cell2mat(y), ...
                                        cellfun(@(x) ProjectData(x, 2), SamePositionR_Idxs, ...
                                        "UniformOutput", false), "UniformOutput", false), "UniformOutput", false);
        for PositionRIdx = 1 : numel(AllPositionR)
            clear DepthInfo
            DepthCount = 0;
            Depth = unique(SamePositionR_Cells{PositionRIdx, 1}(:, 1));
            temp = SamePositionR_Cells{PositionRIdx, 1};
            for DepthIdx = 1 : numel(Depth)
                DepthCount = DepthCount + 1;
                if strcmp(SelectChoice, "mean")
                    DepthInfo(DepthCount, :) = mean(temp(ismember(temp(:, 1), Depth(DepthIdx)), :), 1);
                elseif strcmp(SelectChoice, "max")
                    DepthInfo(DepthCount, :) = max(temp(ismember(temp(:, 1), Depth(DepthIdx)), :), 1);
                elseif strcmp(SelectChoice, "median")
                    DepthInfo(DepthCount, :) = median(temp(ismember(temp(:, 1), Depth(DepthIdx)), :), 1);
                end
            end
            PositionR = AllPositionR(PositionRIdx);
            for DepthIdx = 1 : size(DepthInfo, 1)
                PjVert_Click(DepthInfo(DepthIdx, 1), PositionR) = DepthInfo(DepthIdx, 2);
                PjVert_ClickTrain(DepthInfo(DepthIdx, 1), PositionR) = DepthInfo(DepthIdx, 3);
                PjVert_CSI(DepthInfo(DepthIdx, 1), PositionR) = DepthInfo(DepthIdx, 4);
            end
        end
        PjHorzAndVert(ProtocolIdx).protocol = Protocols{ProtocolIdx};
        PjHorzAndVert(ProtocolIdx).SelectChoice = SelectChoice;
        PjHorzAndVert(ProtocolIdx).PjHorz_Click = PjHorz_Click;
        PjHorzAndVert(ProtocolIdx).PjHorz_ClickTrain = PjHorz_ClickTrain;
        PjHorzAndVert(ProtocolIdx).PjHorz_CSI = PjHorz_CSI;
        PjHorzAndVert(ProtocolIdx).PjVert_Click = PjVert_Click;
        PjHorzAndVert(ProtocolIdx).PjVert_ClickTrain = PjVert_ClickTrain;
        PjHorzAndVert(ProtocolIdx).PjVert_CSI = PjVert_CSI;   
    end 
end
%%
function PlotPjHorzAndVert(PjHorzAndVert, AnimalAndAreaStr)
    Fig = figure;
    maximizeFig(Fig);
    RowNum = 2; % R1:BG3ms; R2:BG14ms
    ColNum = 6; % C1:click; C2:click train; C3:CSI
    for protocolIdx = 1 : numel({PjHorzAndVert.protocol})
        SelectChoice = PjHorzAndVert(protocolIdx).SelectChoice;
        %%%%%%%%%%%%%%% Colum 1 and 2: click %%%%%%%%%%%%%%%%%%%
        %Horz
        subplot(RowNum, ColNum, 1 + (protocolIdx -1) * ColNum);
        colorMap = PjHorzAndVert(protocolIdx).PjHorz_Click; 
        PjHorz_Click_clim = [min([PjHorzAndVert.PjHorz_Click], [], "all"), max([PjHorzAndVert.PjHorz_Click], [], "all")];
        clipLim = linspace(-max(abs(PjHorz_Click_clim)), max(abs(PjHorz_Click_clim)), 256)';
        colorMap(colorMap >= clipLim(127) & colorMap <0) = clipLim(127);
        colorMap(colorMap <= clipLim(130) & colorMap >0) = clipLim(130);
        imagesc(colorMap);
        %plot settings
        [row, col] = find(colorMap ~= 0);
        xlim([min(col) - 0.5, max(col) + 0.5]); 
        ylim([min(row) - 0.5, max(row) + 0.5]); 
        scaleAxes(gca, "c", [-max(abs(PjHorz_Click_clim)), max(abs(PjHorz_Click_clim))]);
        xticks(0 : max(col)); yticks(0 : max(row));
        xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
        c = colormap(gca, "jet");
        c(128:129, :) = 1;
        colormap(gca, c); colorbar;
        title("Click-Horizontal");
        %Vert
        subplot(RowNum, ColNum, 2 + (protocolIdx -1) * ColNum);
        colorMap = PjHorzAndVert(protocolIdx).PjVert_Click; 
        PjVert_Click_clim = [min([PjHorzAndVert.PjVert_Click], [], "all"), max([PjHorzAndVert.PjVert_Click], [], "all")];
        clipLim = linspace(-max(abs(PjVert_Click_clim)), max(abs(PjVert_Click_clim)), 256)';
        colorMap(colorMap >= clipLim(127) & colorMap <0) = clipLim(127);
        colorMap(colorMap <= clipLim(130) & colorMap >0) = clipLim(130);
        imagesc(colorMap);
        %plot settings
        [row, col] = find(colorMap ~= 0);
        xlim([min(col) - 0.5, max(col) + 0.5]); 
        ylim([min(row) - 0.5, max(row) + 0.5]); 
        scaleAxes(gca, "c", [-max(abs(PjVert_Click_clim)), max(abs(PjVert_Click_clim))]);
        xticks(0 : max(col)); yticks(0 : max(row));
        xlabel("Lateral to Interaural"); ylabel("Deep to Surface");
        c = colormap(gca, "jet");
        c(128:129, :) = 1;
        colormap(gca, c); colorbar; 
        title("Click-Vertical");

        %%%%%%%%%%%%%%% Colum 3 and 4: click train %%%%%%%%%%%%%%%%%%%
        %Horz
        subplot(RowNum, ColNum, 3 + (protocolIdx -1) * ColNum);
        colorMap = PjHorzAndVert(protocolIdx).PjHorz_ClickTrain; 
        PjHorz_ClickTrain_clim = [min([PjHorzAndVert.PjHorz_ClickTrain], [], "all"), max([PjHorzAndVert.PjHorz_ClickTrain], [], "all")];
        clipLim = linspace(-max(abs(PjHorz_ClickTrain_clim)), max(abs(PjHorz_ClickTrain_clim)), 256)';
        colorMap(colorMap >= clipLim(127) & colorMap <0) = clipLim(127);
        colorMap(colorMap <= clipLim(130) & colorMap >0) = clipLim(130);
        imagesc(colorMap);
        %plot settings
        [row, col] = find(colorMap ~= 0);
        xlim([min(col) - 0.5, max(col) + 0.5]); 
        ylim([min(row) - 0.5, max(row) + 0.5]); 
        scaleAxes(gca, "c", [-max(abs(PjHorz_ClickTrain_clim)), max(abs(PjHorz_ClickTrain_clim))]);
        xticks(0 : max(col)); yticks(0 : max(row));
        xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
        c = colormap(gca, "jet");
        c(128:129, :) = 1;
        colormap(gca, c); colorbar;        
        title("ClickTrain-Horizontal");

        %Vert
        subplot(RowNum, ColNum, 4 + (protocolIdx -1) * ColNum);
        colorMap = PjHorzAndVert(protocolIdx).PjVert_ClickTrain; 
        PjVert_ClickTrain_clim = [min([PjHorzAndVert.PjVert_ClickTrain], [], "all"), max([PjHorzAndVert.PjVert_ClickTrain], [], "all")];
        clipLim = linspace(-max(abs(PjVert_ClickTrain_clim)), max(abs(PjVert_ClickTrain_clim)), 256)';
        colorMap(colorMap >= clipLim(127) & colorMap <0) = clipLim(127);
        colorMap(colorMap <= clipLim(130) & colorMap >0) = clipLim(130);
        imagesc(colorMap);
        %plot settings
        [row, col] = find(colorMap ~= 0);
        xlim([min(col) - 0.5, max(col) + 0.5]); 
        ylim([min(row) - 0.5, max(row) + 0.5]); 
        scaleAxes(gca, "c", [-max(abs(PjVert_ClickTrain_clim)), max(abs(PjVert_ClickTrain_clim))]);
        xticks(0 : max(col)); yticks(0 : max(row));
        xlabel("Lateral to Interaural"); ylabel("Deep to Surface");
        c = colormap(gca, "jet");
        c(128:129, :) = 1;
        colormap(gca, c); colorbar;  
        title("ClickTrain-Vertical");

        %%%%%%%%%%%%%%% Colum 5 and 6: CSI %%%%%%%%%%%%%%%%%%%
        % Horz
        subplot(RowNum, ColNum, 5 + (protocolIdx -1) * ColNum);
        colorMap = PjHorzAndVert(protocolIdx).PjHorz_CSI;  
        PjHorz_CSI_clim = [min([PjHorzAndVert.PjHorz_CSI], [], "all"), max([PjHorzAndVert.PjHorz_CSI], [], "all")];
        clipLim = linspace(-max(abs(PjHorz_CSI_clim)), max(abs(PjHorz_CSI_clim)), 256)';
        colorMap(colorMap >= clipLim(127) & colorMap <0) = clipLim(127);
        colorMap(colorMap <= clipLim(130) & colorMap >0) = clipLim(130);
        imagesc(colorMap);
        %plot settings
        [row, col] = find(colorMap ~= 0);
        xlim([min(col) - 0.5, max(col) + 0.5]); 
        ylim([min(row) - 0.5, max(row) + 0.5]); 
        scaleAxes(gca, "c", [-max(abs(PjHorz_CSI_clim)), max(abs(PjHorz_CSI_clim))]);
        xticks(0 : max(col)); yticks(0 : max(row));
        xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
        c = colormap(gca, "jet");
        c(128:129, :) = 1;
        colormap(gca, c); colorbar;        
        title("CSI-Horizontal");
        % Vert
        subplot(RowNum, ColNum, 6 + (protocolIdx -1) * ColNum);
        colorMap = PjHorzAndVert(protocolIdx).PjVert_CSI; 
        PjVert_CSI_clim = [min([PjHorzAndVert.PjVert_CSI], [], "all"), max([PjHorzAndVert.PjVert_CSI], [], "all")];
        clipLim = linspace(-max(abs(PjVert_CSI_clim)), max(abs(PjVert_CSI_clim)), 256)';
        colorMap(colorMap >= clipLim(127) & colorMap <0) = clipLim(127);
        colorMap(colorMap <= clipLim(130) & colorMap >0) = clipLim(130);
        imagesc(colorMap);
        %plot settings
        [row, col] = find(colorMap ~= 0);
        xlim([min(col) - 0.5, max(col) + 0.5]); 
        ylim([min(row) - 0.5, max(row) + 0.5]); 
        scaleAxes(gca, "c", [-max(abs(PjVert_CSI_clim)), max(abs(PjVert_CSI_clim))]);
        xticks(0 : max(col)); yticks(0 : max(row));
        xlabel("Lateral to Interaural"); ylabel("Deep to Surface");
        c = colormap(gca, "jet");
        c(128:129, :) = 1;
        colormap(gca, c); colorbar; 
        title("CSI-Vertical");

    end
    Protemp = cellfun(@(y) y(2), cellfun(@(x) strsplit(x, "_"), {PjHorzAndVert.protocol}, "UniformOutput", false));
    annotation("textbox", [.35, .89, .1, .1], 'String', strcat(strrep(AnimalAndAreaStr, "_", "-"), "(", SelectChoice, ")", " | ", Protemp(1)), 'EdgeColor', 'none', 'FitBoxToText', 'on', 'FontSize', 15);
    annotation("textbox", [.35, .43, .1, .1], 'String', strcat(strrep(AnimalAndAreaStr, "_", "-"), "(", SelectChoice, ")", " | ", Protemp(2)), 'EdgeColor', 'none', 'FitBoxToText', 'on', 'FontSize', 15);
end










