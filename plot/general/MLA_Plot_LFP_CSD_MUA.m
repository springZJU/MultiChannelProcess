function Fig = MLA_Plot_LFP_CSD_MUA(LFP, CSD, MUA, selWin)
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
cRange = scaleAxes(Axes, "c", "on");
scaleAxes(Axes, "c", [-max(abs(cRange)), max(max(cRange))]);
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
cRange = scaleAxes(Axes, "c", "on");
scaleAxes(Axes, "c", [-max(abs(cRange)), max(max(cRange))]);
csdYTick = linspace(1, size(CSD.Data, 1), length(CSD.Chs));
set(Axes, "ytick", csdYTick);
set(Axes, "yticklabel", string(num2cell(flip(CSD.Chs))'));
colorbar

% plot MUA Wave
tIndex = MUA.tWave >= selWin(1) & MUA.tWave <= selWin(2);
waveTemp = MUA.Wave(CSD.Boundary+1 : end-CSD.Boundary, tIndex);
scaleFactor = 0.8* unique(roundn(diff(csdYTick), -2)) / max(max(waveTemp, [], 2) - min(waveTemp, [], 2));
waveTemp = scaleFactor * waveTemp;
waveTemp = waveTemp - repmat(min(waveTemp ,[], 2), 1, size(waveTemp, 2));
adds = repmat(flip(1:unique(roundn(diff(csdYTick), -2)):size(waveTemp, 1)*unique(roundn(diff(csdYTick), -2)))', 1, size(waveTemp, 2));
temp = waveTemp  + adds;
plot(MUA.tWave(tIndex), temp, "k-", "LineWidth", 1); hold on
title(Axes, "CSD (uv/mm2) & MUA");
colorbar;

%% plot MUA Image
Axes = mSubplot(Fig, 1, 4, 4, [1, 1], margins, paddings);
CData = flipud(MUA.Data);
imagesc('XData', MUA.tImage, 'CData', CData);
colormap(Axes, "hot");
ylim([1, size(MUA.Data, 1)]);
xlim(selWin);
cRange = scaleAxes(Axes, "c", "on");
scaleAxes(Axes, "c", [0, 0.9] * cRange(2));
% scaleAxes(Axes, "c", [0, 1]);
set(Axes, "ytick", linspace(1, size(MUA.Data, 1), length(MUA.Chs)));
set(Axes, "yticklabel", string(num2cell(flip(MUA.Chs))'));
title(Axes, "MUA Color Map");
colorbar

%% add onset line
lines.X = 0;
addLines2Axes(Fig, lines);
% % plot MUA 
% lineSpace = ceil(1.2 * max(max(abs(diff(MUA.Wave, 1, 1)))));
% adds = repmat(flip(MUA.Chs - 1)' * lineSpace, 1, size(MUA.Wave, 2));
% yMax = max([max(max(MUA.Wave)), lineSpace]) + max(max(adds));
% yMin = min([min(min(MUA.Wave)), -lineSpace]);
% temp = MUA.Wave + adds;
% % plot(MUA.tWave, adds, "b:"); hold on
% plot(MUA.tWave, temp, "k-", "LineWidth", 1); hold on
% ylim([yMin, yMax]);
% xlim([-20 150]);
% set(Axes, "ytick", flip(mean(temp, 2)));
% set(Axes, "yticklabel", string(num2cell(flip(MUA.Chs))'));
% title(Axes, "MUA (Multi Unit Acitivity)");




end
