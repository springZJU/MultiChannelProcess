function Fig = plotTuningPrecise_Old(cellData, visibilityOpt)
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
        temp = cellData.data(fIndex).trials.spikes;
        for wIndex = 1 : length(winStr)
            eval(['y_fr(', num2str(wIndex), ').label = "', char(labelStr(wIndex)), '";']);
            eval(['y_fr(', num2str(wIndex), ').win = ', char(winStr(wIndex)), ';']);
            y_fr(wIndex).count{fIndex, 1} = cell2mat(cellfun(@(x) length(findWithinInterval(x, y_fr(wIndex).win)), temp, "UniformOutput", false));
            eval(['y_fr(wIndex).frRaw{fIndex, 1} = y_fr(wIndex).count{fIndex, 1} * 1000 / diff(', char(winStr(wIndex)), ');']);
            y_fr(wIndex).frMean(fIndex, 1) =  mean(y_fr(wIndex).frRaw{fIndex, 1});
            y_fr(wIndex).frSE(fIndex, 1) =  SE(y_fr(wIndex).frRaw{fIndex, 1});
        end

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

        if flag == 1
            ylabel(num2str(trials(aIndex).amp));
        end

        if aIndex == 1
            title(num2str(plotData(fIndex).ICI));
        end

    end

end

%% plot fr tuning
mAxe = axes("Position", [0.05 + rasterWidth *0, 0.08, rasterWidth*8, 0.8-rasterHeight*8], "Box", "on");


for wIndex = 1 : length(y_fr)-2
    % firing rate tuning
    h(wIndex) = plot(X1, [y_fr(wIndex).frMean], "Color", colors(wIndex), "LineStyle", "-", "DisplayName", y_fr(wIndex).label);  hold on
    frMean = [y_fr(wIndex).frMean(1:end-1)];
    % significance
    [~, temp] = cellfun(@(x, y) ttest2(x, y), y_fr(wIndex).frRaw(1:end-1), y_fr(wIndex).frRaw(2:end), "UniformOutput", false);
    temp = cell2mat(temp);
    temp(isnan(temp)) = 1;
    y_fr(wIndex).p = temp;
    sigIdx = temp < 0.05;
    X_Test = 1 : length(temp);
    scatter(X_Test(sigIdx), frMean(sigIdx), 25, colorDec{wIndex}, "filled");  hold on
    scatter(X_Test(~sigIdx), frMean(~sigIdx), 40, colorDec{wIndex});  hold on
end
% temp = y_fr(6).frMean ./ y_fr(5).frMean;
% [~, p] = cellfun(@(x, y) ttest2(x, y), y_fr(5).frRaw, y_fr(6).frRaw, "UniformOutput", false);

xlim([X1(1), X1(end)]);
xlabel("ICI (ms)");
xticks(1:61);
xticklabels(cellfun(@(x) num2str(x), {plotData.ICI}', "UniformOutput", false))
ylabel("Firing Rate (Hz)");
title("firing rate tuning")
legend(h);


return;
end
