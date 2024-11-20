function [wfMean, wfRaw] = loadWfMean(dateStr, chIdx)
protStr = evalin("base", "protStr");
ROOTPATH = evalin("base", "ROOTPATH");

MATPATH = string(dirItem(ROOTPATH, strcat(protStr,"\\", dateStr, "\\spkWave.mat"), "folderOrFile", "file"));

load(MATPATH)
info = dir(MATPATH);
ch = [spkWave.MChInID]';
chs = unique(ch);
for cIndex = 1 : length(chs)
    idx = find(ch == chs(cIndex));
    if length(idx) > 1
        for i = 2 : length(idx)
            spkWave(idx(i)).MChInID = 1000 * (i-1) + ch(idx(i));
        end
    end
end
spkRes = dirItem(strrep(ROOTPATH, "Data", "Figures"), strcat(protStr, "\\", dateStr, "\\spkRes.mat"), "folderOrFile", "file");
load(spkRes{1});
FigCH = double(erase(string({chSpikeLfp(1).chSPK.info}), "CH"))';

if ~isequal(FigCH, sort([spkWave.MChInID]'))
    if isequal(FigCH+1, sort([spkWave.MChInID]'))
        chIdx = chIdx + 1;
    elseif isequal(FigCH-1, sort([spkWave.MChInID]'))
        chIdx = chIdx - 1;
    end
end

try
wfMean = spkWave([spkWave.MChInID]' == chIdx).waveFormsMean;

waveform = spkWave([spkWave.MChInID]' == chIdx).waveForms;
waveform(any((abs(waveform) > 50), 2), :) = [];
groupSize = 50;
groups = [1 : groupSize : floor(size(waveform, 1)/groupSize)*groupSize; groupSize : groupSize : floor(size(waveform, 1)/groupSize)*groupSize];
wfRaw =  cell2mat(cellfun(@(x) mean(waveform(x(1):x(2), :), 1), num2cell(groups, 1)', "uni", false));

catch
    wfMean = [];
    wfRaw = [];
end
end