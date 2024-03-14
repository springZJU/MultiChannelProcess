function Fig = MLA_PlotRasterLfp_Intrinsic(chSpikeLfp, CTLParams)


parseStruct(CTLParams);

colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).chSPK);
nGeneral = 4;
legendRows = 12;


for cIndex = 1 : chNum
    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.1, 0.01];

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
        
        %% ROW2: spike ACF
        pIndex = colMax + dIndex;
        Axes(dIndex, 2) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = [0, 1; chSpikeLfp(dIndex).chSPK(cIndex).spkACG];
        spkAcgTemp{dIndex, 1} = temp;
        plot(temp(:, 1), temp(:, 2), "Color", "black", "LineStyle", "-", "LineWidth", 1); hold on;
        plot([0, chSpikeLfp(dIndex).chSPK(cIndex).acgSpkTime], [1/exp(1), 1/exp(1)], "k--"); hold on
        plot([1, 1] * chSpikeLfp(dIndex).chSPK(cIndex).acgSpkTime, [min(temp(:, 2)), 1/exp(1)], "k--"); hold on

        title(strcat(chStr, "tau=",  num2str(chSpikeLfp(dIndex).chSPK(cIndex).acgSpkTime)));

        %% ROW3: whole time lfp
        pIndex = 2 * colMax + dIndex;
        Axes(dIndex, 3) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
        lfpTemp{dIndex, 1} = chSpikeLfp(dIndex).chLFP(cIndex).Wave;
        plot(lfpTemp{dIndex, 1}(:, 1), lfpTemp{dIndex, 1}(:, 2), "Color", "red", "LineWidth", 1, "LineStyle", "-", "LineWidth", 1.5); hold on;


        %% ROW4: lfp ACF
        pIndex = 3 * colMax + dIndex;
        Axes(dIndex, 4) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = [0, 1; chSpikeLfp(dIndex).chLFP(cIndex).lfpACG];
        lfpAcgTemp{dIndex, 1} = temp;
        plot(temp(:, 1), temp(:, 2), "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
        plot([0, chSpikeLfp(dIndex).chLFP(cIndex).acgLfpTime], [1/exp(1), 1/exp(1)], "k--"); hold on
        plot([1, 1] * chSpikeLfp(dIndex).chLFP(cIndex).acgLfpTime, [min(temp(:, 2)), 1/exp(1)], "k--"); hold on
        title(strcat(chStr, "tau=",  num2str(chSpikeLfp(dIndex).chLFP(cIndex).acgLfpTime)));
    end

    %% spk ACF Comparison
    Compare_Index = Compare_Index(cell2mat(cellfun(@(x) any(ismember(1 : colMax, x)), Compare_Index, "UniformOutput", false)));
    compareGroupN = length(Compare_Index);
    compareCol = (PSTH_CompareSize(1) + LFP_CompareSize(1)) * compareGroupN;
    for pIndex = 1 : compareGroupN
        posIndex = nGeneral * compareCol + pIndex;
        AxesSpkACG(pIndex) = mSubplot(Fig, plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
        idxs = Compare_Index{pIndex, 1};
        for dIndex = 1 : length(idxs)
            X = spkAcgTemp{idxs(dIndex), 1}(:, 1);
            Y = spkAcgTemp{idxs(dIndex), 1}(:, 2);
            plot(AxesSpkACG(pIndex), X, Y, "Color", colors(dIndex), "LineWidth", 1, "LineStyle", "-", "DisplayName", stimStr(idxs(dIndex))); hold on
            plot(AxesSpkACG(pIndex), [0, chSpikeLfp(dIndex).chSPK(cIndex).acgSpkTime], [1/exp(1), 1/exp(1)], "k--"); hold on
            plot(AxesSpkACG(pIndex), [1, 1] * chSpikeLfp(dIndex).chSPK(cIndex).acgSpkTime, [min(Y), 1/exp(1)], "LineStyle", "--", "Color", colors(dIndex)); hold on

        end
        title(strjoin(stimStr(idxs), "-"));

        % legend
        AxesLegend = mSubplot(Fig, legendRows, compareCol, (legendRows-1) * compareCol + pIndex, [1, 1], [0, 0, 0.01, 0], [paddings(1), paddings(2), 0, 0]);
        set(AxesLegend, "Visible", "off");
        legend(AxesLegend, flip(AxesSpkACG(pIndex).Children(matches({AxesSpkACG(pIndex).Children.DisplayName}', stimStr))), "NumColumns", ceil(length(idxs)/2), "FontSize", legendFontSize);    end

    %% LFP ACF Comparison
    for pIndex = 1 : compareGroupN
        compareIdx = pIndex + compareGroupN * PSTH_CompareSize(1);
        posIndex = nGeneral * compareCol + compareIdx;
        AxesLFPACG(pIndex) = mSubplot(Fig, plotRows, compareCol, posIndex, LFP_CompareSize, margins, paddings, "alignment", "top-left");
        idxs = Compare_Index{pIndex, 1};
        for dIndex = 1 : length(idxs)
            X = lfpAcgTemp{idxs(dIndex), 1}(:, 1);
            Y = lfpAcgTemp{idxs(dIndex), 1}(:, 2);
            plot(AxesLFPACG(pIndex), X, Y, "Color", colors(dIndex), "LineStyle", "-", "DisplayName", stimStr(idxs(dIndex))); hold on;
            plot(AxesLFPACG(pIndex), [0, chSpikeLfp(dIndex).chLFP(cIndex).acgLfpTime], [1/exp(1), 1/exp(1)], "k--"); hold on
            plot(AxesLFPACG(pIndex), [1, 1] * chSpikeLfp(dIndex).chLFP(cIndex).acgLfpTime, [min(Y), 1/exp(1)], "LineStyle", "--", "Color", colors(dIndex)); hold on
        end
        title(strjoin(stimStr(idxs), "-"));
        % legend
        AxesLegend = mSubplot(Fig, legendRows, compareCol, (legendRows-1) * compareCol + compareIdx, [1, 1], [0, 0, 0, 0], [paddings(1), paddings(2), 0, 0]);
        set(AxesLegend, "Visible", "off");
        legend(AxesLegend, flip(AxesLFPACG(pIndex).Children(matches({AxesLFPACG(pIndex).Children.DisplayName}', stimStr))), "NumColumns", ceil(length(idxs)/2), "FontSize", legendFontSize);    end



    %% scale
    for rIndex = [1, 3]
        scaleAxes(Axes(:, rIndex), "x", plotWin);
    end
    for rIndex = [2, 4]
        scaleAxes(Axes(:, rIndex), "x", acfWin);
    end
    for rIndex = 1 : 3
        scaleAxes(Axes(:, rIndex), "y", "on");
    end

    scaleAxes(AxesSpkACG, "x", compareWin);
    scaleAxes(AxesLFPACG, "x", compareWin);
    scaleAxes(AxesSpkACG, "y", "on");
    scaleAxes(AxesLFPACG, "y", "on");
    drawnow;
    FIGPATH = evalin("caller", "FIGPATH");
    spikeDataset = evalin("caller", "spikeDataset");
    print(Fig, strcat(FIGPATH, "CH", num2str(spikeDataset(cIndex).ch)), "-djpeg", "-r300");
    close(Fig);

end

end