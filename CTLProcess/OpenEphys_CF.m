%%
ccc;
DATAPATH = "S:\neuropixels\openEphys\Ratzyy3_20231103\Record Node 121\experiment2\recording2\continuous\Neuropix-PXI-122.ProbeA-AP\continuous.dat";
BLOCKPATH = "I:\neuroPixels\TDTTank\Rat3_ZYY\Rat3ZYY20231103\Block-19";
fs = 30e3; % Hz

ch = 112;

dataInfo = dir(DATAPATH);
dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
dataTypeNBytes = numel(typecast(cast(0, dataType), 'uint8')); % determine number of bytes per sample
nCh = 385;
nSamp = fix(dataInfo.bytes/(nCh * dataTypeNBytes));  % Number of samples per channel
mmf = memmapfile(DATAPATH, 'Format', {dataType, [nCh nSamp], 'x'});
data = single(mmf.Data(1).x(ch, :));

%% Alignment
temp = mmf.Data(1).x(end, :);
idx = find(diff(temp) == 1) + 1;

%%
dataTDT = TDTbin2mat(char(BLOCKPATH), 'TYPE', {'epocs'});
data = TDTDataConvertor(data, fs);
data.epocs = dataTDT.epocs;
data.epocs.Swep.onset = idx' / fs;

%%
windowParams.window = [0 100]; % ms

sortData = mysort(data, [], "reselect", "preview");

plotSSEorGap(sortData);
plotPCA(sortData, [1 2 3]);
plotWave(sortData);
plotSpikeAmp(sortData);

result.label = "";
result.windowParams = windowParams;

for cIndex = 1:sortData.K
    result.data = sFRAProcess(data, windowParams, sortData, cIndex);
    plotTuning(result, "on");
end
