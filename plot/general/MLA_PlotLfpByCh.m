function Fig = MLA_PlotLfpByCh(chAll, CTLParams)   

CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
chNum = length(chAll(1).chLFP);

margins = [0.05, 0.05, 0, 0];
paddings = [0.01, 0.03, 0.03, 0.03];
Fig = figure;
maximizeFig(Fig);
axesMap = reshape(1 : chNum * length(chAll), [length(chAll), chNum]);

for dIndex = 1 : length(chAll)
    for cIndex = 1 : chNum
        %% whole time lfp wave
        % shank1
        Axes = mSubplot(Fig, chNum,  length(chAll), axesMap(dIndex, cIndex), [1, 1], margins, paddings);
        t = chAll(dIndex).chLFP(cIndex).Wave(:, 1);
        temp = chAll(dIndex).chLFP(cIndex).Wave(:, 2);
        plot(Axes, t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
        xlim([t(1), t(end)]);
        if cIndex == 1
            title(strcat(stimStr(dIndex), " shank1-Odd"));
        end
        if cIndex < chNum
            set(gca, 'xticklabel', '');
        end
        if dIndex > 1
            set(gca, 'yticklabel', '');
        end
    end
end

% add vertical line
lines(1).X = 0;
lines(1).color = "black";
addLines2Axes(Fig, lines);



