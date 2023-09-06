function Fig = MLA_PlotLfpAcrossCh_version1(chAll, CTLParams)

CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
chNum = length(chAll(1).chLFP);
if chNum <= 16
    colors = generateColorGrad(16, 'rgb', 'red', 1:5,  'blue', 6:11, 'black', 12:16);
else
    colors = generateColorGrad(32, 'rgb');
end

margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.05];
Fig = figure;
maximizeFig(Fig);
plotRows = numel(stimStrs);
ymin = 0; 
ymax = 0;
for dIndex = 1 : length(chAll)
    Axes = mSubplot(Fig, plotRows,  ceil(length(chAll)/plotRows), dIndex, [1, 1], margins, paddings);
    for cIndex = 1 : chNum
        %% whole time lfp wave
        t = chAll(dIndex).chLFP(cIndex).Wave(:, 1);
        temp = chAll(dIndex).chLFP(cIndex).Wave(:, 2);
        plot(Axes, t, temp, "Color", colors{cIndex}, "LineStyle", "-", "LineWidth", 1, "DisplayName", ['CH', num2str(cIndex)]); hold on;
        if cIndex == 1
            title(strcat(stimStrs(dIndex)));
        end
        if mod(dIndex, ceil(length(chAll)/plotRows)) ~= 1
            set(gca, 'yticklabel', '');
        end

    end
    %     legend;
end

% add vertical line
lines(1).X = 0;
lines(1).color = "black";
addLines2Axes(Fig, lines);


%% legend
AxesLegend = subplot('position', [0.02, 0.95, 0.95, 0.04]);
set(AxesLegend, "Visible", "off");
legend(AxesLegend, Axes.Children(end:-1:2), "NumColumns", 16, "FontSize", 12);


