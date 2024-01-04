
%% Parameter Settings
% windows
windowParams.Window              = [-200 1000]; % ms
windowParams.psthPara.binsize    = 50; % ms
windowParams.psthPara.binstep    = 5; % ms
% sustain
try 
    sustainWin                    = evalin("base", "sustainWin");
catch
    sustainWin                   = [100, 500];
end
windowParams.sustainWin          = sustainWin;
% onset
windowParams.onRespWin           = [0, sustainWin(1)];
windowParams.onBaseWin           = [-sustainWin(1), 0];
% offset
windowParams.offRespWin          = [0, 200] + sustainWin(2);
windowParams.offBaseWin          = sustainWin(2) + [300, 500];
% stimStr
stimStrs                         = strrep( ...
                                   [{'Noise'}; ...
                                   cellfun(@(x, y, z) [num2str(x), ' Hz,', num2str(rats(y, z)), ' Octave'], ...
                                   num2cell(reshape(repmat(250*2.^(0:7), 3, 1), [], 1)), num2cell(repmat([0, 1/3, 1]', 8, 1)), num2cell(repmat([1, 3, 1]', 8, 1)), "UniformOutput", false); ...
                                   ], ...
                                   '0 Octave', 'Pure Tone');
mkdir(FIGPATH)
for cIndex = 1 : length(spkRes)
    result = cell2mat(cellfun(@(x) quantifyResp(x, windowParams), {spkRes(cIndex).spkData.spikes}', "uni", false));
    result = structcat(addFieldToStruct(rmfield(spkRes(cIndex).spkData, "spikes"), stimStrs, "stimStr"), result);
    Fig = plotResOfBPN(result, windowParams);
    mPrint(Fig, fullfile(FIGPATH, ['CH', num2str(spkRes(cIndex).ch)]), "-djpeg", "-r0");
    close(Fig);
end

function result = quantifyResp(spikes, windowParams)
parseStruct(windowParams);
%% quantifying
result.spikes = spikes;
PSTH = calPsth(spikes, psthPara, 1e3, "EDGE", Window);
result.PSTH                  = PSTH;
% sustain response
[susRespFR, ~, susRespCount]   = calFR(spikes, sustainWin);
[susBaseFR, ~, susBaseCount]   = calFR(spikes, sustainWin);
result.susRespFR              = susRespFR;
result.susBaseFR              = susBaseFR;
result.susRespCount           = susRespCount;
result.susBaseCount           = susBaseCount;

% onset response
% decide if an obvious (p < 0.05) onset response is elicited
[onRespFR, ~, onRespCount]   = calFR(spikes, onRespWin);
[onBaseFR, ~, onBaseCount]   = calFR(spikes, onBaseWin);
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
[offRespFR, ~, offRespCount] = calFR(spikes, onRespWin);
[offBaseFR, ~, offBaseCount] = calFR(spikes, onBaseWin);
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


function Fig = plotResOfBPN(result, windowParams)
parseStruct(windowParams);
%% plot
Fig = figure;
maximizeFig
% seperate dashed lines
lines         = cell2struct(num2cell([onRespWin, offRespWin]), "X");
[row, col]    = find(reshape(1:length(result)-1, 3, []));
colNum = max(col); rowNum = max(row)+1;
[~, reOrgIdx] = sortrows([length(result); (row-1)*fix((length(result)-1)/3) + col]);
resultOld     = result;
result        = result(reOrgIdx);
for iciIdx = 1 : length(result)
    %% raster plot
    FigRaster(iciIdx) = mSubplot(rowNum*2+1, colNum, iciIdx+floor((iciIdx-1)/colNum)*colNum, "margin_top", 0.12, "paddings",  [0.03, 0.03, 0.08, 0.05]/2);
    spikes = result(iciIdx).spikes;
    spikePlot        = mCell2mat(cellfun(@(x, y) [x, ones(length(x), 1)*y], spikes, num2cell(1:length(spikes))', "UniformOutput", false));
    if ~isempty(spikePlot)
        scatter(spikePlot(:, 1), spikePlot(:, 2), 5, "red", "filled"); hold on
    end
    % sustain response
    plot(sustainWin,  [1, 1] * length(spikes)+1, "color", "#FFA500", "LineStyle", "-", "LineWidth", 5); hold on
    % onset response
    plot(onRespWin,  [1, 1] * length(spikes)+1, "color", "green",   "LineStyle", "-", "LineWidth", 5); hold on
    % offet response
    plot(offRespWin, [1, 1] * length(spikes)+1, "color", "cyan",    "LineStyle", "-", "LineWidth", 5); hold on
    ylim([0, length(spikes)+1]);
    xticklabels("");
    title(result(iciIdx).stimStr);

    %% PSTH plot
    FigPSTH(iciIdx) = mSubplot(rowNum*2+1, colNum, iciIdx+floor((iciIdx-1)/colNum)*colNum+colNum, "margin_bottom", 0.12, "paddings",  [0.03, 0.03, 0.08, 0.05]/2);
    plot(result(iciIdx).PSTH(:, 1), result(iciIdx).PSTH(:, 2)); hold on
    xticklabels("");
end
%% comparison
for fcIdx = 1 : colNum
    FigCompare(fcIdx) = mSubplot(rowNum*2+1, colNum, (max(row)+1)*colNum*2+fcIdx, "margin_top", 0.12, "paddings",  [0.03, 0.03, 0.08, 0.05]/2);
    compRes = result(3*(fcIdx)-2 : 3*fcIdx);
    colors = ["r", "b", "k"];
    dispName = ["PureTone", "BPN 1/3 Octave", "BPN 1 Octave"];
    for cmpIdx = 1 : 3
        plot(compRes(cmpIdx).PSTH(:, 1), compRes(cmpIdx).PSTH(:, 2), 'Color', colors(cmpIdx), "LineStyle", "-", "DisplayName", dispName(cmpIdx)); hold on;
    end
    title(strrep(result(fcIdx).stimStr, 'Pure Tone', 'Comparison'));
end
% add legend
lgdAxes = mSubplot(rowNum*2+1, colNum, iciIdx+floor((iciIdx-1)/colNum)*colNum+colNum+1, "margin_bottom", 0.12, "paddings",  [0.03, 0.03, 0.08, 0.05]/2);
lgdAxes.Visible = "off";
legend(lgdAxes, FigCompare(1).Children, 'Location','southeast');

%% scale axes
scaleAxes([FigPSTH, FigCompare], "y");
scaleAxes(Fig, "x", Window);
addLines2Axes([FigRaster, FigPSTH, FigCompare], lines);

%% add BPN/PT(s) ratio
textAxes = mSubplot(rowNum*2+1, colNum, iciIdx+floor((iciIdx-1)/colNum)*colNum+colNum+2, [colNum-2, 2], "alignment", "bottom-left", "margin_bottom", 0.12, "paddings",  [0.03, 0.03, 0.08, 0.05]/2);
textAxes.Visible = "off";
maxPT  = max([result(contains({result.stimStr}, "Pure Tone")).susRespFR]);
maxBPN = max([result(contains({result.stimStr}, "Octave")).susRespFR]);
text(textAxes, 0.05, 0.5, {...
     'Sustain Window: 100 to 500 ms relative to onset'; ...
    ['Max fring rate of Pure Tones: ', num2str(maxPT), ' Hz']; ...
    ['Max fring rate of BPN: ',        num2str(maxBPN), ' Hz']; ...
    ['BPN/PT(s) ratio: maxBPN/maxPT = ', num2str(maxBPN/maxPT)]...
    }, "FontSize", 15)

end




