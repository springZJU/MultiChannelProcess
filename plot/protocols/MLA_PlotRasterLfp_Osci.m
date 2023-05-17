function Fig = MLA_PlotRasterLfp_Osci(chSpikeLfp, CTLParams)


CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end

colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).chSPK);
nGeneral = 4;

if ~toPlotFFT
    nGeneral = nGeneral - 1;
    plotRows = plotRows - 1;
end


for cIndex = 1 : chNum
    Fig(cIndex) = figure;
    maximizeFig(Fig(cIndex));
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];

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


        %% ROW4: FFT
        if toPlotFFT
            pIndex = (nGeneral-1) * colMax + dIndex;
            Axes(dIndex, nGeneral) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
            temp = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 2);
            t = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 1);
            plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
            
            xlim([0 100]);
        end

    end

    % add vertical line
    lines = [];
    lines(1).X = 0;
    lines(1).color = "red";
    addLines2Axes(Fig(cIndex), lines);

    %% Rayleigh statistics
    pIndex= 1;
    for dIndex = 1 : colMax
        RS(dIndex, 1) = chSpikeLfp(dIndex).chSPK(cIndex).chRS;
    end
    posIndex = nGeneral * compareCol + pIndex;
    AxesRS(pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, [compareCol, plotRows-nGeneral], margins, paddings, "alignment", "top-left");
    plot(1 : colMax, RS, "r-", "LineWidth", 2); hold on;
    scatter(1 : colMax, RS, 20, "red", "filled"); hold on
    plot([1, colMax], [13.8, 13.8], "b--"); hold on
    set(AxesRS(pIndex), "XTickLabel", stimStr);
    title("Rayleigh statistics");
    %% scale
    for rIndex = 1 : 3
        scaleAxes(Axes(:, rIndex), "x", plotWin);
    end
    for rIndex = 1 : nGeneral
        scaleAxes(Axes(:, rIndex), "y", "on");
    end

    drawnow;
end
end