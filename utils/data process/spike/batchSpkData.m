function res = batchSpkData(spkData, params)
parseStruct(params);
if ~iscolumn(spkData)
    spkData = spkData';
end

chSPK_All = {spkData.chSpikeLfp.chSPK}';
stimStr = {spkData.chSpikeLfp.stimStr}';
trialsRaw = {spkData.chSpikeLfp.trialsRaw}';

%% process spike
for cIndex = 1 : length(spkData.chSpikeLfp(1).chSPK)
    dateStr{cIndex, 1} = cellfun(@(x) [spkData.date, char(x(cIndex).info)], chSPK_All(1), "UniformOutput", false);
    temp = addFieldToStruct(rmfield(cell2mat(cellfun(@(x) x(cIndex), chSPK_All, "UniformOutput", false)), "info"), [stimStr, trialsRaw], ["stimStr"; "trialsRaw"]);

    ChangeSpike{cIndex, 1} = cellfun(@(y, k) rowFcn(@(x) y(y(:, 2) == x), k, "UniformOutput", false), {temp.spikePlot}', {temp.trialsRaw}', "UniformOutput", false);
    OnsetSpike{cIndex, 1} = cellfun(@(x, y) cellfun(@(k) k + y, x, "UniformOutput", false), ChangeSpike{cIndex, 1}, num2cell(S1Duration'), "UniformOutput", false);

    % judge if there is a significant difference
    ChangeRes{cIndex, 1} = cell2mat(cellfun(@(x) spikeDiffWinTest(x, winChangeResp, winChangeBase, "Tail", "right", "Alpha", Alpha, "absThr", absThr, "sdThr", sdThr), ChangeSpike{cIndex, 1}, "UniformOutput", false));
    OnsetRes{cIndex, 1} = cell2mat(cellfun(@(x) spikeDiffWinTest(x, winOnsetResp, winOnsetBase, "Tail", "right", "Alpha", Alpha, "absThr", absThr, "sdThr", sdThr), OnsetSpike{cIndex, 1}, "UniformOutput", false));


    % compute latency
        OnsetLatency{cIndex, 1}  = [];  ChangeLatency{cIndex, 1} = [];
%         OnsetLatency{cIndex, 1}  = cell2mat(cellfun(@(x) peakWidthLatency(x, winOnsetBase, latencyWin, binpara, "returnVal", "latency", "latencyMethod", latencyMethod, "firstSpkWin", [10, 100], "peakRatio", peakRatio), OnsetSpike{cIndex, 1}, "UniformOutput", false));
%         ChangeLatency{cIndex, 1} = cell2mat(cellfun(@(x) peakWidthLatency(x, winOnsetBase, latencyWin, binpara, "returnVal", "latency", "latencyMethod", latencyMethod, "firstSpkWin", [10, 100], "peakRatio", peakRatio), ChangeSpike{cIndex, 1}, "UniformOutput", false));
% 


    
%         % compute PSTH
%         OnsetPSTH{cIndex, 1}  = cellfun(@(x) calPsth(x,binpara, 10e3), OnsetSpike{cIndex, 1},  "UniformOutput", false);
%         ChangePSTH{cIndex, 1} = cellfun(@(x) calPsth(x,binpara, 10e3), ChangeSpike{cIndex, 1}, "UniformOutput", false);
end


ChangeOnRatio = cellfun(@(x) (cell2mat({x.frMean_Resp}') - cell2mat({x.frMean_Base}')) ./ (cell2mat({x.frMean_Resp}') + cell2mat({x.frMean_Base}')), ChangeRes, "UniformOutput", false);
% ChangeOnRatio = cellfun(@(x) cell2mat({x.frMean_Resp}') - cell2mat({x.frMean_Base}'), ChangeRes, "UniformOutput", false);

res = cell2struct([ dateStr,   ChangeRes,    OnsetRes,   ChangeOnRatio,   OnsetSpike,   ChangeSpike,   OnsetLatency,   ChangeLatency], ...
                  ["dateStr", "ChangeRes",  "OnsetRes", "ChangeOnRatio", "OnsetSpike", "ChangeSpike", "OnsetLatency", "ChangeLatency"], 2);

end
