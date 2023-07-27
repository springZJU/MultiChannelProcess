%% TDT Data
data = TDTbin2mat('H:\MGB\DDZ\ddz20230725\Block-17', 'CHANNEL', 4);
Window = [-200, 200];
segWin = num2cell(Window + data.epocs.Swep.onset*1000, 2);
trialN = num2cell(1 : length(data.epocs.Swep.onset))';
spikes = data.snips.eNeu.ts* 1000;
noiseSpike = cell2mat(cellfun(@(x, y) [findWithinInterval(spikes, x) - x(1) + Window(1), fix(y)*ones(length(findWithinInterval(spikes, x)), 1)], segWin, trialN, "UniformOutput", false));

[peak, width, latency, Fig] = peakWidthLatency(noiseSpike, [-100, 0], [-50, 150], 1 : length(trialN));
