function spikeDataset = spikeByCh(data)
data(:, 1) = data(:, 1) * 1e3;
data(:, 2) = data(:, 2) + 1;
chs = unique(data(:, 2));
spikeTime = data(: ,1);
spikeChs = data(:, 2);
for cIndex = 1 : length(chs)
    spikes{cIndex, 1} = spikeTime(spikeChs == chs(cIndex));
end

realChs = mod(chs, 1000);
spikeDataset = struct('ch', num2cell(chs), 'spike', spikes, 'realCh', num2cell(realChs));