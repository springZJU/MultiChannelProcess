function Fig = MLA_PlotRasterLfp_TITSinsert(chSpikeLfp, CTLParams)
CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).chSPK);
% plot params setting
nGeneral = 3;
plotRows = 5;
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

        % After Change Spike Counts
        tIndex = t >= sigTestWin(1) & t<= sigTestWin(2);
        selSpikes = temp(tIndex, 2);
        AfterChange_FR{dIndex, 1} = [hist(selSpikes,unique(selSpikes))' / diff(sigTestWin) * 1000; zeros(trialNum-length(unique(selSpikes)), 1)];
        % Before Change Spike Counts
        winTemp = sigTestWin - diff(sigTestWin);
        tIndex = t >= winTemp(1) & t<= winTemp(2);
        selSpikes = temp(tIndex, 2);
        BeforeChange_FR{dIndex, 1} = [hist(selSpikes,unique(selSpikes))'/ diff(sigTestWin) * 1000; zeros(trialNum-length(unique(selSpikes)), 1)];
        % significance test
        if strcmpi(sigTestMethod, "ranksum")
            p_Change = ranksum(AfterChange_FR{dIndex, 1}, BeforeChange_FR{dIndex, 1});
        elseif strcmpi(sigTestMethod, "ttest2")
            [~, p_Change] = ttest2(AfterChange_FR{dIndex, 1}, BeforeChange_FR{dIndex, 1});
        else
            error("Unitiated method!")
        end
        p_Str = strcat("p-Change = ", num2str(roundn(p_Change, -4)));
        test_Str = strcat(" ", sigTestMethod, "[", num2str(sigTestWin(1)), " ", num2str(sigTestWin(2)), "]: ");
        title(strcat(stimStrs(dIndex), test_Str, p_Str));

        %% ROW2: whole time psth
        pIndex = colMax + dIndex;
        Axes(dIndex, 2) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).PSTH;
        t =temp(:, 1);
        PSTH = smoothdata(temp(: ,2),'gaussian',25);
        psthTemp{dIndex, 1} = [t, PSTH];
        plot(t, PSTH, "Color", "black", "LineStyle", "-", "LineWidth", 1); hold on;
        title(strcat(chStr, " n=",  num2str(trialNum)));

        %% ROW3-1: whole time lfp
        pIndex = 2 * 2 * colMax + 2 * dIndex - 1;
        Axes(dIndex, 3) = mSubplot(Fig(cIndex), plotRows, 2 * colMax, pIndex, [1, 1], margins, paddings);
        lfpTemp{dIndex, 1} = chSpikeLfp(dIndex).chLFP(cIndex).Wave;
        plot(lfpTemp{dIndex, 1}(:, 1), lfpTemp{dIndex, 1}(:, 2), "Color", "red", "LineWidth", 1, "LineStyle", "-", "LineWidth", 1.5); hold on;

        %% ROW3-2: FFT
        temp = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 2);
        t = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 1);
        pIndex = 2 * 2 * colMax + 2 * dIndex;

        % local
        Axes(dIndex, 4) = mSubplot(Fig(cIndex), plotRows, 2 * colMax, pIndex, [1, 1], margins, paddings);
        plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
        xlim([0 1000 / BaseICI + 50]);
        title(strcat("FFTWin[", string(FFTWin(1)), ",", string(FFTWin(2)), "]"));
        
    end

    %% PSTH Comparison
    compareGroupN = length(GroupTypes);
    compareCol = compareGroupN + 1;
    for pIndex = 1 : compareGroupN
        controlIdx = GroupTypes{pIndex}(1);
        compareIdx = GroupTypes{pIndex}(2);
        legendStr = [stimStrs(controlIdx), stimStrs(compareIdx)];
        posIndex = nGeneral * compareCol + pIndex + 1;

        % control vs Insert
        AxesPSTH(pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
        % control
        X = psthTemp{controlIdx, 1}(:, 1);
        Y = psthTemp{controlIdx, 1}(:, 2);
        plot(AxesPSTH(pIndex), X, Y, "Color", Colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on;
        % Insert
        X = psthTemp{compareIdx, 1}(:, 1);
        Y = psthTemp{compareIdx, 1}(:, 2);
        plot(AxesPSTH(pIndex), X, Y, "Color", Colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on
        title(strcat(legendStr(1), " vs ", legendStr(2)));

        % legend
        legend(AxesPSTH(pIndex), flip(AxesPSTH(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
    end

    %% LFP Comparison
    for pIndex = 1 : compareGroupN
        controlIdx = GroupTypes{pIndex}(1);
        compareIdx = GroupTypes{pIndex}(2);
        legendStr = [stimStrs(controlIdx), stimStrs(compareIdx)];
        posIndex = (nGeneral+1) * compareCol + pIndex + 1;

        % Odd Dev vs Odd Std
        AxesLFP(pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, LFP_CompareSize, margins, paddings, "alignment", "top-left");
        % Odd Dev
        X = lfpTemp{controlIdx, 1}(:, 1);
        Y = lfpTemp{controlIdx, 1}(:, 2);
        plot(AxesLFP(pIndex), X, Y, "Color", Colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on

        % Odd Std
        X = lfpTemp{compareIdx, 1}(:, 1);
        Y = lfpTemp{compareIdx, 1}(:, 2);
        plot(AxesLFP(pIndex), X, Y, "Color", Colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on
        title(strcat(strjoin(legendStr, " vs ")));

        % legend
        legend(AxesLFP(pIndex), flip(AxesLFP(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
    end
    %% scale
    for rIndex = [1, 2, 3]
        scaleAxes(Axes(:, rIndex), "x", plotWin);
    end

    for rIndex = 1 : size(Axes, 2)
        scaleAxes(Axes(:, rIndex), "y", "on");
    end

    scaleAxes(AxesPSTH, "x", compareWin);
    scaleAxes(AxesLFP, "x", compareWin);
    scaleAxes(AxesPSTH, "y", "on");
    scaleAxes(AxesLFP, "y", "on");

    % add vertical line
    lines = [];
    lines(1).X = 1000 / BaseICI; lines(1).color = 'b';
    addLines2Axes(Axes(:, 4), lines);

    lines = [];
    lines(1).X = 0;
    lines(1).color = "red";
    for aIndex = 1 : size(Axes, 2)
        addLines2Axes(Axes(:, aIndex), lines);
    end
    addLines2Axes(AxesLFP, lines);
    addLines2Axes(AxesPSTH, lines);

    drawnow;
    pause(2);
    print(Fig(cIndex), strcat(FIGPATH, chSpikeLfp(dIndex).chSPK(cIndex).info, ".jpg"), "-djpeg", "-r200");
end
close all;

end