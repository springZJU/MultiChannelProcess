function spkPlotMMN(FIGPATH, chSpikeLfp, windowParams, ResaveFlag)
%% figure yes or not?
temp = dir(FIGPATH);
Exist_Single = any(contains(string({temp.name}), "CH"));
if all([Exist_Single])
    disp('The spike Figure of single channel already Exists.')
    if ~ResaveFlag
        return
    else
        disp("RePlot Figure ...")
    end
end
%% parameter
parseStruct(windowParams);
typeMax = length(chSpikeLfp); %  types
margins1 = [0, 0.05, 0, 0];
margins = [0, 0.02, 0.02, 0.02];
paddings = [0.02, 0.02, 0.02, 0.02];
switch typeMax
    case 14 % 4+2+1
        colorsLine = generateColorGrad(14,'rgb');
    case 12 % 5+1
        colors = generateColorGrad(6,'rgb','blue', 1:5,'black', 6);
        colorsLine = generateColorGrad(12,'rgb');
end

%% plot select channel
chNums = length(chSpikeLfp(1).chSPK);
chindSelect = 1:chNums;
mWaitbar = waitbar(0, ' plot channel...');
for chIndex = chindSelect
    waitbar(chIndex / length(chindSelect), mWaitbar, ['Plot ChIndex', num2str(chIndex), ' ing...']);
    Fig = figure;
    maximizeFig(Fig);
    ax1 = mSubplot(Fig, 6, 10, 10,'nSize',[2 0.8],'alignment','top-right', 'margins', margins, 'paddings', paddings);
    ax3 = mSubplot(Fig, 6, 10, 30,'nSize',[2 0.8],'alignment','top-right', 'margins', margins, 'paddings', paddings);
    ax5 = mSubplot(Fig, 6, 10, 50,'nSize',[2 0.8],'alignment','top-right', 'margins', margins, 'paddings', paddings);

    ax2 = mSubplot(Fig, 6, 10, 20,'nSize',[2 0.8],'alignment','top-right', 'margins', margins, 'paddings', paddings);
    ax4 = mSubplot(Fig, 6, 10, 40,'nSize',[2 0.8],'alignment','top-right', 'margins', margins, 'paddings', paddings);
    ax6 = mSubplot(Fig, 6, 10, 60,'nSize',[2 0.8],'alignment','top-right', 'margins', margins, 'paddings', paddings);

    for tIndex = 1 : typeMax
        chinfo = chSpikeLfp(tIndex).chSPK(chIndex).info;
        %% ROW1: all std time raster plot
        for i = 1:ratio(1)-1
            mSubplot(Fig, 40, 10, 10*(i-1)+1+mod((tIndex-1), 8)+200*floor((tIndex-1)/8), 'margins',margins1, 'paddings',paddings);
            spikePlot = cell2mat(chSpikeLfp(tIndex).chSPK(chIndex).(['Sti',num2str(i)]));
            if ~isempty(spikePlot)
                scatter(spikePlot(:, 1), spikePlot(:,2), 4, "filled", 'color', colorDec{1}); hold on;
                xlim(spkPlotWindow);
            end
            xticks(''); yticks('');
            if i == 1
                ylabel("std1");
                title(strcat(chSpikeLfp(tIndex).stimStr));
            end
        end
        %% ROW1: Std time raster
        mSubplot(Fig, 40, 10, 10*8+1+mod((tIndex-1), 8)+200*floor((tIndex-1)/8), 'margins',margins1, 'paddings',paddings);
        temp = chSpikeLfp(tIndex).chSPK(chIndex).StdSpikePlot;
        if ~isempty(temp)
            scatter(temp(:, 1), temp(:,2), 4, "filled", 'b'); hold on;
            xlim(spkPlotWindow);
            xticks('');yticks('');ylabel('std');
        end
        %% ROW1: Dev time raster
        mSubplot(Fig, 40, 10, 10*9+1+mod((tIndex-1), 8)+200*floor((tIndex-1)/8), 'margins', margins1, 'paddings', paddings);
        temp = chSpikeLfp(tIndex).chSPK(chIndex).DevSpikePlot;
        if ~isempty(temp)
            scatter(temp(:, 1), temp(:,2), 4, "r", "filled"); hold on;
            xlim(spkPlotWindow); xticks('');yticks('');
            ylabel("dev");
        end

        %% ROW2: psth :  last std + dev
        ax = mSubplot(Fig, 14, 10, 50+1+mod((tIndex-1), 8)+70*floor((tIndex-1)/8), 'nSize', [1, 1.85], 'margins', margins1, 'paddings', paddings);

        temp = smoothdata(chSpikeLfp(tIndex).chSPK(chIndex).DevSpkPSTH,'gaussian',3);
        plot(temp(:, 1), temp(:, 2), "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
        temp = smoothdata(chSpikeLfp(tIndex).chSPK(chIndex).StdSpkPSTH,'gaussian',3);
        plot(temp(:, 1), temp(:, 2), "Color", "blue", "LineStyle", "-", "LineWidth", 1.5); hold on;
        xlim(spkPlotWindow);
        xticks(spkPlotWindow(1):50:spkPlotWindow(2));
        set(ax, 'xcolor', colors{ceil(tIndex/2)}, 'ycolor', colors{ceil(tIndex/2)}, 'LineWidth', 1);

        % switch tIndex
        %     case {1,3}
        %     set(ax, 'xcolor', colors{1}, 'ycolor', colors{1}, 'LineWidth', 1);
        %     case {2,4}
        %     set(ax, 'xcolor', colors{2}, 'ycolor', colors{2}, 'LineWidth', 1);
        %     case {5,7}
        %     set(ax, 'xcolor', colors{3}, 'ycolor', colors{3}, 'LineWidth', 1);
        %     case {6,8}
        %     set(ax, 'xcolor', colors{4}, 'ycolor', colors{4}, 'LineWidth', 1);
        %     case {9,11}
        %     set(ax, 'xcolor', colors{5}, 'ycolor', colors{5}, 'LineWidth', 1);
        %     case {10,12}
        %     set(ax, 'xcolor', colors{6}, 'ycolor', colors{6}, 'LineWidth', 1);
        % end
        [~, pvalue0_50] = ttest(chSpikeLfp(tIndex).chSPK(chIndex).DevfrWinOnset0_50, chSpikeLfp(tIndex).chSPK(chIndex).StdfrWinOnset0_50 );
        [~, pvalue50_200] = ttest(chSpikeLfp(tIndex).chSPK(chIndex).DevfrWinLate50_200, chSpikeLfp(tIndex).chSPK(chIndex).StdfrWinLate50_200 );
        [~, pvalue0_250] = ttest(chSpikeLfp(tIndex).chSPK(chIndex).DevfrWin0_250, chSpikeLfp(tIndex).chSPK(chIndex).StdfrWin0_250 );
        title({strcat("S:D, p[0 50] = ",  num2str(round(pvalue0_50, 3))); ...
            strcat(",p[0 250] = ", num2str(round(pvalue0_250, 3))); ...
            strcat(",p[50 200] = ", num2str(round(pvalue50_200, 3)))});

        %% ROW 3: win [0 250]

        FrTemp = [];
        for i = 1:sum(ratio)
            FrTemp(:, i) = cell2mat(cellfun(@(x) calOriFirate(x, spkFrWin{1}, 0),  chSpikeLfp(tIndex).chSPK(chIndex).(['Sti',num2str(i)]), "UniformOutput", false ));
        end
        FrMean = mean(FrTemp, 1);
        FrSe = SE(FrTemp, 1);
        if any(ismember(1:8, tIndex))
            axes(ax1); hold on;
            errorbar(ax1, 1:sum(ratio), FrMean, FrSe, 'Color', colorsLine{tIndex}, "LineWidth", 1.5); hold off;
        elseif any(ismember([typeMax, typeMax-1], tIndex))
            axes(ax5); hold on;
            errorbar(ax5, 1:sum(ratio), FrMean, FrSe, 'Color', colorsLine{tIndex}, "LineWidth", 1.5); hold off;
        else
            axes(ax3); hold on;
            errorbar(ax3, 1:sum(ratio), FrMean, FrSe, 'Color', colorsLine{tIndex}, "LineWidth", 1.5); hold off;
        end
        title([winStr{1}, '[0 250]']);
        xticks('');

        %% ROW 4: win onset

        FrTemp = [];
        for i = 1:sum(ratio)
            FrTemp(:, i) = cell2mat(cellfun(@(x) calOriFirate(x, spkFrWin{3}, 0),  chSpikeLfp(tIndex).chSPK(chIndex).(['Sti',num2str(i)]), "UniformOutput", false ));
        end
        FrMean = mean(FrTemp, 1);
        FrSe = SE(FrTemp, 1);
        if any(ismember(1:8, tIndex))
            axes(ax2); hold on;
            errorbar(ax2, 1:sum(ratio), FrMean, FrSe, 'Color', colorsLine{tIndex}, "LineWidth", 1.5); hold off;
        else
            if any(ismember([typeMax, typeMax-1], tIndex))
                axes(ax6);hold on;
                errorbar(1:sum(ratio), FrMean, FrSe, 'Color', colorsLine{tIndex}, "LineWidth", 1.5); hold off;
            else
                axes(ax4); hold on;
                errorbar(1:sum(ratio), FrMean, FrSe, 'Color', colorsLine{tIndex}, "LineWidth", 1.5);  hold off;
            end
        end
        title([winStr{3}, '[0 50]']);
        xticks([0:11]);
        xticklabels(["", "S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9", "D10", ""]);
    end
    %% add vertical line
    lines(1).X = 0;
    addLines2Axes(Fig, lines);
    print(Fig, strcat(FIGPATH, '\', chinfo), "-djpeg", "-r300");
    close(Fig);
end
waitbar(1, mWaitbar, 'Done');
close(mWaitbar);

