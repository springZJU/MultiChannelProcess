function Fig = MLA_PlotRasterLfp_BaoOffset2(chSpikeLfp, CTLParams)


parseStruct(CTLParams);

colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).chSPK);
nGeneral = 4;
legendRows = 3;

if ~toPlotFFT
    nGeneral = nGeneral - 1;
    plotRows = plotRows - 1;
end

OnsetWin = [0,100];
ChangeWin = [500,600];
OffsetWin = [1000,1100];

% for cIndex = 2
for cIndex = 1 : chNum
    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.14, 0.1];
    paddings = [0.01, 0.03, 0.2, 0.07];

    for dIndex = 1 : colMax

        trialNum = chSpikeLfp(dIndex).trialNum;
        chStr = chSpikeLfp(dIndex).chLFP(cIndex).info;
        %% ROW1: whole time raster plot
        pIndex = dIndex;
        Axes(dIndex, 1) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).spikePlot;
        [OnsetFr(dIndex),OnsetSE(dIndex)] = mBCalFR(temp,OnsetWin);
        [ChangeFr(dIndex),ChangeSE(dIndex)] = mBCalFR(temp,ChangeWin);
        [OffsetFr(dIndex),OffsetSE(dIndex)] = mBCalFR(temp,OffsetWin);
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
        plot(lfpTemp{dIndex, 1}(:, 1), lfpTemp{dIndex, 1}(:, 2), "Color", "red", "LineWidth", 1, "LineStyle", "-", "LineWidth", 1.5); hold on;


        %% ROW4: FFT
        if toPlotFFT
            pIndex = (nGeneral-1) * colMax + dIndex;
            Axes(dIndex, nGeneral) = mSubplot(Fig, plotRows, colMax, pIndex, [1, 1], margins, paddings);
            temp = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 2);
            t = chSpikeLfp(dIndex).chLFP(cIndex).FFT(:, 1);
            plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1); hold on;
            cursor = 1000 / BaseICI(dIndex);
            xlim([0 cursor*2]);
            ylim([0, max(temp(t>2))]);
            plot([1, 1]*cursor, [0, max(temp(t>2))], "LineStyle", "--");
        end
    end

    %% PSTH Comparison
    Compare_Index = Compare_Index(cell2mat(cellfun(@(x) any(ismember(1 : colMax, x)), Compare_Index, "UniformOutput", false)));
    compareGroupN = length(Compare_Index);
    compareCol = (PSTH_CompareSize(1) + LFP_CompareSize(1)) * compareGroupN;
    for pIndex = 1 : compareGroupN
        posIndex = nGeneral * compareCol + pIndex;
        AxesPSTH(pIndex) = mSubplot(Fig, plotRows, compareCol, posIndex, PSTH_CompareSize, margins, paddings, "alignment", "left-top");
        idxs = Compare_Index{pIndex, 1};
        for dIndex = 1 : length(idxs)
            if idxs(dIndex) > length(psthTemp)
                continue
            end
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
        AxesLFP(pIndex) = mSubplot(Fig, plotRows, compareCol, posIndex, LFP_CompareSize, margins, paddings, "alignment", "left-top");
        idxs = Compare_Index{pIndex, 1};
        for dIndex = 1 : length(idxs)
            if idxs(dIndex) > length(psthTemp)
                continue
            end
            X = lfpTemp{idxs(dIndex), 1}(:, 1);
            Y = lfpTemp{idxs(dIndex), 1}(:, 2);
            plot(AxesLFP(pIndex), X, Y, "Color", colors(dIndex), "LineStyle", "-", "DisplayName", stimStr(idxs(dIndex))); hold on;
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
    for rIndex = 1 : 3
        scaleAxes(Axes(:, rIndex), "y", "on");
    end

    scaleAxes(AxesPSTH, "x", compareWin);
    scaleAxes(AxesLFP, "x", compareWin);
    scaleAxes(AxesPSTH, "y", "on");
    scaleAxes(AxesLFP, "y", "on");
    drawnow;

    %% Plot Bar

    % Onset
    Newmargins = [0.01, 0.01, 0.01, 0.01];
    Newpaddings = [0.05, 0.05, 0.05, 0.01];
    mSubplot(6,5,26,[1,1],Newmargins,Newpaddings);
    errorbar(OnsetFr,OnsetSE,'LineWidth',1);
    title('Onset Compare');
    ylabel('Firing rate');
    xlim([0,6]);
    xticks([1:5]);
    xticklabels(stimStr);

    % Change
    Newmargins = [0.01, 0.01, 0.01, 0.01];
    Newpaddings = [0.05, 0.05, 0.05, 0.01];
    mSubplot(6,5,27,[1,1],Newmargins,Newpaddings);
    errorbar(ChangeFr,ChangeSE,'LineWidth',1);
    title('Change Compare');
    ylabel('Firing rate');
    xlim([0,6]);
    xticks([1:5]);
    xticklabels(stimStr);

    % Offset
    Newmargins = [0.01, 0.01, 0.01, 0.01];
    Newpaddings = [0.05, 0.05, 0.05, 0.01];
    mSubplot(6,5,28,[1,1],Newmargins,Newpaddings);
    errorbar(OffsetFr,OffsetSE,'LineWidth',1);
    title('Offset Compare');
    ylabel('Firing rate');
    xlim([0,6]);
    xticks([1:5]);
    xticklabels(stimStr);

    %% Save figures
    FIGPATH = evalin("caller", "FIGPATH");
    spikeDataset = evalin("caller", "spikeDataset");

    % 添加标题注释
    dim = [0.1 0.93 0.3 0.05];
    AnnoStr = '方案一 Adaptation';
    annotation('textbox',dim,'String',AnnoStr,'FitBoxToText','on','FontSize',20,'Color','r');
    dim = [0.4 0.93 0.3 0.05];
    thePun = split(FIGPATH,'\');
    thePun = thePun(end-1);
    AnnoStr = strrep(thePun,'_','-');
    annotation('textbox',dim,'String',AnnoStr,'FitBoxToText','on','FontSize',20,'Color','r');

    print(Fig, strcat(FIGPATH, "CH", num2str(spikeDataset(cIndex).ch)), "-djpeg", "-r150");
    close(Fig);
    
end

end