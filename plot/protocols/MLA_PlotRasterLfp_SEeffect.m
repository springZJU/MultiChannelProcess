function Fig = MLA_PlotRasterLfp_SEeffect(chSpikeLfp, CTLParams)
CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
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
        title(strrep(stimStrs(dIndex), "_", "-"));

        % Spike Counts for sigtest
        tIndex = t >= ChangeTime(dIndex) + sigTestWin(1) & t<= ChangeTime(dIndex) + sigTestWin(2);
        selSpikes = temp(tIndex, 2);
        All_FR{dIndex, 1} = [hist(selSpikes,unique(selSpikes))' / diff(sigTestWin) * 1000; zeros(trialNum-length(unique(selSpikes)), 1)];

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

        %% ROW4: CWT
        temp = chSpikeLfp(dIndex).chLFP(cIndex).cwt;
        t = chSpikeLfp(dIndex).chLFP(cIndex).cwt_time(:, 1);
        f = chSpikeLfp(dIndex).chLFP(cIndex).cwt_f(:, 1);
        t_idx = find(t > CWTplotWindow(1) & t < CWTplotWindow(2));
        t_fsD_win = t(t_idx);
        pIndex = 3 * colMax + dIndex;   
        Axes(dIndex, 4) = mSubplot(Fig(cIndex), plotRows, colMax, pIndex, [1, 1], margins, paddings);
        imagesc('XData', t_fsD_win, 'YData', f, 'CData', temp);
        colormap("jet");
        hold on;

    end

    %% PSTH Comparison
    compareGroupN = length(GroupTypes);
    compareCol = compareGroupN + 1;
    for pIndex = 1 : compareGroupN
        Control_Index = GroupTypes{pIndex}(1);
        Compare_Index = GroupTypes{pIndex}(2);
        for sIndex = 1
        legendStr = [stimStrs(Control_Index), stimStrs(Compare_Index)];
        posIndex = (nGeneral+sIndex-1) * compareCol + pIndex + 1;
        % Control vs change
        AxesPSTH(pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "top-left");
        % Control
        X = psthTemp{Control_Index, 1}(:, 1);
        Y = psthTemp{Control_Index, 1}(:, 2);
        plot(AxesPSTH(pIndex), X, Y, "Color", colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on
        % Compare
        X = psthTemp{Compare_Index, 1}(:, 1);
        Y = psthTemp{Compare_Index, 1}(:, 2);
        plot(AxesPSTH(pIndex), X, Y, "Color", colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on
        
        % significance test
        % Control vs Change
        if strcmpi(sigTestMethod, "ranksum")
            p_Odd_Dev_Std = ranksum(All_FR{Control_Index}, All_FR{Compare_Index});
        elseif strcmpi(sigTestMethod, "ttest2")
            [~, p_Odd_Dev_Std] = ttest2(All_FR{Control_Index}, All_FR{Compare_Index});
        else
            error("Unitiated method!")
        end
        p_Str = strcat("p = ", num2str(roundn(p_Odd_Dev_Std, -4)));
        test_Str = strcat(sigTestMethod, "[", num2str(sigTestWin(1)), " ", num2str(sigTestWin(2)), "]: ");
        title(strcat(test_Str, p_Str));
        end
        % legend
%         legend(AxesPSTH(pIndex), flip(AxesPSTH(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
    end

    %% LFP Comparison
    for pIndex = 1 : compareGroupN
        Control_Index = GroupTypes{pIndex}(1);
        Compare_Index = GroupTypes{pIndex}(2);
        for sIndex = 2
        legendStr = [strrep(stimStrs(Control_Index), "_", "-"), strrep(stimStrs(Compare_Index), "_", "-")];
        posIndex = (nGeneral+sIndex-1) * compareCol + pIndex + 1;
        % Control vs Change
        AxesLFP(pIndex) = mSubplot(Fig(cIndex), plotRows, compareCol, posIndex, LFP_CompareSize, margins, paddings, "alignment", "top-left");
        % Control
        X = lfpTemp{Control_Index, 1}(:, 1);
        Y = lfpTemp{Control_Index, 1}(:, 2);
        plot(AxesLFP(pIndex), X, Y, "Color", colors(1), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(1)); hold on
        % Change
        X = lfpTemp{Compare_Index, 1}(:, 1);
        Y = lfpTemp{Compare_Index, 1}(:, 2);
        plot(AxesLFP(pIndex), X, Y, "Color", colors(2), "LineWidth", 1, "LineStyle", "-", "DisplayName", legendStr(2)); hold on
%         title(strcat(strjoin(legendStr, " vs ")));
        end
        % legend
%         legend(AxesLFP(pIndex), flip(AxesLFP(pIndex).Children), "NumColumns", ceil(length(legendStr)/2), "FontSize", legendFontSize);
    end

    %% scale
    for rIndex = 1 : 3
        scaleAxes(Axes(:, rIndex), "x", plotWindow);
    end
    for rIndex = 1 : 3
        scaleAxes(Axes(:, rIndex), "y", "on");
    end
    scaleAxes(AxesPSTH, "x", compareWindow);
    scaleAxes(AxesLFP, "x", compareWindow);
    scaleAxes(AxesPSTH, "y", "on");
    scaleAxes(AxesLFP, "y", "on");
    % add vertical line
    % add changetime lines
    lines = [];
    for dIndex = 1 : length(chSpikeLfp)
        lines(1).X  = ChangeTime(dIndex);
        lines(1).color  = "k";
        addLines2Axes(Axes(dIndex, 1:4), lines);
    end
    lines = [];
    for compareIdx = 1 : length(AxesPSTH)
        lines(1).X  = ChangeTime(compareIdx + 1);
        lines(1).color  = "k";
        addLines2Axes(AxesLFP(compareIdx), lines);
        addLines2Axes(AxesPSTH(compareIdx), lines);
    end
    % add 0 time line    
    lines = [];
    lines(1).X = 0;
    lines(1).color = "k";
    for aIndex = 1 : size(Axes, 2)
        addLines2Axes(Axes(:, aIndex), lines);
    end
    addLines2Axes(AxesLFP, lines);
    addLines2Axes(AxesPSTH, lines);

    drawnow;
    pause(2);
    print(Fig(cIndex), strcat(FIGPATH, chSpikeLfp(dIndex).chSPK(cIndex).info), "-djpeg", "-r200");
end
close all;

end