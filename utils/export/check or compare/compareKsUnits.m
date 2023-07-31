fs = 12207.03125;
DataPath = 'G:\ECoG\DD\dd20221122\Merge1';
NPYPATH = 'G:\ECoG\DD\dd20221122\Merge1\th7_6';
unitID = [2, 3];
wfWin = [-30, 30];
id = 0 : 10;
ch = [1, 3, 6, 5, 6, 7, 9, 11, 12, 13, 14];
IDandCHANNEL = [id; zeros(1, length(id)); ch]';

temp = getWaveForm_singleID_v2(fs, DataPath, NPYPATH, unitID, IDandCHANNEL, wfWin);

mData1 = temp(1).waveForms;
mData2 = temp(2).waveForms;
labels = vertcat(ones(size(mData1, 1), 1), 2 * ones(size(mData2, 1), 1));

%%
[coeff,score,latent] = pca(double([mData1; mData2]));

pcaData = score(:, 1:3);
result.wave = double([mData1; mData2]);
result.noiseClusterIdx = zeros(size(result.wave, 1), 1);
result.clusterIdx = labels;
result.pcaData = pcaData;
result.K = 2;
result.clusterCenter = genTemplates(result);
result.chanIdx = [temp.MChInID];
result.sortOpts.scaleFactor = 1;
result.waveAmp = max(result.wave, [], 2);
result.spikeTimeAll = vertcat(temp.SpikeTime);
recluster(result)

%%

figure
plot3(pcaData(labels == 1, 1), pcaData(labels == 1, 2), pcaData(labels == 1, 3), 'r.' );hold on;
plot3(pcaData(labels == 2, 1), pcaData(labels == 2, 2), pcaData(labels == 2, 3), 'b.' );hold on;

