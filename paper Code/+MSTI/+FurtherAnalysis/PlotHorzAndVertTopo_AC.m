clear all;clc;close all;
PathTemp = strsplit(string(mfilename("fullpath")), "\");
SaveRootPath = strjoin(PathTemp(1 : end-1), "\");
%% get ClickInteval/ClickDuration/CSI TopoInfo
load(strcat(SaveRootPath, "\MSTITopo.mat"));
cm_AC_BG3o6_Interval = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "cm") & contains([PjHorzAndVertData.Info], "AC")).Data(1).PjHorz_Click;
cm_AC_BG14_Interval = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "cm") & contains([PjHorzAndVertData.Info], "AC")).Data(2).PjHorz_Click;
cm_AC_BG3o6_Duration = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "cm") & contains([PjHorzAndVertData.Info], "AC")).Data(1).PjHorz_ClickTrain;
cm_AC_BG14_Duration = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "cm") & contains([PjHorzAndVertData.Info], "AC")).Data(2).PjHorz_ClickTrain;
cm_AC_BG3o6_CSI = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "cm") & contains([PjHorzAndVertData.Info], "AC")).Data(1).PjHorz_CSI;
cm_AC_BG14_CSI = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "cm") & contains([PjHorzAndVertData.Info], "AC")).Data(2).PjHorz_CSI;

ddz_AC_BG3o6_Interval = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "ddz") & contains([PjHorzAndVertData.Info], "AC")).Data(1).PjHorz_Click;
ddz_AC_BG14_Interval = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "ddz") & contains([PjHorzAndVertData.Info], "AC")).Data(2).PjHorz_Click;
ddz_AC_BG3o6_Duration = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "ddz") & contains([PjHorzAndVertData.Info], "AC")).Data(1).PjHorz_ClickTrain;
ddz_AC_BG14_Duration = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "ddz") & contains([PjHorzAndVertData.Info], "AC")).Data(2).PjHorz_ClickTrain;
ddz_AC_BG3o6_CSI = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "ddz") & contains([PjHorzAndVertData.Info], "AC")).Data(1).PjHorz_CSI;
ddz_AC_BG14_CSI = PjHorzAndVertData(contains([PjHorzAndVertData.Info], "ddz") & contains([PjHorzAndVertData.Info], "AC")).Data(2).PjHorz_CSI;

[rowIdx, colIdx, val] = find(cm_AC_BG3o6_Interval); cm_AC_BG3o6_Interval = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(cm_AC_BG14_Interval); cm_AC_BG14_Interval = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(cm_AC_BG3o6_Duration); cm_AC_BG3o6_Duration = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(cm_AC_BG14_Duration); cm_AC_BG14_Duration = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(cm_AC_BG3o6_CSI); cm_AC_BG3o6_CSI = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(cm_AC_BG14_CSI); cm_AC_BG14_CSI = [rowIdx, colIdx, val]; clear rowIdx colIdx val;

[rowIdx, colIdx, val] = find(ddz_AC_BG3o6_Interval); ddz_AC_BG3o6_Interval = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(ddz_AC_BG14_Interval); ddz_AC_BG14_Interval = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(ddz_AC_BG3o6_Duration); ddz_AC_BG3o6_Duration = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(ddz_AC_BG14_Duration); ddz_AC_BG14_Duration = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(ddz_AC_BG3o6_CSI); ddz_AC_BG3o6_CSI = [rowIdx, colIdx, val]; clear rowIdx colIdx val;
[rowIdx, colIdx, val] = find(ddz_AC_BG14_CSI); ddz_AC_BG14_CSI = [rowIdx, colIdx, val]; clear rowIdx colIdx val;

IntervalTopo = readtable(strcat(SaveRootPath, "\MSTITopo.xlsx"), "Sheet", "Interval");
% ddz AC BG3.6
ddz_Allpos = num2cell([IntervalTopo.DDZ_AC_A, IntervalTopo.DDZ_AC_R], 2);
ddz_BG3o6pos = num2cell([ddz_AC_BG3o6_Interval(:, 1), ddz_AC_BG3o6_Interval(:, 2)], 2);
checkAllpos = cellfun(@(allpos) cellfun(@(recordpos) allpos == recordpos, ddz_BG3o6pos, "UniformOutput", false), ddz_Allpos, "UniformOutput", false);
ddz_AC_BG3o6_posIdx = cellfun(@(x) find(x ~= 0), cellfun(@(checkIdx_all) cellfun(@(checkIdx_record) all(checkIdx_record), checkIdx_all), ...
        checkAllpos, "UniformOutput", false), "UniformOutput", false);
CFTopo = readtable(strcat(SaveRootPath, "\MSTITopo.xlsx"), "Sheet", "CF");

%% DDZ AC
figure;
set(gcf, "position", [2, 179, 1915, 600]);
% CF
ddzAC = table2array(CFTopo(:, 1:3));
ddzAC = ddzAC(ddzAC(:, 1) > 0, :);
cMap_ddzAC_CF = [];
for cIndex = 1 : size(ddzAC, 1)
    cMap_ddzAC_CF(ddzAC(cIndex, 1), ddzAC(cIndex, 2)) = ddzAC(cIndex, 3);
end
% ClickInteval/ClickDuration/CSI
cMap_ddzAC_BG3o6Interval = zeros(size(cMap_ddzAC_CF));cMap_ddzAC_BG3o6Duration = zeros(size(cMap_ddzAC_CF));cMap_ddzAC_BG3o6CSI = zeros(size(cMap_ddzAC_CF));
cMap_ddzAC_BG14Interval = zeros(size(cMap_ddzAC_CF));cMap_ddzAC_BG14Duration = zeros(size(cMap_ddzAC_CF));cMap_ddzAC_BG14CSI = zeros(size(cMap_ddzAC_CF));
for cIndex = 1 : size(ddz_AC_BG3o6_Interval, 1) % BG3.6
    cMap_ddzAC_BG3o6Interval(ddz_AC_BG3o6_Interval(cIndex, 1), ddz_AC_BG3o6_Interval(cIndex, 2)) = ddz_AC_BG3o6_Interval(cIndex, 3);
    cMap_ddzAC_BG3o6Duration(ddz_AC_BG3o6_Duration(cIndex, 1), ddz_AC_BG3o6_Duration(cIndex, 2)) = ddz_AC_BG3o6_Duration(cIndex, 3);
    cMap_ddzAC_BG3o6CSI(ddz_AC_BG3o6_CSI(cIndex, 1), ddz_AC_BG3o6_CSI(cIndex, 2)) = ddz_AC_BG3o6_CSI(cIndex, 3);
end
for cIndex = 1 : size(ddz_AC_BG14_Interval, 1) %BG14
    cMap_ddzAC_BG14Interval(ddz_AC_BG14_Interval(cIndex, 1), ddz_AC_BG14_Interval(cIndex, 2)) = ddz_AC_BG14_Interval(cIndex, 3);
    cMap_ddzAC_BG14Duration(ddz_AC_BG14_Duration(cIndex, 1), ddz_AC_BG14_Duration(cIndex, 2)) = ddz_AC_BG14_Duration(cIndex, 3);
    cMap_ddzAC_BG14CSI(ddz_AC_BG14_CSI(cIndex, 1), ddz_AC_BG14_CSI(cIndex, 2)) = ddz_AC_BG14_CSI(cIndex, 3);
end

% plot CF
mSubplot(2,4,1);
im = imagesc(cMap_ddzAC_CF); 
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(ddzAC(:, 2)) - 0.5, max(ddzAC(:, 2)) + 0.5]);  ylim([min(ddzAC(:, 1)) - 0.5, max(ddzAC(:, 1)) + 0.5]); clim([200, 19079]);
c = colormap(gca, "jet"); c(1, :) = 1; colormap(gca, c); colorbar ; clim([100, 19079]);
set(gca,'ColorScale','log');
xticklabels(""); yticklabels("");
title("DDZ AC CF");

% plot Interval
ddzAC_Interval_clim = [min([cMap_ddzAC_BG3o6Interval, cMap_ddzAC_BG14Interval], [], "all"), max([cMap_ddzAC_BG3o6Interval, cMap_ddzAC_BG14Interval], [], "all")];
ddzAC_Interval_clipLim = linspace(-max(abs(ddzAC_Interval_clim)), max(abs(ddzAC_Interval_clim)), 256)';

mSubplot(2,4,2);
cMap_ddzAC_BG3o6Interval(cMap_ddzAC_BG3o6Interval >= ddzAC_Interval_clipLim(127) & cMap_ddzAC_BG3o6Interval <0) = ddzAC_Interval_clipLim(127);
cMap_ddzAC_BG3o6Interval(cMap_ddzAC_BG3o6Interval <= ddzAC_Interval_clipLim(130) & cMap_ddzAC_BG3o6Interval >0) = ddzAC_Interval_clipLim(130);
imagesc(cMap_ddzAC_BG3o6Interval);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(ddzAC(:, 2)) - 0.5, max(ddzAC(:, 2)) + 0.5]); ylim([min(ddzAC(:, 1)) - 0.5, max(ddzAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(ddzAC_Interval_clim)), max(abs(ddzAC_Interval_clim))]);
xticklabels(""); yticklabels(""); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("DDZ AC Interval BG3.6");

mSubplot(2,4,6);
cMap_ddzAC_BG14Interval(cMap_ddzAC_BG14Interval >= ddzAC_Interval_clipLim(127) & cMap_ddzAC_BG14Interval <0) = ddzAC_Interval_clipLim(127);
cMap_ddzAC_BG14Interval(cMap_ddzAC_BG14Interval <= ddzAC_Interval_clipLim(130) & cMap_ddzAC_BG14Interval >0) = ddzAC_Interval_clipLim(130);
imagesc(cMap_ddzAC_BG14Interval);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(ddzAC(:, 2)) - 0.5, max(ddzAC(:, 2)) + 0.5]); ylim([min(ddzAC(:, 1)) - 0.5, max(ddzAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(ddzAC_Interval_clim)), max(abs(ddzAC_Interval_clim))]);
xticklabels(""); yticklabels("");xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("DDZ AC Interval BG14");

% plot Duration
ddzAC_Duration_clim = [min([cMap_ddzAC_BG3o6Duration, cMap_ddzAC_BG14Duration], [], "all"), max([cMap_ddzAC_BG3o6Duration, cMap_ddzAC_BG14Duration], [], "all")];
ddzAC_Duration_clipLim = linspace(-max(abs(ddzAC_Duration_clim)), max(abs(ddzAC_Duration_clim)), 256)';

mSubplot(2,4,3);
cMap_ddzAC_BG3o6Duration(cMap_ddzAC_BG3o6Duration >= ddzAC_Duration_clipLim(127) & cMap_ddzAC_BG3o6Duration <0) = ddzAC_Duration_clipLim(127);
cMap_ddzAC_BG3o6Duration(cMap_ddzAC_BG3o6Duration <= ddzAC_Duration_clipLim(130) & cMap_ddzAC_BG3o6Duration >0) = ddzAC_Duration_clipLim(130);
imagesc(cMap_ddzAC_BG3o6Duration);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(ddzAC(:, 2)) - 0.5, max(ddzAC(:, 2)) + 0.5]); ylim([min(ddzAC(:, 1)) - 0.5, max(ddzAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(ddzAC_Duration_clim)), max(abs(ddzAC_Duration_clim))]);
xticklabels(""); yticklabels(""); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("DDZ AC Duration BG3.6");

mSubplot(2,4,7);
cMap_ddzAC_BG14Duration(cMap_ddzAC_BG14Duration >= ddzAC_Duration_clipLim(127) & cMap_ddzAC_BG14Duration <0) = ddzAC_Duration_clipLim(127);
cMap_ddzAC_BG14Duration(cMap_ddzAC_BG14Duration <= ddzAC_Duration_clipLim(130) & cMap_ddzAC_BG14Duration >0) = ddzAC_Duration_clipLim(130);
imagesc(cMap_ddzAC_BG14Duration);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(ddzAC(:, 2)) - 0.5, max(ddzAC(:, 2)) + 0.5]); ylim([min(ddzAC(:, 1)) - 0.5, max(ddzAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(ddzAC_Duration_clim)), max(abs(ddzAC_Duration_clim))]);
xticklabels(""); yticklabels("");xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("DDZ AC Duration BG14");

% plot Duration
ddzAC_CSI_clim = [min([cMap_ddzAC_BG3o6CSI, cMap_ddzAC_BG14CSI], [], "all"), max([cMap_ddzAC_BG3o6CSI, cMap_ddzAC_BG14CSI], [], "all")];
ddzAC_CSI_clipLim = linspace(-max(abs(ddzAC_CSI_clim)), max(abs(ddzAC_CSI_clim)), 256)';

mSubplot(2,4,4);
cMap_ddzAC_BG3o6CSI(cMap_ddzAC_BG3o6CSI >= ddzAC_CSI_clipLim(127) & cMap_ddzAC_BG3o6CSI <0) = ddzAC_CSI_clipLim(127);
cMap_ddzAC_BG3o6CSI(cMap_ddzAC_BG3o6CSI <= ddzAC_CSI_clipLim(130) & cMap_ddzAC_BG3o6CSI >0) = ddzAC_CSI_clipLim(130);
imagesc(cMap_ddzAC_BG3o6CSI);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(ddzAC(:, 2)) - 0.5, max(ddzAC(:, 2)) + 0.5]); ylim([min(ddzAC(:, 1)) - 0.5, max(ddzAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(ddzAC_CSI_clim)), max(abs(ddzAC_CSI_clim))]);
xticklabels(""); yticklabels(""); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("DDZ AC CSI BG3.6");

mSubplot(2,4,8);
cMap_ddzAC_BG14CSI(cMap_ddzAC_BG14CSI >= ddzAC_CSI_clipLim(127) & cMap_ddzAC_BG14CSI <0) = ddzAC_CSI_clipLim(127);
cMap_ddzAC_BG14CSI(cMap_ddzAC_BG14CSI <= ddzAC_CSI_clipLim(130) & cMap_ddzAC_BG14CSI >0) = ddzAC_CSI_clipLim(130);
imagesc(cMap_ddzAC_BG14CSI);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(ddzAC(:, 2)) - 0.5, max(ddzAC(:, 2)) + 0.5]); ylim([min(ddzAC(:, 1)) - 0.5, max(ddzAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(ddzAC_CSI_clim)), max(abs(ddzAC_CSI_clim))]);
xticklabels(""); yticklabels("");xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("DDZ AC CSI BG14");
%% CM AC
figure;
set(gcf, "position", [2, 179, 1915, 600]);
% CF
cmAC = table2array(CFTopo(:, 4:6));
cmAC = cmAC(cmAC(:, 1) > 0, :);
cMap_cmAC_CF = [];
for cIndex = 1 : size(cmAC, 1)
    cMap_cmAC_CF(cmAC(cIndex, 1), cmAC(cIndex, 2)) = cmAC(cIndex, 3);
end
% ClickInteval/ClickDuration/CSI
cMap_cmAC_BG3o6Interval = zeros(size(cMap_cmAC_CF));cMap_cmAC_BG3o6Duration = zeros(size(cMap_cmAC_CF));cMap_cmAC_BG3o6CSI = zeros(size(cMap_cmAC_CF));
cMap_cmAC_BG14Interval = zeros(size(cMap_cmAC_CF));cMap_cmAC_BG14Duration = zeros(size(cMap_cmAC_CF));cMap_cmAC_BG14CSI = zeros(size(cMap_cmAC_CF));
for cIndex = 1 : size(cm_AC_BG3o6_Interval, 1) % BG3.6
    cMap_cmAC_BG3o6Interval(cm_AC_BG3o6_Interval(cIndex, 1), cm_AC_BG3o6_Interval(cIndex, 2)) = cm_AC_BG3o6_Interval(cIndex, 3);
    cMap_cmAC_BG3o6Duration(cm_AC_BG3o6_Duration(cIndex, 1), cm_AC_BG3o6_Duration(cIndex, 2)) = cm_AC_BG3o6_Duration(cIndex, 3);
    cMap_cmAC_BG3o6CSI(cm_AC_BG3o6_CSI(cIndex, 1), cm_AC_BG3o6_CSI(cIndex, 2)) = cm_AC_BG3o6_CSI(cIndex, 3);
end
for cIndex = 1 : size(cm_AC_BG14_Interval, 1) %BG14
    cMap_cmAC_BG14Interval(cm_AC_BG14_Interval(cIndex, 1), cm_AC_BG14_Interval(cIndex, 2)) = cm_AC_BG14_Interval(cIndex, 3);
    cMap_cmAC_BG14Duration(cm_AC_BG14_Duration(cIndex, 1), cm_AC_BG14_Duration(cIndex, 2)) = cm_AC_BG14_Duration(cIndex, 3);
    cMap_cmAC_BG14CSI(cm_AC_BG14_CSI(cIndex, 1), cm_AC_BG14_CSI(cIndex, 2)) = cm_AC_BG14_CSI(cIndex, 3);
end

% plot CF
mSubplot(2,4,1);
im = imagesc(cMap_cmAC_CF); 
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(cmAC(:, 2)) - 0.5, max(cmAC(:, 2)) + 0.5]);  ylim([min(cmAC(:, 1)) - 0.5, max(cmAC(:, 1)) + 0.5]); clim([200, 19079]);
c = colormap(gca, "jet"); c(1, :) = 1; colormap(gca, c); colorbar ; clim([100, 19079]);
set(gca,'ColorScale','log');
xticklabels(""); yticklabels("");
title("CM AC CF");

% plot Interval
cmAC_Interval_clim = [min([cMap_cmAC_BG3o6Interval, cMap_cmAC_BG14Interval], [], "all"), max([cMap_cmAC_BG3o6Interval, cMap_cmAC_BG14Interval], [], "all")];
cmAC_Interval_clipLim = linspace(-max(abs(cmAC_Interval_clim)), max(abs(cmAC_Interval_clim)), 256)';

mSubplot(2,4,2);
cMap_cmAC_BG3o6Interval(cMap_cmAC_BG3o6Interval >= cmAC_Interval_clipLim(127) & cMap_cmAC_BG3o6Interval <0) = cmAC_Interval_clipLim(127);
cMap_cmAC_BG3o6Interval(cMap_cmAC_BG3o6Interval <= cmAC_Interval_clipLim(130) & cMap_cmAC_BG3o6Interval >0) = cmAC_Interval_clipLim(130);
imagesc(cMap_cmAC_BG3o6Interval);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(cmAC(:, 2)) - 0.5, max(cmAC(:, 2)) + 0.5]); ylim([min(cmAC(:, 1)) - 0.5, max(cmAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(cmAC_Interval_clim)), max(abs(cmAC_Interval_clim))]);
xticklabels(""); yticklabels(""); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("CM AC Interval BG3.6");

mSubplot(2,4,6);
cMap_cmAC_BG14Interval(cMap_cmAC_BG14Interval >= cmAC_Interval_clipLim(127) & cMap_cmAC_BG14Interval <0) = cmAC_Interval_clipLim(127);
cMap_cmAC_BG14Interval(cMap_cmAC_BG14Interval <= cmAC_Interval_clipLim(130) & cMap_cmAC_BG14Interval >0) = cmAC_Interval_clipLim(130);
imagesc(cMap_cmAC_BG14Interval);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(cmAC(:, 2)) - 0.5, max(cmAC(:, 2)) + 0.5]); ylim([min(cmAC(:, 1)) - 0.5, max(cmAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(cmAC_Interval_clim)), max(abs(cmAC_Interval_clim))]);
xticklabels(""); yticklabels("");xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("CM AC Interval BG14");

% plot Duration
cmAC_Duration_clim = [min([cMap_cmAC_BG3o6Duration, cMap_cmAC_BG14Duration], [], "all"), max([cMap_cmAC_BG3o6Duration, cMap_cmAC_BG14Duration], [], "all")];
cmAC_Duration_clipLim = linspace(-max(abs(cmAC_Duration_clim)), max(abs(cmAC_Duration_clim)), 256)';

mSubplot(2,4,3);
cMap_cmAC_BG3o6Duration(cMap_cmAC_BG3o6Duration >= cmAC_Duration_clipLim(127) & cMap_cmAC_BG3o6Duration <0) = cmAC_Duration_clipLim(127);
cMap_cmAC_BG3o6Duration(cMap_cmAC_BG3o6Duration <= cmAC_Duration_clipLim(130) & cMap_cmAC_BG3o6Duration >0) = cmAC_Duration_clipLim(130);
imagesc(cMap_cmAC_BG3o6Duration);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(cmAC(:, 2)) - 0.5, max(cmAC(:, 2)) + 0.5]); ylim([min(cmAC(:, 1)) - 0.5, max(cmAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(cmAC_Duration_clim)), max(abs(cmAC_Duration_clim))]);
xticklabels(""); yticklabels(""); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("CM AC Duration BG3.6");

mSubplot(2,4,7);
cMap_cmAC_BG14Duration(cMap_cmAC_BG14Duration >= cmAC_Duration_clipLim(127) & cMap_cmAC_BG14Duration <0) = cmAC_Duration_clipLim(127);
cMap_cmAC_BG14Duration(cMap_cmAC_BG14Duration <= cmAC_Duration_clipLim(130) & cMap_cmAC_BG14Duration >0) = cmAC_Duration_clipLim(130);
imagesc(cMap_cmAC_BG14Duration);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(cmAC(:, 2)) - 0.5, max(cmAC(:, 2)) + 0.5]); ylim([min(cmAC(:, 1)) - 0.5, max(cmAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(cmAC_Duration_clim)), max(abs(cmAC_Duration_clim))]);
xticklabels(""); yticklabels("");xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("CM AC Duration BG14");

% plot Duration
cmAC_CSI_clim = [min([cMap_cmAC_BG3o6CSI, cMap_cmAC_BG14CSI], [], "all"), max([cMap_cmAC_BG3o6CSI, cMap_cmAC_BG14CSI], [], "all")];
cmAC_CSI_clipLim = linspace(-max(abs(cmAC_CSI_clim)), max(abs(cmAC_CSI_clim)), 256)';

mSubplot(2,4,4);
cMap_cmAC_BG3o6CSI(cMap_cmAC_BG3o6CSI >= cmAC_CSI_clipLim(127) & cMap_cmAC_BG3o6CSI <0) = cmAC_CSI_clipLim(127);
cMap_cmAC_BG3o6CSI(cMap_cmAC_BG3o6CSI <= cmAC_CSI_clipLim(130) & cMap_cmAC_BG3o6CSI >0) = cmAC_CSI_clipLim(130);
imagesc(cMap_cmAC_BG3o6CSI);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(cmAC(:, 2)) - 0.5, max(cmAC(:, 2)) + 0.5]); ylim([min(cmAC(:, 1)) - 0.5, max(cmAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(cmAC_CSI_clim)), max(abs(cmAC_CSI_clim))]);
xticklabels(""); yticklabels(""); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("CM AC CSI BG3.6");

mSubplot(2,4,8);
cMap_cmAC_BG14CSI(cMap_cmAC_BG14CSI >= cmAC_CSI_clipLim(127) & cMap_cmAC_BG14CSI <0) = cmAC_CSI_clipLim(127);
cMap_cmAC_BG14CSI(cMap_cmAC_BG14CSI <= cmAC_CSI_clipLim(130) & cMap_cmAC_BG14CSI >0) = cmAC_CSI_clipLim(130);
imagesc(cMap_cmAC_BG14CSI);
set(gca, "XTickLabel", mat2cellStr(get(gca, "XTick") / 2));
xlim([min(cmAC(:, 2)) - 0.5, max(cmAC(:, 2)) + 0.5]); ylim([min(cmAC(:, 1)) - 0.5, max(cmAC(:, 1)) + 0.5]); 
scaleAxes(gca, "c", [-max(abs(cmAC_CSI_clim)), max(abs(cmAC_CSI_clim))]);
xticklabels(""); yticklabels("");xlabel("Lateral to Interaural"); ylabel("Posterior to Anterior");
c = colormap(gca, "jet");c(128:129, :) = 1;colormap(gca, c); colorbar;
title("CM AC CSI BG14");







