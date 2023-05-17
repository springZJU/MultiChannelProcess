function MUA = MUA_Process(trialsWave, window, selWin, fs)
trialsWave = cellfun(@(x) double(x), trialsWave, "UniformOutput", false);

bpFilt = designfilt('bandpassfir','FilterOrder',100, ...
    'CutoffFrequency1',500,'CutoffFrequency2',5000, ...
    'SampleRate', fs);

lpFilt = designfilt('lowpassfir','FilterOrder',50, ...
    'CutoffFrequency',200, 'SampleRate',fs);

t = linspace(window(1), window(2), size(trialsWave{1}, 2));
tIndex = t < selWin(1);
temp = cellfun(@(x) MUA_Compute(x, bpFilt, lpFilt), trialsWave, "UniformOutput", false);
MUA.Wave = cell2mat(cellfun(@mean, changeCellRowNum(temp), "uni", false));
% waveTemp = cellfun(@(x) interp2(x, 3), temp, "UniformOutput", false);
% MUA.Data = cell2mat(cellfun(@mean, changeCellRowNum(waveTemp), "uni", false));
temp = MUA.Wave - repmat(mean(MUA.Wave(:, tIndex), 2), 1, size(MUA.Wave, 2));
MUA.Data = interp2(temp, 3);
MUA.Chs = 1 : size(trialsWave{1}, 1);
MUA.tImage = linspace(window(1), window(2), size(MUA.Data, 2));
MUA.tWave = linspace(window(1), window(2), size(MUA.Wave, 2));
MUA.fs =fs;
end