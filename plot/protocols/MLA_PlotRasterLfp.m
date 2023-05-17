function Fig = MLA_PlotRasterLfp(chSpikeLfp, window, stimStr)


colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).spikeLfp);

for cIndex = 1 : chNum
        Fig(cIndex) = figure;
        maximizeFig(Fig(cIndex));
        rowMax = 5;
        margins = [0.05, 0.05, 0.1, 0.1];
        paddings = [0.01, 0.03, 0.01, 0.01];
        trialNum = length(chSpikeLfp(1).spikeLfp(cIndex).trialSpike);

    for dIndex = 1 : colMax
        %% ROW1: whole time raster plot
        pIndex = dIndex;
        mSubplot(Fig(cIndex), rowMax, colMax, pIndex, [1, 1], margins, paddings);
        ch = chSpikeLfp(dIndex).spikeLfp(cIndex).ch;
        temp = chSpikeLfp(dIndex).spikeLfp(cIndex).spikePlot;
        t =temp(:, 1);
        scatter(t, temp(:,2), 10, "black", "filled"); hold on
        xlim(window);
%         title(strcat("CH", num2str(ch), " ", stimStr(dIndex), " raster plot, n = ",  num2str(trialNum)));
        title(stimStr(dIndex));


        %% ROW2: whole time psth
        pIndex = colMax + dIndex;
        mSubplot(Fig(cIndex), rowMax, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).spikeLfp(cIndex).PSTH;
        temp = smoothdata(temp,'gaussian',25);
        t =temp(:, 1);
        plot(t, temp(:, 2), "Color", "black", "LineStyle", "-", "LineWidth", 1.5); hold on;
        xlim([t(1), t(end)]);
%         title(strcat("CH", num2str(ch), " ", stimStr(dIndex), " PSTH plot, n = ",  num2str(trialNum)));
        title(strcat("CH", num2str(ch), " n=",  num2str(trialNum)));

        %% ROW3: whole time lfp
        pIndex = 4 * colMax + dIndex;
        mSubplot(Fig(cIndex), rowMax, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).spikeLfp(cIndex).meanLFP;
        t = linspace(window(1), window(2), size(temp, 2));
        %                 for tIndex = 1 : length(trialsLfp{dIndex})
        %                     temp2 = chSpikeLfp{dIndex, 1}(cIndex).trialsLfp(cIndex, :);
        %                     plot(t, temp2, "Color", "#AAAAAA", "LineStyle", "-", "LineWidth", 1.5); hold on;
        %                 end
        plot(t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
        xlim([t(1), t(end)]);
%         title(strcat("CH", num2str(ch), " ", stimStr(dIndex), " mean LFP plot, n = ",  num2str(trialNum)));
%         title(strcat("n = ",  num2str(trialNum)));

        %% ROW4: zoom in raster plot
        pIndex = 2 * colMax + dIndex;
        mSubplot(Fig(cIndex), rowMax, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).spikeLfp(cIndex).spikePlot;
        t =temp(:, 1);
        scatter(t, temp(:,2), 10, "black", "filled"); hold on
        xlim([-1000 1000]);
%         title(strcat("CH", num2str(ch), " ", stimStr(dIndex), " zoomed in raster plot, n = ",  num2str(trialNum)));

        %% ROW5: zoom in psth
        pIndex = 3 * colMax + dIndex;
        mSubplot(Fig(cIndex), rowMax, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).spikeLfp(cIndex).PSTH;
        temp = smoothdata(temp,'gaussian',25);
        t =temp(:, 1);
        plot(t, temp(:, 2), "Color", "black", "LineStyle", "-", "LineWidth", 1.5); hold on;
        xlim([-1000 1000]);
%         title(strcat("CH", num2str(ch), " ", stimStr(dIndex), " zoomed in PSTH plot, n = ",  num2str(trialNum)));

    end

    % add vertical line
    lines(1).X = 0;
    lines(1).color = "red";
    addLines2Axes(Fig(cIndex), lines);

    % scale y
    Axes = findobj(Fig(cIndex), "Type", "axes");
    for rIndex = 1 : rowMax
        scaleAxes(Axes(rIndex : rowMax : rowMax * colMax), "y", "on");
    end

    drawnow;
end


end