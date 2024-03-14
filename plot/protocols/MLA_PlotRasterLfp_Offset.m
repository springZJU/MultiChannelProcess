function Fig = MLA_PlotRasterLfp_Offset(chSpikeLfp, CTLParams)


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
    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.12, 0.1];
    paddings = [0.01, 0.03, 0.05, 0.01];

    for dIndex = 1 : colMax

        trialNum = chSpikeLfp(dIndex).trialNum;
        chStr = chSpikeLfp(dIndex).chLFP(cIndex).info;
        %% ROW1: whole time raster plot
        pIndex = dIndex;
        Axes(dIndex, 1) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).spikePlot;
        t =temp(:, 1);
        trialN = arrayRep(temp(:, 2), unique(temp(:, 2)), 1 : length(unique(temp(:, 2))));
        scatter(t, trialN, 10, "black", "filled"); hold on
        title(stimStr(dIndex));

        %% ROW2: whole time psth
        pIndex = colMax + dIndex;
        Axes(dIndex, 2) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).PSTH;
        t =temp(:, 1);
        PSTH = smoothdata(temp(: ,2),'gaussian',25);
        psthTemp{dIndex, 1} = [t, PSTH];
        plot(t, PSTH, "Color", "black", "LineStyle", "-", "LineWidth", 1); hold on;
        title(strcat(chStr, " n=",  num2str(trialNum)));

        %% ROW3: whole time lfp
        pIndex = 2 * colMax + dIndex;
        Axes(dIndex, 3) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
        lfpTemp{dIndex, 1} = chSpikeLfp(dIndex).chLFP(cIndex).Wave;
        plot(lfpTemp{dIndex, 1}(:, 1), lfpTemp{dIndex, 1}(:, 2), "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;


        %% ROW4: FFT
        if toPlotFFT
            pIndex = (nGeneral-1) * colMax + dIndex;
            Axes(dIndex, nGeneral) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
            temp = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 2);
            t = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 1);
            plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
            xlim([0 300]);
        end
    end

    %% PSTH Comparison
    Compare_Index = Compare_Index(cell2mat(cellfun(@(x) any(ismember(1 : colMax, x)), Compare_Index, "UniformOutput", false)));
    compareGroupN = length(Compare_Index);
    compareCol = (PSTH_CompareSize(1) + LFP_CompareSize(1)) * compareGroupN;
    for pIndex = 1 : compareGroupN
        posIndex = nGeneral * compareCol + pIndex;
        AxesPSTH(pIndex) = mSubplot(Fig, plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
        idxs = Compare_Index{pIndex, 1};
        for dIndex = 1 : length(idxs)
            X = psthTemp{idxs(dIndex), 1}(:, 1);
            Y = psthTemp{idxs(dIndex), 1}(:, 2);
            plot(AxesPSTH(pIndex), X, Y, "Color", colors(dIndex), "LineWidth", 1, "LineStyle", "-", "DisplayName", stimStr(idxs(dIndex))); hold on
        end
        title(strjoin(stimStr(idxs), "-"));

        % legend
        AxesLegend = mSubplot(Fig, legendRows, compareCol, (legendRows-1) * compareCol + pIndex, [1, 1], [0, 0, 0.01, 0], [paddings(1), paddings(2), 0, 0]); 
        set(AxesLegend, "Visible", "off");
        legend(AxesLegend, flip(AxesPSTH(pIndex).Children), "NumColumns", ceil(length(idxs)/2), "FontSize", legendFontSize);
    end

    %% LFP Comparison
    for pIndex = 1 : compareGroupN
        compareIdx = pIndex + compareGroupN * PSTH_CompareSize(1);
        posIndex = nGeneral * compareCol + compareIdx;
        AxesLFP(pIndex) = mSubplot(Fig, plotRows, compareCol, posIndex, LFP_CompareSize, margins, paddings, "alignment", "top-left");
        idxs = Compare_Index{pIndex, 1};
        for dIndex = 1 : length(idxs)
            X = lfpTemp{idxs(dIndex), 1}(:, 1);
            Y = lfpTemp{idxs(dIndex), 1}(:, 2);
            plot(AxesLFP(pIndex), X, Y, "Color", colors(dIndex), "LineWidth", 1, "LineStyle", "-", "DisplayName", stimStr(idxs(dIndex))); hold on;
        end
        title(strjoin(stimStr(idxs), "-"));
        % legend
        AxesLegend = mSubplot(Fig, legendRows, compareCol, (legendRows-1) * compareCol + compareIdx, [1, 1], [0, 0, 0, 0], [paddings(1), paddings(2), 0, 0]); 
        set(AxesLegend, "Visible", "off");
        legend(AxesLegend, flip(AxesLFP(pIndex).Children), "NumColumns", ceil(length(idxs)/2), "FontSize", legendFontSize);
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
    scaleAxes(AxesPSTH, "x", [-100, 300]);
    scaleAxes(AxesLFP, "x", [-100, 300]);
    scaleAxes(AxesPSTH, "y", "on");
    scaleAxes(AxesLFP, "y", "on");

    %% Rayleigh statistics
    compareIdx = compareGroupN * (PSTH_CompareSize(1) + LFP_CompareSize(1)) + 1;
    for dIndex = 1 : colMax
        RS(dIndex, 1) = chSpikeLfp(dIndex).chSPK(cIndex).chRS;
    end
    posIndex = nGeneral * compareCol + compareIdx;
    AxesRS(pIndex) = mSubplot(Fig, plotRows, compareCol, posIndex, [compareCol-compareIdx+ 1, LFP_CompareSize(2)], margins, paddings, "alignment", "top-left");
    plot(1 : colMax, RS, "r-", "LineWidth", 2); hold on;
    scatter(1 : colMax, RS, 20, "red", "filled"); hold on
    plot([1, colMax], [13.8, 13.8], "b--"); hold on
    set(AxesRS(pIndex), "XTick", 1 : colMax)
    set(AxesRS(pIndex), "XTickLabel", stimStr);
    title("Rayleigh statistics");
    drawnow;
    FIGPATH = evalin("caller", "FIGPATH");
    spikeDataset = evalin("caller", "spikeDataset");
    print(Fig, strcat(FIGPATH, "CH", num2str(spikeDataset(cIndex).ch)), "-djpeg", "-r300");
    close(Fig);
end

end