function Fig = Plot_LFP_CSD(LFP, CSD, selWin)
margins = [0.05, 0.05, 0, 0];
paddings = [0.01, 0.03, 0.1, 0.1];
Fig = figure;
maximizeFig(Fig);

%% plot LFP Wave
Axes = mSubplot(Fig, 1, 4, 1, [1, 1], margins, paddings);
lineSpace = ceil(1.2 * max(max(abs(diff(LFP.Raw, 1, 1)))));
adds = repmat(flip(LFP.Chs - 1)' * lineSpace, 1, size(LFP.Raw, 2));
yMax = max([max(max(LFP.Raw)), lineSpace]) + max(max(adds));
yMin = min([min(min(LFP.Raw)), -lineSpace]);
temp = LFP.Raw + adds;
plot(LFP.tWave, adds, "b:"); hold on
plot(LFP.tWave, temp, "k-", "LineWidth", 1); hold on
ylim([yMin, yMax]);
xlim(selWin);
set(Axes, "ytick", flip(adds(:, 1)));
set(Axes, "yticklabel", string(num2cell(flip(LFP.Chs))'));
title(Axes, "Averaged LFP Waveform");

%% plot LFP Image
Axes = mSubplot(Fig, 1, 4, 2, [1, 1], margins, paddings);
CData = -1 * flipud(LFP.Data);
imagesc('XData', LFP.tImage, 'CData', CData);
colormap("jet");
ylim([1, size(LFP.Data, 1)]);
xlim(selWin);
scaleAxes(Axes, "c", max(max(abs(LFP.Data(:, LFP.tImage > selWin(1) & LFP.tImage < selWin(2))))) * [-1, 1]);
set(Axes, "ytick", linspace(1, size(LFP.Data, 1), length(LFP.Chs)));
set(Axes, "yticklabel", string(num2cell(flip(LFP.Chs))'));
title(Axes, "LFP Color Map");
colorbar

%% plot CSD and corresponding MUA wave
vertSeg = (1 - sum(paddings(3 : 4))) / (length(LFP.Chs) - 1);
paddingCSD = paddings;
paddingCSD(3) = paddingCSD(3) + vertSeg * CSD.Boundary;
paddingCSD(4) = paddingCSD(4) + vertSeg * CSD.Boundary;

Axes = mSubplot(Fig, 1, 4, 3, [1, 1], margins, paddingCSD);
box(Axes, "off");

CData = flipud(CSD.Data);
imagesc('XData', CSD.t, 'CData', CData); hold on
colormap("jet");
ylim([1, size(CSD.Data, 1)]);
xlim(selWin);
scaleAxes(Axes, "c", max(max(abs(CSD.Data(:, CSD.t > selWin(1) & CSD.t < selWin(2))))) * [-1, 1]);
csdYTick = linspace(1, size(CSD.Data, 1), length(CSD.Chs));
set(Axes, "ytick", csdYTick);
set(Axes, "yticklabel", string(num2cell(flip(CSD.Chs))'));
colorbar



end
