ccc;

data = TDTbin2mat('M:\DATA\CM\cm20231123\Block-1');

onsetTimeAll = data.epocs.Swep.onset * 1000; % ms

spikeTimeAll = data.snips.eNeu.ts * 1000; % ms
chAll = data.snips.eNeu.chan;

ch = 8;
spikeTimeAll = spikeTimeAll(chAll == ch);

window = [-200, 1000];
spikesByTrial = arrayfun(@(x) spikeTimeAll(spikeTimeAll >= x + window(1) & spikeTimeAll <= x + window(2)) - x, onsetTimeAll, "UniformOutput", false);

[latency, P, spikes] = calLatency(spikesByTrial, [0, 300], [-200, 0]);
figure;
plot(spikes, P);
set(gca, "YScale", "log");
lines = [];
lines(1).X = latency;
lines(2).Y = 1e-6;
addLines2Axes(lines);

figure;
rasterData.X = spikesByTrial;
mRaster(rasterData);

[psth, edge] = calPSTH(spikesByTrial, window, 10, 1);
figure;
plot(edge, psth);