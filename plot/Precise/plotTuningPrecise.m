function Fig = plotTuningPrecise(cellData, visibilityOpt)
%% Plot settings
parseStruct(cellData.windowParams);

%% Plotting
plotData = cellData.data;

Fig = figure;
set(Fig, "visible", visibilityOpt, "outerposition", get(0, "screensize"));

rasterWidth = 0.9 / size(plotData, 1)*8;
%     FR = [];
%     disp(size(plotData,1));
YFR=[];
X1=1:size(plotData, 1);
for fIndex = 1:size(plotData, 1)
    trials = plotData(fIndex).trials;
    tn=size(trials);
    %         disp(fIndex);
    rasterHeight = 0.5 / size(trials, 1)/8;
    flag=mod(fIndex,8);
    n=fix(fIndex/8);
    %         disp(n);
    %         disp(rasterHeight);

    for aIndex = 1:size(trials, 1)

        if flag ==0
            mAxe = axes("Position", [0.05 + rasterWidth *7, 0.9- (n-1)*rasterHeight, rasterWidth, rasterHeight], "Box", "on");

        else
            mAxe = axes("Position", [0.05 + rasterWidth *(flag-1), 0.9 - n*rasterHeight, rasterWidth, rasterHeight], "Box", "on");
        end

        % Raster
        y = sum(cell2mat(cellfun(@(x) length(x), cellData.data(fIndex).trials.spikes, "UniformOutput", false)));
        if y > 0
            y_fr = length(findWithinInterval(cell2mat(cellData.data(fIndex).trials.spikes), frWin));
            y_frEarly = length(findWithinInterval(cell2mat(cellData.data(fIndex).trials.spikes), frWinEarly));
            y_frLate = length(findWithinInterval(cell2mat(cellData.data(fIndex).trials.spikes), frWinLate));
        else
            y_fr = 0;
            y_frEarly = 0;
            y_frLate = 0;
        end

        for tIndex = 1:size(trials(aIndex).spikes, 1)
            X = trials(aIndex).spikes{tIndex};
            Y = ones(length(X), 1) * tIndex;
            plot(X, Y, "r.", "MarkerSize", 10); hold on;
        end
        YFR(fIndex)=y_fr*1000/diff(frWin)/tIndex;
        YFR_Early(fIndex)=y_frEarly*1000/diff(frWinEarly)/tIndex;
        YFR_Late(fIndex)=y_frLate*1000/diff(frWinLate)/tIndex;
        ylim([0, tIndex + 1]);
        xlim([Window(1), Window(2)])

        set(gca, 'YTickLabel', '');

        if fIndex < length(cellData.data)
            set(gca, 'XTickLabel', '');
        end

        if flag == 1
            ylabel(num2str(trials(aIndex).amp));
        end

        if aIndex == 1
            title(num2str(plotData(fIndex).ICI));
        end

        % Rate
        %             FR(aIndex, fIndex) = length(cell2mat(trials(aIndex).spikes)) / size(trials(aIndex).spikes, 1) / ((Window(2) - Window(1)) / 1000);
    end

end
mAxe = axes("Position", [0.05 + rasterWidth *0, 0.08, rasterWidth*8, 0.8-rasterHeight*8], "Box", "on");
% Total
h1 = plot(X1, YFR, "r-", "DisplayName", "Entire Resp [0 1000]");  hold on
h2 = plot(X1, YFR_Early, "b-", "DisplayName", "Early Resp [0 200]");  hold on
h3 = plot(X1, YFR_Late, "k-", "DisplayName", "Late Resp [200 1000]");  hold on

plot(X1, YFR, "r.", "MarkerSize", 10);  hold on
plot(X1, YFR_Early, "b.", "MarkerSize", 10);  hold on
plot(X1, YFR_Late, "k.", "MarkerSize", 10);  hold on
xlim([X1(1), X1(end)]);
xlabel("ICI (ms)");
xticks(1:61);
xticklabels(cellfun(@(x) num2str(x), {plotData.ICI}', "UniformOutput", false))
ylabel("Firing Rate (Hz)");
title("firing rate tuning")
legend([h1, h2, h3]);
%     axes('Position', [0.05, 0.05, 0.9, 0.4]);
%     image(FR, 'CDataMapping', 'scaled');
%     colorbar("Position", [0.96, 0.05, 0.02, 0.4]);
%     drawnow;

return;
end
