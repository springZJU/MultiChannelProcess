function RNP_PlotRasterSpike_ClickTrain_Tuning(FIGPATH, chSpikeLfp, window, stimStr, colors)

rowMax = 3;
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];
% chSelect = 38; % responding to chinfo
colMax = length(chSpikeLfp);
chNum = length(chSpikeLfp(1).chSPK);

allpsth.psth = cell(length(chSpikeLfp), 1);
allpsth.legend = cell(length(chSpikeLfp), 1);

for cIndex = 1 : chNum
    Fig = figure;
    maximizeFig(Fig);

    for dIndex = 1 : colMax   % types
        chinfo = chSpikeLfp(dIndex).chSPK(cIndex).info;

        %         if sum ( ismember(chSelect, str2num(cell2mat(regexp(chinfo,'\d*\.?\d*','match'))) ) ) ~= 0

        %% ROW1: whole time raster plot
        pIndex = dIndex;
        mSubplot(Fig, rowMax, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).spikePlot;
        if ~isempty(temp)
            scatter(temp(:, 1), temp(:,2), 10, "black", "filled"); hold on;
            xlim(window);
            title(strcat(chinfo, " ", stimStr(dIndex), " raster, n = ",  num2str(chSpikeLfp(dIndex).trialNum)));
        end

        %% ROW2: whole time psth
        pIndex = colMax + dIndex;
        mSubplot(Fig, rowMax, colMax, pIndex, [1, 1], margins, paddings);
        temp = chSpikeLfp(dIndex).chSPK(cIndex).PSTH;
        temp = smoothdata(temp,'gaussian',25);
        t =temp(:, 1);
        plot(t, temp(:, 2), "Color", "black", "LineStyle", "-", "LineWidth", 1.5); hold on;
        xlim([t(1), t(end)]);

        %% ROW3: integrate in psth
        allpsth.psth{dIndex, 1} = temp ;
        allpsth.legend{dIndex, 1} = stimStr(dIndex) ;
        allpsth.color{dIndex, 1} = colors(dIndex) ;

        %% Row3: tuning
        allpsth.Fr0_50(dIndex, 1) = mean(chSpikeLfp(dIndex).chSPK(cIndex).Fr0_50) ;
        allpsth.Fr0_50(dIndex, 2) = std(chSpikeLfp(dIndex).chSPK(cIndex).Fr0_50)/length(chSpikeLfp(dIndex).chSPK(cIndex).Fr0_50) ;
        allpsth.Fr200_250(dIndex, 1) = mean(chSpikeLfp(dIndex).chSPK(cIndex).Fr200_250) ;
        allpsth.Fr200_250(dIndex, 2) = std(chSpikeLfp(dIndex).chSPK(cIndex).Fr200_250)/length(chSpikeLfp(dIndex).chSPK(cIndex).Fr200_250) ;
        allpsth.Fr50_200(dIndex, 1) = mean(chSpikeLfp(dIndex).chSPK(cIndex).Fr50_200) ;
        allpsth.Fr50_200(dIndex, 2) = std(chSpikeLfp(dIndex).chSPK(cIndex).Fr50_200)/length(chSpikeLfp(dIndex).chSPK(cIndex).Fr50_200) ;
        allpsth.Fr0_250(dIndex, 1) = mean(chSpikeLfp(dIndex).chSPK(cIndex).Fr0_250) ;
        allpsth.Fr0_250(dIndex, 2) = std(chSpikeLfp(dIndex).chSPK(cIndex).Fr0_250)/length(chSpikeLfp(dIndex).chSPK(cIndex).Fr0_250) ;

        % add vertical line
        lines(1).X = 0;
        lines(1).color = "red";
        addLines2Axes(Fig, lines);

        %         end
    end

    %     if sum ( ismember(chSelect, str2num(cell2mat(regexp(chinfo,'\d*\.?\d*','match'))) ) ) ~= 0
    mSubplot(Fig, rowMax, colMax, (rowMax-1)* colMax + 2 , [3, 1], margins, paddings);
    hold on;
    cellfun(@(x, y, z) plot( x(:, 1), x(:, 2), 'DisplayName', y, "LineWidth", 1.5, 'Color', z), allpsth.psth, allpsth.legend, allpsth.color); hold on;
    xlim([t(1), t(end)]); legend;
    mSubplot(Fig, rowMax, colMax, (rowMax-1)* colMax + 6, [3, 1], margins, paddings);
    errorbar(allpsth.Fr0_250(:, 1), allpsth.Fr0_250(:, 2), 'color', 'r', 'LineWidth', 2); hold on;
%     errorbar(allpsth.Fr200_250(:, 1), allpsth.Fr200_250(:, 2), 'color', 'b', 'LineWidth', 2); hold on;
%     errorbar(allpsth.Fr50_200(:, 1), allpsth.Fr50_200(:, 2), 'color', 'k', 'LineWidth', 2); hold on;
    xticks(1:length(stimStr));
    xticklabels(stimStr);
%     legend('Win: [0 80]', 'Win: [200 280]', 'Win: [80 200]');
    legend('Win: [0 250]');
    print(Fig, strcat(FIGPATH, '\', chinfo), "-djpeg", "-r300");
    %     end
    close(Fig);
end
