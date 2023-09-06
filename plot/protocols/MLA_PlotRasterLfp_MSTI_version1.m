function Fig = MLA_PlotRasterLfp_MSTI_version1(chSpikeLfp, CTLParams)
CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
Std_Dev_Onset = {MSTIsoundinfo.Std_Dev_Onset};
colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).chSPK);
% plot params setting
nGeneral = 4;
plotRows = 6;
PSTH_CompareSize = [1,1];
LFP_CompareSize = [1,1];
legendFontSize = 5;
margins = [0.05, 0.05, 0.15, 0.1];
paddings = [0.01, 0.03, 0.1, 0.01];
for cIndex = 1 : chNum
    Fig(cIndex) = figure;
    maximizeFig(Fig(cIndex));

    for dIndex = 1 : length(chSpikeLfp)

        trialNum = chSpikeLfp(dIndex).trialNum;
        chStr = chSpikeLfp(dIndex).chLFP(cIndex).info;
        %% ROW1: whole time raster plot
        pIndex = dIndex;
        Axes(dIndex, 1) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
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
        winTemp = sigTestWin - diff(Std_Dev_Onset{dIndex}(end-1:end));
        tIndex = t >= winTemp(1) & t<= winTemp(2);
        selSpikes = temp(tIndex, 2);
        Odd_Std_FR{dIndex, 1} = [hist(selSpikes,unique(selSpikes))'/ diff(sigTestWin) * 1000; zeros(trialNum-length(unique(selSpikes)), 1)];

        %% ROW2: whole time psth
        pIndex = colMax + dIndex;
        Axes(dIndex, 2) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).PSTH;
        t =temp(:, 1);
        PSTH = smoothdata(temp(: ,2),'gaussian',25);
        psthTemp{dIndex, 1} = [t, PSTH];
        plot(t, PSTH, "Color", "black", "LineStyle", "-", "LineWidth", 1); hold on;
        title(strcat(chStr, " n=",  num2str(trialNum)));

        %% ROW3: whole time lfp
        pIndex = 2 * colMax + dIndex;
        Axes(dIndex, 3) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
        lfpTemp{dIndex, 1} = chSpikeLfp(dIndex).chLFP(cIndex).Wave;
        plot(lfpTemp{dIndex, 1}(:, 1), lfpTemp{dIndex, 1}(:, 2), "Color", "red", "LineWidth", 1, "LineStyle", "-", "LineWidth", 1.5); hold on;

        %% add std lines
        lines = [];
        for stdIdx = 1 : size(Std_Dev_Onset{dIndex}, 1)
            lines(stdIdx).X  = Std_Dev_Onset{dIndex}(stdIdx) - Std_Dev_Onset{dIndex}(end);
        end
        addLines2Axes(Axes(dIndex, 1:3), lines);

        %% ROW4: FFT
        temp = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 2);
        t = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 1);
        pIndex = (nGeneral-1) * 2 * colMax + 2 * dIndex - 1;
        lines = [];
        lines(1).X = cursor1(dIndex);lines(1).color = 'b';
        lines(2).X = unique(cursor2);lines(2).color = 'b';
        lines(3).X = cursor3;lines(3).color = 'b';   
        % local
        Axes(dIndex, nGeneral) = mSubplot(Fig(cIndex), plotRows, 2 * colMax, pIndex, [1, 1], margins, paddings);
        plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
        xlim([0 cursor1(dIndex) + 50]);
        addLines2Axes(Axes(dIndex, nGeneral), lines(1:2));
        % 5Hz
        Axes(dIndex, nGeneral + 1) = mSubplot(Fig(cIndex), plotRows, 2 * colMax, pIndex + 1, [1, 1], margins, paddings);
        plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
        xlim([0 10]);
        addLines2Axes(Axes(dIndex, nGeneral + 1), lines(3));
        
    end

    %% PSTH Comparison
    legendStr = ["Odd Dev", "Odd Std"];
    compareGroupN = length(MMNcompare);
    compareCol = compareGroupN;
    for pIndex = 1 : compareGroupN
        for sIndex = 1
        posIndex = (nGeneral+sIndex-1) * compareCol + pIndex;

        % Odd Dev vs Odd Std
        soundICI = strrep(MMNcompare(pIndex).sound, "Std", "ICI");
        Odd_Dev_Index = MMNcompare(pIndex).DevOrder;
        Odd_Std_Index = MMNcompare(pIndex).StdOrder_Lagidx;
        AxesPSTH(pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
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
        end
        % legend
        legend(AxesPSTH(pIndex), flip(AxesPSTH(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
    end

    %% LFP Comparison
    for pIndex = 1 : compareGroupN
        for sIndex = 2
        posIndex = (nGeneral+sIndex-1) * compareCol + pIndex;
        % Odd Dev vs Odd Std
        soundICI = strrep(MMNcompare(pIndex).sound, "Std", "ICI");
        Odd_Dev_Index = MMNcompare(pIndex).DevOrder;
        Odd_Std_Index = MMNcompare(pIndex).StdOrder_Lagidx;
        AxesLFP(pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, LFP_CompareSize, margins, paddings, "alignment", "top-left");
        % Odd Dev
        X = lfpTemp{Odd_Dev_Index, 1}(:, 1);
        Y = lfpTemp{Odd_Dev_Index, 1}(:, 2);
        plot(AxesLFP(pIndex), X, Y, "Color", Colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on

        % Odd Std
        X = lfpTemp{Odd_Std_Index, 1}(:, 1) + diff(Std_Dev_Onset{Odd_Std_Index}(end-1:end));
        Y = lfpTemp{Odd_Std_Index, 1}(:, 2);
        plot(AxesLFP(pIndex), X, Y, "Color", Colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on
        title(strcat(soundICI, " ", strjoin(legendStr, " vs ")));
        end
        % legend
        legend(AxesLFP(pIndex), flip(AxesLFP(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
    end

    % add vertical line
    lines = [];
    lines(1).X = 0;
    lines(1).color = "red";
    for aIndex = 1 : size(Axes, 2)
        addLines2Axes(Axes(:, aIndex), lines);
    end
    addLines2Axes(AxesLFP, lines);
    addLines2Axes(AxesPSTH, lines);

    %% scale
    for rIndex = 1 : 3
        scaleAxes(Axes(:, rIndex), "x", plotWin);
    end
    for rIndex = 1 : nGeneral
        scaleAxes(Axes(:, rIndex), "y", "on");
    end

    scaleAxes(AxesPSTH, "x", compareWin);
    scaleAxes(AxesLFP, "x", compareWin);
    scaleAxes(AxesPSTH, "y", "on");
    scaleAxes(AxesLFP, "y", "on");
    drawnow;
    pause(2);
    print(Fig(cIndex), strcat(FIGPATH, chSpikeLfp(dIndex).chSPK(cIndex).info), "-djpeg", "-r200");
end
close all;
%% RS distribution
% rowNum = length(chSpikeLfp);%for trial types
% colNum = 3;%for BG,ICI1,ICI2
% FigRS = figure;
% maximizeFig(FigRS);
% lines(1).X = 3.6; lines(1).color = "r";
% 
% for typeIndex = 1 : rowNum
%     BG_RS_value = cell2mat(cellfun(@(x) x(1, :), {chSpikeLfp(typeIndex).chSPK.chRS}, "UniformOutput", false)');
%     BG_ICI_str = strcat("BG ICI", string(unique(BG_RS_value(:, 2))), "ms");
%     Sound1_RS_value = cell2mat(cellfun(@(x) x(2, :), {chSpikeLfp(typeIndex).chSPK.chRS}, "UniformOutput", false)');
%     Sound1_ICI_str = strcat("Sound1 ICI", string(unique(Sound1_RS_value(:, 2))), "ms");
%     Sound2_RS_value = cell2mat(cellfun(@(x) x(3, :), {chSpikeLfp(typeIndex).chSPK.chRS}, "UniformOutput", false)');
%     Sound2_ICI_str = strcat("Sound2 ICI", string(unique(Sound2_RS_value(:, 2))), "ms");
%     scatter_y = [1 : numel(chSpikeLfp(typeIndex).chSPK)];
%     for colIndex = 1 : colNum
%         if typeIndex == 1
%             posIndex = colIndex;
%         else
%             posIndex = (typeIndex - 1) * colNum + colIndex;
%         end
%         AxesRS(typeIndex, colIndex) = mSubplot(FigRS, rowNum, colNum, posIndex, [1,1], margins, paddings);
%         if colIndex == 1
%             scatter(AxesRS(typeIndex, colIndex), BG_RS_value(:, 1), scatter_y, 200, "k.");hold on;
%             title(BG_ICI_str);
%         elseif colIndex == 2
%             scatter(AxesRS(typeIndex, colIndex), Sound1_RS_value(:, 1), scatter_y, 200, "k.");hold on;
%             title(Sound1_ICI_str);
%         elseif colIndex == 3
%             scatter(AxesRS(typeIndex, colIndex), Sound2_RS_value(:, 1), scatter_y, 200, "k.");hold on;
%             title(Sound2_ICI_str);
%         end
%         set(AxesRS(typeIndex, colIndex), 'YTick', scatter_y);
%         set(AxesRS(typeIndex, colIndex), 'YTickLabel', {chSpikeLfp(typeIndex).chSPK.info});
%         scaleAxes(AxesRS(typeIndex, colIndex), "y");
%         addLines2Axes(AxesRS(typeIndex, colIndex), lines);hold on;
%     end
% end
% print(FigRS, strcat(FIGPATH, "CHs_RS.jpg"), "-djpeg", "-r200");
% close all;

end