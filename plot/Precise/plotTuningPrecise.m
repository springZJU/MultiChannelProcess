function Fig = plotTuningPrecise(cellData, visibilityOpt)
%% Plot settings
parseStruct(cellData.windowParams);

%% Plotting
plotData = cellData.data;

Fig = figure;
set(Fig, "visible", visibilityOpt, "outerposition", get(0, "screensize"));

rasterWidth = 0.9 / size(plotData, 1)*8;
for fIndex = 1:size(plotData, 1)
    trials = plotData(fIndex).trials;
    rasterHeight = 0.5 / size(trials, 1)/8;
    flag=mod(fIndex,8);
    n=fix(fIndex/8);

    for aIndex = 1:size(trials, 1)

        if flag ==0
            mAxe = axes("Position", [0.05 + rasterWidth *7, 0.9- (n-1)*rasterHeight, rasterWidth, rasterHeight], "Box", "on");

        else
            mAxe = axes("Position", [0.05 + rasterWidth *(flag-1), 0.9 - n*rasterHeight, rasterWidth, rasterHeight], "Box", "on");
        end

        % Raster
        for tIndex = 1:size(trials(aIndex).spikes, 1)
            X = trials(aIndex).spikes{tIndex};
            Y = ones(length(X), 1) * tIndex;
            plot(X, Y, "r.", "MarkerSize", 10); hold on;
        end

        ylim([0, tIndex + 1]);
        xlim([Window(1), Window(2)])

        set(gca, 'YTickLabel', '');

        if fIndex < length(cellData.data)
            set(gca, 'XTickLabel', '');
        end

        if aIndex == 1
            title(num2str(plotData(fIndex).ICI));
        end

    end

end

return;
end
