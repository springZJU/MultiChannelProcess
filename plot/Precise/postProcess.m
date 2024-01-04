ccc
addpath(genpath(fullfile(getRootDirPath(mfilename("fullpath"), 4), "utils\data process")), "-begin");
%% Parameter Settings

% accumulation
windowParams.Window              = [-1000 3000]; % ms
windowParams.accBinsize          = 20;
accWindow                        = [200, 2000];
windowParams.accWindow           = accWindow;
windowParams.accEarly            = [accWindow(1), fix(accWindow(1) + diff(accWindow)/2)];
windowParams.accLate             = [fix(accWindow(1) + diff(accWindow)/2), accWindow(2)];
windowParams.accTestBinsize      = 100;
windowParams.psthPara.binsize    = 50; % ms
windowParams.psthPara.binstep    = 5; % ms


% onset
windowParams.onRespWin           = [0, accWindow(1)];
windowParams.onBaseWin           = [-accWindow(1), 0];
% offset
windowParams.offRespWin          = [0, 200] + accWindow(2);
windowParams.offBaseWin          = accWindow(2) + [800, 1000];

FIGPATH = {'I:\neuroPixels\Figure\CTL_New\Rat3ZYY20231102_AC1\RNP_Precise', ...
           'I:\neuroPixels\Figure\CTL_New\Rat3ZYY20231102_AC2\RNP_Precise', ...
           'I:\neuroPixels\Figure\CTL_New\Rat3ZYY20231103_AC3\RNP_Precise', ...
           'I:\neuroPixels\Figure\CTL_New\Rat3ZYY20231103_AC4\RNP_Precise'};
for fIndex = 1 : length(FIGPATH)
    load([FIGPATH{fIndex}, '\spkRes.mat'], "spkRes");

    %% check noise
    noiseRes = cellfun(@(x) x(end).spikes, {spkRes.spkData}', "UniformOutput", false);
    result = cell2mat(cellfun(@(x) quantifyResp(x, windowParams), noiseRes, "uni", false));

    %% plot figures
    for cIndex = 1 : length(spkRes)
        result = cell2mat(cellfun(@(x) quantifyResp(x, windowParams), {spkRes(cIndex).spkData.spikes}', "uni", false));
        result = structcat(rmfield(spkRes(cIndex).spkData, "spikes"), result);
        Fig = plotResOfICIs(result, windowParams);
        mPrint(Fig, fullfile(FIGPATH{fIndex}, ['CH', num2str(spkRes(cIndex).ch)]), "-djpeg", "-r0");
        close(Fig);
    end
end

function result = quantifyResp(spikes, windowParams)
parseStruct(windowParams);
%% quantifying
% PSTH during Window
result.spikes = spikes;
PSTH = calPsth(spikes, psthPara, 1e3, "EDGE", Window);
result.PSTH                  = PSTH;

% accumulation response
% accumulation function during accWin (normalized, from 0 to 1)
tACC = (accWindow(1):accBinsize:accWindow(2)-accBinsize)' + accBinsize/2;
ACC = cumsum(histcounts(cell2mat(spikes), accWindow(1):accBinsize:accWindow(2)))' ./ histcounts(cell2mat(spikes), accWindow);
if all(isnan(ACC))
    ACC = [zeros(length(ACC)-1, 1); 1];
end
% check significance of adjacent windows across accWin
ACCTestData                  = changeCellRowNum(cellfun(@(x) histcounts(x, accWindow(1):accTestBinsize:accWindow(2))', spikes, "UniformOutput", false));
ACCTestH                     = cellfun(@(x, y) ttest2(x, y), ACCTestData(1:end-1), ACCTestData(2:end));
ACCTestT                     = accWindow(1)+accTestBinsize:accTestBinsize:accWindow(2)-accTestBinsize;
% check significance of early and late responses during accWin
ACCHalfData                  = changeCellRowNum(cellfun(@(x) histcounts(x, accWindow(1):diff(accWindow)/2:accWindow(2))', spikes, "UniformOutput", false));
[ACCHalfH, ACCHalfP]         = ttest2(ACCHalfData{1}, ACCHalfData{2}, "Alpha", 0.05); % determine if firing rate increase/decrease
if ACCHalfH==1 ; if  mean(ACCHalfData{1}) <= mean(ACCHalfData{2}); ACCHalfDir = "sig Increase"; else; ACCHalfDir = "sig Decrease"; end; else; ACCHalfDir = "no Sig Change"; end
% organize the ACC result
result.ACCTestH              = ACCTestH;
result.ACCTestT              = ACCTestT;
result.ACC                   = [tACC, ACC];
result.ACCAUC                = sum(ACC) / length(ACC);
result.ACCTHRs               = [0.1:0.1:0.9; cellfun(@(x) tACC(find(ACC >= x, 1, "first")),  num2cell(0.1:0.1:0.9))]';
result.ACCHalfH              = ACCHalfH;
result.ACCHalfP              = ACCHalfP;
result.ACCHalfDir            = ACCHalfDir;

% onset response
% decide if an obvious (p < 0.05) onset response is elicited
[onRespFR, ~, onRespCount]   = calFr(spikes, onRespWin);
[onBaseFR, ~, onBaseCount]   = calFr(spikes, onBaseWin);
[onsetH, onsetP]             = ttest2(onRespCount, onBaseCount, "Alpha", 0.05);
if onsetH == 1; if  onRespFR >= onBaseFR ; onsetDir = "sig On Exc."; else; onsetDir = "sig On Inh."; end; else; onsetDir = "no Sig OnResp"; end
% organize the onset result
result.onRespFR              = onRespFR;
result.onBaseFR              = onBaseFR;
result.onRespCount           = onRespCount;
result.onBaseCount           = onBaseCount;
result.onsetH                = onsetH;
result.onsetP                = onsetP;
result.onsetDir              = onsetDir;

% offset response
% decide if an obvious (p < 0.05) offset response is elicited
[offRespFR, ~, offRespCount] = calFr(spikes, onRespWin);
[offBaseFR, ~, offBaseCount] = calFr(spikes, onBaseWin);
[offsetH, offsetP]           = ttest2(offRespCount, offBaseCount, "Alpha", 0.05);
if offsetH == 1; if  offRespFR >= offBaseFR ; offsetDir = "sig Off Exc."; else; offsetDir = "sig Off Inh."; end; else; offsetDir = "no Sig OffResp"; end
% organize the offset result
result.offRespFR             = offRespFR;
result.offBaseFR             = offBaseFR;
result.offRespCount          = offRespCount;
result.offBaseCount          = offBaseCount;
result.offsetH               = offsetH;
result.offsetP               = offsetP;
result.offsetDir             = offsetDir;
end

function plotRes(result, windowParams)
parseStruct(windowParams);
%% plot
figure
subplot(3, 1, 1);
spikes = result.spikes;
spikePlot        = cell2mat(cellfun(@(x, y) [x, ones(length(x), 1)*y], spikes, num2cell(1:length(spikes))', "UniformOutput", false));
scatter(spikePlot(:, 1), spikePlot(:, 2), 10, "red", "filled"); hold on

% acc response
lines            = cell2struct(num2cell(accWindow(1):accTestBinsize:accWindow(2)), "X");
addLines2Axes(lines);
plot(accWindow, [1, 1] * length(spikes)+1, "color", "#FFA500", "LineStyle", "-", "LineWidth", 5); hold on
scatter(result.ACCTestT(result.ACCTestH == 0), length(spikes)+1, 20, "black"); hold on
scatter(result.ACCTestT(result.ACCTestH == 1), length(spikes)+1, 20, "black", "filled"); hold on
% onset response
plot(onRespWin, [1, 1] * length(spikes)+1, "color", "green", "LineStyle", "-", "LineWidth", 5); hold on
% offet response
plot(offRespWin, [1, 1] * length(spikes)+1, "color", "cyan", "LineStyle", "-", "LineWidth", 5); hold on
ylim([0, length(spikes)+1]);


subplot(3, 1, 2);
plot(result.PSTH(:, 1), result.PSTH(:, 2)); hold on
subplot(3, 1, 3);
plot(result.ACC(:, 1), result.ACC(:, 2)); hold on
for lines = 1 : length(result.ACCTHRs)
    plot([Window(1), result.ACCTHRs(lines, 2)], 0.1*[lines, lines], "k--"); hold on
    plot(result.ACCTHRs(lines, 2) * [1, 1], [0, lines*0.1], "k--"); hold on
end
scaleAxes(gcf, "x", Window);
end


function Fig = plotResOfICIs(result, windowParams)
parseStruct(windowParams);
%% plot
Fig = figure;
maximizeFig
% seperate dashed lines
lines            = cell2struct(num2cell([onRespWin, offRespWin]), "X");

for iciIdx = 1 : length(result)

    %% raster plot
    FigRaster(iciIdx) = mSubplot(floor((length(result)-1)/10 + 1)*2, 10, iciIdx+floor((iciIdx-1)/10)*10, "margin_top", 0.12, "paddings",  [0.03, 0.03, 0.08, 0.05]/2);
    spikes = result(iciIdx).spikes;
    spikePlot        = mCell2mat(cellfun(@(x, y) [x, ones(length(x), 1)*y], spikes, num2cell(1:length(spikes))', "UniformOutput", false));
    if ~isempty(spikePlot)
        scatter(spikePlot(:, 1), spikePlot(:, 2), 5, "red", "filled"); hold on
    end
    % acc response
    plot(accWindow,  [1, 1] * length(spikes)+1, "color", "#FFA500", "LineStyle", "-", "LineWidth", 5); hold on
    % onset response
    plot(onRespWin,  [1, 1] * length(spikes)+1, "color", "green",   "LineStyle", "-", "LineWidth", 5); hold on
    % offet response
    plot(offRespWin, [1, 1] * length(spikes)+1, "color", "cyan",    "LineStyle", "-", "LineWidth", 5); hold on
    ylim([0, length(spikes)+1]);
    xticklabels("");
    if ~isequal(result(iciIdx).ICI, 500)
        title(['ICI = ', num2str(result(iciIdx).ICI)]);
    else
        title('Noise');
    end
    if iciIdx <= floor((length(result)-1)/10 + 1)*2
        xticklabels("");
    end

    %% PSTH plot
    FigPSTH(iciIdx) = mSubplot(floor((length(result)-1)/10 + 1)*2, 10, iciIdx+floor((iciIdx-1)/10)*10+10, "margin_bottom", 0.12, "paddings",  [0.03, 0.03, 0.08, 0.05]/2);
    plot(result(iciIdx).PSTH(:, 1), result(iciIdx).PSTH(:, 2)); hold on
    if iciIdx <= floor((length(result)-1)/10)*10
        xticklabels("");
    end

    % drawnow;
end
scaleAxes(FigPSTH, "y");
scaleAxes(Fig, "x", Window);
addLines2Axes(Fig, lines);

end




