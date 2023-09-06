function Fig = MLA_PlotRasterLfp_MSTI(chSpikeLfp, CTLParams)


CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end

colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).chSPK);
nGeneral = 4;
legendRows = 12;

if ~toPlotFFT
    nGeneral = nGeneral - 1;
    plotRows = plotRows - 1;
end

for cIndex = 1 : chNum
    Fig(cIndex) = figure;
    maximizeFig(Fig(cIndex));
    margins = [0.05, 0.05, 0.15, 0.1];
    paddings = [0.01, 0.03, 0.1, 0.01];

    for dIndex = 1 : colMax

        trialNum = chSpikeLfp(dIndex).trialNum;
        chStr = chSpikeLfp(dIndex).chLFP(cIndex).info;
        %% ROW1: whole time raster plot
        pIndex = dIndex;
        Axes(dIndex, 1) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).spikePlot;
        t =temp(:, 1);
        trialN = arrayRep(temp(:, 2), unique(temp(:, 2)), 1 : length(unique(temp(:, 2))));
        scatter(t, trialN, 10, "black", "filled"); hold on
        title(stimStr(dIndex));

        % Odd Dev Spike Counts
        tIndex = t >= sigTestWin(1) & t<= sigTestWin(2);
        selSpikes = temp(tIndex, 2);
        Odd_Dev_FR{dIndex, 1} = [hist(selSpikes,unique(selSpikes))' / diff(sigTestWin) * 1000; zeros(trialNum-length(unique(selSpikes)), 1)];
        % Odd Std Spike Counts
        winTemp = sigTestWin - diff(Std_Dev_Onset(dIndex, end-1:end));
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
        for stdIdx = 1 : size(Std_Dev_Onset, 2)-1
            lines(stdIdx).X  = Std_Dev_Onset(dIndex, stdIdx) - DevOnset(dIndex);
        end
        addLines2Axes(Axes(dIndex, :), lines);

        %% ROW4: FFT
        if toPlotFFT
            pIndex = (nGeneral-1) * colMax + dIndex;
            Axes(dIndex, nGeneral) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
            temp = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 2);
            t = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 1);
            plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
            xlim([0 100]);
        end
    end

    %% PSTH Comparison
    legendStr = ["Odd Dev", "ManyStd Dev","Odd Std"];
    Compare_Index = Compare_Index(cell2mat(cellfun(@(x) any(ismember(1 : colMax, x)), Compare_Index, "UniformOutput", false)));
    compareGroupN = length(Compare_Index);
    compareCol = (PSTH_CompareSize(1) + LFP_CompareSize(1)) * compareGroupN;
    for pIndex = 1 : compareGroupN
        for sIndex = 1 : 2
        posIndex = (nGeneral+sIndex-1) * compareCol + pIndex;

        % Odd Dev vs Odd Std vs ManyStd Dev
        devStr = S1_S2(pIndex, sIndex);
        StdStr = S1_S2(pIndex, 2-sIndex+1);
        Odd_Dev_Index = cell2mat(cellfun(@(x) strcmpi(x(2), devStr)&~strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "-")), stimStr, "uni", false)', "UniformOutput", false));
        MantStd_Dev_Index = cell2mat(cellfun(@(x) strcmpi(x(2), devStr)&strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "-")), stimStr, "uni", false)', "UniformOutput", false));
        Odd_Std_Index = cell2mat(cellfun(@(x) strcmpi(x(2), StdStr)&~strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "-")), stimStr, "uni", false)', "UniformOutput", false));
        AxesPSTH(sIndex, pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
        % Odd Dev
        X = psthTemp{Odd_Dev_Index, 1}(:, 1);
        Y = psthTemp{Odd_Dev_Index, 1}(:, 2);
        plot(AxesPSTH(sIndex, pIndex), X, Y, "Color", colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on
        
        % ManyStd Dev
        X = psthTemp{MantStd_Dev_Index, 1}(:, 1);
        Y = psthTemp{MantStd_Dev_Index, 1}(:, 2);
        plot(AxesPSTH(sIndex, pIndex), X, Y, "Color", colors(3), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on

        % Odd Std
        X = psthTemp{Odd_Std_Index, 1}(:, 1) + diff(Std_Dev_Onset(Odd_Std_Index, end-1:end));
        Y = psthTemp{Odd_Std_Index, 1}(:, 2);
        plot(AxesPSTH(sIndex, pIndex), X, Y, "Color", colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(3)); hold on
        
        % significance test
        % Odd Dev vs Odd Std
        if strcmpi(sigTestMethod, "ranksum")
            p_Odd_Dev_Std = ranksum(Odd_Dev_FR{Odd_Dev_Index}, Odd_Std_FR{Odd_Std_Index});
            p_Odd_Dev_ManyStd_Dev = ranksum(Odd_Dev_FR{Odd_Dev_Index}, Odd_Dev_FR{MantStd_Dev_Index});
        elseif strcmpi(sigTestMethod, "ttest2")
            [~, p_Odd_Dev_Std] = ttest2(Odd_Dev_FR{Odd_Dev_Index}, Odd_Std_FR{Odd_Std_Index});
            [~, p_Odd_Dev_ManyStd_Dev] = ttest2(Odd_Dev_FR{Odd_Dev_Index}, Odd_Dev_FR{MantStd_Dev_Index});
        else
            error("Unitiated method!")
        end
        p_Str = strcat("p-Odd-Dev-Std = ", num2str(roundn(p_Odd_Dev_Std, -4)), ", p-Odd-Dev-ManyStd-Dev = ", num2str(roundn(p_Odd_Dev_ManyStd_Dev, -4)));
        test_Str = strcat(" ", sigTestMethod, "[", num2str(sigTestWin(1)), " ", num2str(sigTestWin(2)), "]: ");
        title(strcat(devStr, test_Str, p_Str));
        end
        % legend
        AxesLegend = mSubplot(Fig(cIndex), legendRows, compareCol, (legendRows-1) * compareCol + pIndex, [1, 1], [0, 0, 0.01, 0], [paddings(1), paddings(2), 0, 0]); 
        set(AxesLegend, "Visible", "off");
        legend(AxesLegend, flip(AxesPSTH(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
    end

    %% LFP Comparison
    for pIndex = 1 : compareGroupN
        for sIndex = 1 : 2
        compareIdx = pIndex + compareGroupN * PSTH_CompareSize(1);
        posIndex = (nGeneral+sIndex-1) * compareCol + compareIdx;
        % Odd Dev vs Odd Std vs ManyStd Dev
        devStr = S1_S2(pIndex, sIndex);
        StdStr = S1_S2(pIndex, 2-sIndex+1);
        Odd_Dev_Index = cell2mat(cellfun(@(x) strcmpi(x(2), devStr)&~strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "-")), stimStr, "uni", false)', "UniformOutput", false));
        MantStd_Dev_Index = cell2mat(cellfun(@(x) strcmpi(x(2), devStr)&strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "-")), stimStr, "uni", false)', "UniformOutput", false));
        Odd_Std_Index = cell2mat(cellfun(@(x) strcmpi(x(2), StdStr)&~strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "-")), stimStr, "uni", false)', "UniformOutput", false));
        AxesLFP(sIndex, pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
        % Odd Dev
        X = lfpTemp{Odd_Dev_Index, 1}(:, 1);
        Y = lfpTemp{Odd_Dev_Index, 1}(:, 2);
        plot(AxesLFP(sIndex, pIndex), X, Y, "Color", colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on
        
        % ManyStd Dev
        X = lfpTemp{MantStd_Dev_Index, 1}(:, 1);
        Y = lfpTemp{MantStd_Dev_Index, 1}(:, 2);
        plot(AxesLFP(sIndex, pIndex), X, Y, "Color", colors(3), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on

        % Odd Std
        X = lfpTemp{Odd_Std_Index, 1}(:, 1) + diff(Std_Dev_Onset(Odd_Std_Index, end-1:end));
        Y = lfpTemp{Odd_Std_Index, 1}(:, 2);
        plot(AxesLFP(sIndex, pIndex), X, Y, "Color", colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(3)); hold on
        
        title(strcat(devStr, " ", strjoin(legendStr, " vs ")));
        end
        % legend
        AxesLegend = mSubplot(Fig(cIndex), legendRows, compareCol, (legendRows-1) * compareCol + compareIdx, [1, 1], [0, 0, 0.01, 0], [paddings(1), paddings(2), 0, 0]); 
        set(AxesLegend, "Visible", "off");
        legend(AxesLegend, flip(AxesLFP(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
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
end

end