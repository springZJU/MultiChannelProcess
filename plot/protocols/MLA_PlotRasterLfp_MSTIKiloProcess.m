function MLA_PlotRasterLfp_MSTIKiloProcess(chSpikeLfp, CTLParams)
parseStruct(CTLParams);
colMax = length(chSpikeLfp);
idchNum = length(chSpikeLfp(1).chSPK);
chNum = length(chSpikeLfp(1).chLFP);

temp = dir(FIGPATH);
% Exist_Single = any(contains(string({temp.name}), "kilo"));
Exist_CH = any(contains(string({temp.name}), "CH"));
Exist_Single = 0;
% Exist_CH = 0;
Exist_CSD_MUA = 1;
Exist_LFP_By_Ch = 0;
Exist_LFP_Acorss_Ch = 1;
if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_CSD_MUA, Exist_Single, Exist_CH])
    return
end

% plot params setting
nGeneral = 2;
plotRows = 3;
PSTH_CompareSize = [1,1];
LFP_CompareSize = [1,1];
legendFontSize = 5;
margins = [0.05, 0.05, 0.15, 0.1];
paddings = [0.01, 0.03, 0.1, 0.01];

if ~Exist_Single
    for cIndex = 1 : idchNum
        singleunit_Fig(cIndex) = figure;
        maximizeFig(singleunit_Fig(cIndex));
        for dIndex = 1 : length(chSpikeLfp)
    
            trialNum = chSpikeLfp(dIndex).trialNum;
            chStr = chSpikeLfp(dIndex).chSPK(cIndex).info;
            %% ROW1: whole time raster plot
            pIndex = dIndex;
            Axes(dIndex, 1) = mSubplot(singleunit_Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
            temp = chSpikeLfp(dIndex).chSPK(cIndex).spikePlot;
            t =temp(:, 1);
            trialN = arrayRep(temp(:, 2), unique(temp(:, 2)), 1 : length(unique(temp(:, 2))));
            scatter(t, trialN, 10, "black", "filled"); hold on
            title(stimStrs(dIndex));
    
            % Odd Dev Spike Counts
            tIndex = t >= sigTestWin(1) & t<= sigTestWin(2);
            selSpikes = temp(tIndex, 2);
            Odd_Dev_FR{dIndex, 1} = [hist(selSpikes,unique(selSpikes))' / diff(sigTestWin) * 1000; zeros(trialNum-length(unique(selSpikes)), 1)];
            % Odd Std Spike Counts
            winTemp = sigTestWin - tStdToDev(dIndex, 1);
            tIndex = t >= winTemp(1) & t<= winTemp(2);
            selSpikes = temp(tIndex, 2);
            Odd_Std_FR{dIndex, 1} = [hist(selSpikes,unique(selSpikes))'/ diff(sigTestWin) * 1000; zeros(trialNum-length(unique(selSpikes)), 1)];
    
            %% ROW2: whole time psth
            pIndex = colMax + dIndex;
            Axes(dIndex, 2) = mSubplot(singleunit_Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
            temp = chSpikeLfp(dIndex).chSPK(cIndex).PSTH;
            t = temp(:, 1);
            PSTH = smoothdata(temp(: ,2),'gaussian',25);
            psthTemp{dIndex, 1} = [t, PSTH];
            plot(t, PSTH, "Color", "black", "LineStyle", "-", "LineWidth", 1); hold on;
            title(strcat(strrep(string(chStr), "CH", "ID"), " n=",  num2str(trialNum)));
            
        end
    
        %% PSTH Comparison
        legendStr = ["Odd Dev", "Odd Std"];
        compareGroupN = length(MMNcompare);
        compareCol = compareGroupN;
        for pIndex = 1 : compareGroupN
            posIndex = nGeneral * compareCol + pIndex;
    
            % Odd Dev vs Odd Std
            soundICI = strrep(MMNcompare(pIndex).sound, "Std", "ICI");
            Odd_Dev_Index = MMNcompare(pIndex).DevOrder;
            Odd_Std_Index = MMNcompare(pIndex).StdOrder_Lagidx;
            AxesPSTH(pIndex) = mSubplot(singleunit_Fig(cIndex), plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
            % Odd Dev
            X = psthTemp{Odd_Dev_Index, 1}(:, 1);
            Y = psthTemp{Odd_Dev_Index, 1}(:, 2);
            plot(AxesPSTH(pIndex), X, Y, "Color", Colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on
    
            % Odd Std
            X = psthTemp{Odd_Std_Index, 1}(:, 1) + diff(Std_Dev_Onset{Odd_Std_Index}(end-1:end));
            Y = psthTemp{Odd_Std_Index, 1}(:, 2);
            plot(AxesPSTH(pIndex), X, Y, "Color", Colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on
            
            % significance test
            % Odd Dev vs Odd Std
            if strcmpi(sigTestMethod, "ranksum")
                p_Odd_Dev_Std = ranksum(Odd_Dev_FR{Odd_Dev_Index}, Odd_Std_FR{Odd_Std_Index});
            elseif strcmpi(sigTestMethod, "ttest2")
                [~, p_Odd_Dev_Std] = ttest2(Odd_Dev_FR{Odd_Dev_Index}, Odd_Std_FR{Odd_Std_Index});
            else
                error("Unitiated method!")
            end
            p_Str = strcat("p-Odd-Dev-Std = ", num2str(roundn(p_Odd_Dev_Std, -4)));
            test_Str = strcat(" ", sigTestMethod, "[", num2str(sigTestWin(1)), " ", num2str(sigTestWin(2)), "]: ");
            title(strcat(soundICI, test_Str, p_Str));
    
            % legend
            legend(AxesPSTH(pIndex), flip(AxesPSTH(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
        end
    
        % scale
        for rIndex = 1 : size(Axes, 2)
            scaleAxes(Axes(:, rIndex), "x", plotWin);
        end
        for rIndex = 1 : nGeneral
            scaleAxes(Axes(:, rIndex), "y", "on");
        end
        scaleAxes(AxesPSTH, "x", compareWin);
        scaleAxes(AxesPSTH, "y", "on");
        % add vertical line
        % add std lines
        for dIndex = 1 : length(chSpikeLfp)
            lines = [];
            for stdIdx = 1 : size(Std_Dev_Onset{dIndex}, 1)
                lines(stdIdx).X  = Std_Dev_Onset{dIndex}(stdIdx) - Std_Dev_Onset{dIndex}(end);
            end
            addLines2Axes(Axes(dIndex, 1:2), lines);
        end
        % add 0 time line
        lines = [];
        lines(1).X = 0;
        lines(1).color = "red";
        for aIndex = 1 : size(Axes, 2)
            addLines2Axes(Axes(:, aIndex), lines);
        end
        addLines2Axes(AxesPSTH, lines);
    
        drawnow;
        pause(2);
        print(singleunit_Fig(cIndex), strcat(FIGPATH, "\kiloID", strrep(string(chSpikeLfp(dIndex).chSPK(cIndex).info), "CH", "")), "-djpeg", "-r200");
    end
    close all;
end

if ~Exist_CH
    nGeneral = 3;
    plotRows = 4;
    for cIndex = 1 : chNum
        CH_Fig(cIndex) = figure;
        maximizeFig(CH_Fig(cIndex));
        for dIndex = 1 : length(chSpikeLfp)
    
            trialNum = chSpikeLfp(dIndex).trialNum;
            chStr = chSpikeLfp(dIndex).chLFP(cIndex).info;
            %% ROW1: whole time lfp
            pIndex = dIndex;
            Axes(dIndex, 1) = mSubplot(CH_Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
            lfpTemp{dIndex, 1} = chSpikeLfp(dIndex).chLFP(cIndex).Wave;
            plot(lfpTemp{dIndex, 1}(:, 1), lfpTemp{dIndex, 1}(:, 2), "Color", "red", "LineWidth", 1, "LineStyle", "-", "LineWidth", 1.5); hold on;
            title(strcat(chStr, " | ", stimStrs(dIndex)));

            %% ROW2: FFT
            temp = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 2);
            t = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 1);
            pIndex = 2 * colMax + 2 * dIndex - 1;
            % local
            Axes(dIndex, 2) = mSubplot(CH_Fig(cIndex), plotRows, 2 * colMax, pIndex, [1, 1], margins, paddings);
            plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
            xlim([0 cursor1(dIndex) + 50]);
            % 5Hz
            Axes(dIndex, 3) = mSubplot(CH_Fig(cIndex), plotRows, 2 * colMax, pIndex + 1, [1, 1], margins, paddings);
            plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
            xlim([0 10]);

            %% ROW3: cwt
            temp = chSpikeLfp(dIndex).chLFP(cIndex).cwt;
            t = chSpikeLfp(dIndex).chLFP(cIndex).cwt_time(:, 1);
            f{dIndex} = chSpikeLfp(dIndex).chLFP(cIndex).cwt_f(:, 1);
            t_idx = find(t > CWTplotWindow(1) & t < CWTplotWindow(2));
            t_fsD_win = t(t_idx);
            pIndex = 2 * colMax + dIndex;   
            Axes(dIndex, 4) = mSubplot(CH_Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
            imagesc('XData', t_fsD_win, 'YData', f{dIndex}, 'CData', temp);
            colormap("jet");
            hold on;
        end
    
        %% LFP Comparison
        legendStr = ["Odd Dev", "Odd Std"];
        compareGroupN = length(MMNcompare);
        compareCol = compareGroupN;
        for pIndex = 1 : compareGroupN
            posIndex = nGeneral * compareCol + pIndex;
            % Odd Dev vs Odd Std
            soundICI = strrep(MMNcompare(pIndex).sound, "Std", "ICI");
            Odd_Dev_Index = MMNcompare(pIndex).DevOrder;
            Odd_Std_Index = MMNcompare(pIndex).StdOrder_Lagidx;
            AxesLFP(pIndex) = mSubplot(CH_Fig(cIndex), plotRows, compareCol, posIndex, LFP_CompareSize, margins, paddings, "alignment", "top-left");
            % Odd Dev
            X = lfpTemp{Odd_Dev_Index, 1}(:, 1);
            Y = lfpTemp{Odd_Dev_Index, 1}(:, 2);
            plot(AxesLFP(pIndex), X, Y, "Color", Colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on
    
            % Odd Std
            X = lfpTemp{Odd_Std_Index, 1}(:, 1) + diff(Std_Dev_Onset{Odd_Std_Index}(end-1:end));
            Y = lfpTemp{Odd_Std_Index, 1}(:, 2);
            plot(AxesLFP(pIndex), X, Y, "Color", Colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on
            title(strcat(soundICI, " ", strjoin(legendStr, " vs ")));
    
            % legend
            legend(AxesLFP(pIndex), flip(AxesLFP(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
        end
    
        %% scale
        scaleAxes(Axes(:, 1), "x", plotWin);
        scaleAxes(Axes(:, 4), "x", CWTplotWindow);
        scaleAxes(Axes(:, 1), "y", "on");
        scaleAxes(Axes(:, 2), "y", "on");
        scaleAxes(Axes(:, 3), "y", "on");
        scaleAxes(Axes(:, 4), "y", [0 max(cell2mat(f'))]);
        scaleAxes(Axes(:, 4), "c", "on");
        scaleAxes(AxesLFP, "x", compareWin);
        scaleAxes(AxesLFP, "y", "on");
        % add vertical line
        % add std lines
        for dIndex = 1 : length(chSpikeLfp)
            lines = [];
            for stdIdx = 1 : size(Std_Dev_Onset{dIndex}, 1)
                lines(stdIdx).X  = Std_Dev_Onset{dIndex}(stdIdx) - Std_Dev_Onset{dIndex}(end);
            end
            addLines2Axes(Axes(dIndex, 1), lines);
            addLines2Axes(Axes(dIndex, 4), lines);
        end
        % add fft lines
        for dIndex = 1 : length(chSpikeLfp)
            lines = [];
            lines(1).X = cursor1(dIndex);lines(1).color = 'b';
            lines(2).X = unique(cursor2);lines(2).color = 'b';
            lines(3).X = cursor3;lines(3).color = 'b';
            addLines2Axes(Axes(dIndex, 2), lines(1:2));
            addLines2Axes(Axes(dIndex, 3), lines(3));
        end
        % add 0 time line
        lines = [];
        lines(1).X = 0;
        lines(1).color = "red";
        for aIndex = 1 : size(Axes, 2)
            addLines2Axes(Axes(:, aIndex), lines);
        end
        addLines2Axes(AxesLFP, lines);
        drawnow;
        pause(2);
        print(CH_Fig(cIndex), strcat(FIGPATH, chSpikeLfp(dIndex).chLFP(cIndex).info), "-djpeg", "-r200");
    end
    close all;
end
%% RS distribution
rowNum = length(chSpikeLfp);%for trial types
colNum = 3;%for BG,ICI1,ICI2
FigRS = figure;
maximizeFig(FigRS);
lines(1).X = 3.6; lines(1).color = "r";

for typeIndex = 1 : rowNum
    BG_RS_value = cell2mat(cellfun(@(x) x(1, :), {chSpikeLfp(typeIndex).chSPK.chRS}, "UniformOutput", false)');
    BG_ICI_str = strcat("BG ICI", string(unique(BG_RS_value(:, 2))), "ms");
    Sound1_RS_value = cell2mat(cellfun(@(x) x(2, :), {chSpikeLfp(typeIndex).chSPK.chRS}, "UniformOutput", false)');
    Sound1_ICI_str = strcat("Sound1 ICI", string(unique(Sound1_RS_value(:, 2))), "ms");
    Sound2_RS_value = cell2mat(cellfun(@(x) x(3, :), {chSpikeLfp(typeIndex).chSPK.chRS}, "UniformOutput", false)');
    Sound2_ICI_str = strcat("Sound2 ICI", string(unique(Sound2_RS_value(:, 2))), "ms");
    scatter_y = [1 : numel(chSpikeLfp(typeIndex).chSPK)];
    for colIndex = 1 : colNum
        if typeIndex == 1
            posIndex = colIndex;
        else
            posIndex = (typeIndex - 1) * colNum + colIndex;
        end
        AxesRS(typeIndex, colIndex) = mSubplot(FigRS, rowNum, colNum, posIndex, [1,1], margins, paddings);
        if colIndex == 1
            scatter(AxesRS(typeIndex, colIndex), BG_RS_value(:, 1), scatter_y, 200, "k.");hold on;
            title(BG_ICI_str);
        elseif colIndex == 2
            scatter(AxesRS(typeIndex, colIndex), Sound1_RS_value(:, 1), scatter_y, 200, "k.");hold on;
            title(Sound1_ICI_str);
        elseif colIndex == 3
            scatter(AxesRS(typeIndex, colIndex), Sound2_RS_value(:, 1), scatter_y, 200, "k.");hold on;
            title(Sound2_ICI_str);
        end
        set(AxesRS(typeIndex, colIndex), 'YTick', scatter_y);
        set(AxesRS(typeIndex, colIndex), 'YTickLabel', {chSpikeLfp(typeIndex).chSPK.info});
        scaleAxes(AxesRS(typeIndex, colIndex), "y");
        addLines2Axes(AxesRS(typeIndex, colIndex), lines);hold on;
    end
end
print(FigRS, strcat(FIGPATH, "ID_RS.jpg"), "-djpeg", "-r200");
close all;

end