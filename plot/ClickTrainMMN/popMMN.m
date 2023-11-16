ccc;
%%
% extract channel from excel separately
spikeDataset.ch
% load mat from every penetrate
trialAllRaw = trialAll;
    % exclude trials
  for dIndex = 1:length(stitype)  
     [res, trialnum] = selectSpikeMMN(spikeDataset, trialAllRaw, windowParams, 'trial onset', stitype(dIndex));   

     trialAll(indx) = [];
  end
  % process 

% save

%% batch
%pop parameter
% load and merge mat
ROOTPATH = "E:\MonkeyLinearArray\Figure\CTL_New";
protStr = "TB_BaseICI_4_8_16";
popRes = loadDailyData(ROOTPATH, "MATNAME", "spkRes.mat", "protocols", protStr, "DATE", ["cm", "MGB"]);

% process and plot
%%
Fig00 = figure;
SI1 = [chSpikeLfp(1).chSPK.CSI];
SI2 = [chSpikeLfp(3).chSPK.CSI];
mSubplot(Fig00, 6, 3, 1, [1 1]);
plot(SI1, SI2, 'k.', 'MarkerSize', 14); hold on;
plot([0 0], [-1, 1], 'k--'); hold on; plot([-1, 1], [0 0], 'k--'); hold on;
axis([-1, 1, -1, 1]);
xlabel('J30|30');ylabel('Ascend');

SI1 = [chSpikeLfp(2).chSPK.CSI];
SI2 = [chSpikeLfp(4).chSPK.CSI];
mSubplot(Fig00, 6, 3, 4, [1 1]);
plot(SI1, SI2, 'k.', 'MarkerSize', 14); hold on;
plot([0 0], [-1, 1], 'k--'); hold on; plot([-1, 1], [0 0], 'k--'); hold on;
axis([-1, 1, -1, 1]);
xlabel('Descend');ylabel('Ascend');

SI1 = [chSpikeLfp(5).chSPK.CSI];
SI2 = [chSpikeLfp(7).chSPK.CSI];
mSubplot(Fig00, 6, 3, 7, [1 1]);
plot(SI1, SI2, 'k.', 'MarkerSize', 14); hold on;
plot([0 0], [-1, 1], 'k--'); hold on; plot([-1, 1], [0 0], 'k--'); hold on;
axis([-1, 1, -1, 1]);
xlabel('J50|60');ylabel('Reg4');

SI1 = [chSpikeLfp(6).chSPK.CSI];
SI2 = [chSpikeLfp(8).chSPK.CSI];
mSubplot(Fig00, 6, 3, 10, [1 1]);
plot(SI1, SI2, 'k.', 'MarkerSize', 14); hold on;
plot([0 0], [-1, 1], 'k--'); hold on; plot([-1, 1], [0 0], 'k--'); hold on;
axis([-1, 1, -1, 1]);
xlabel('Descend');ylabel('J30|30');

SI1 = [chSpikeLfp(9).chSPK.CSI];
SI2 = [chSpikeLfp(11).chSPK.CSI];
mSubplot(Fig00, 6, 3, 16, [1 1]);
plot(SI1, SI2, 'k.', 'MarkerSize', 14); hold on;
plot([0 0], [-1, 1], 'k--'); hold on; plot([-1, 1], [0 0], 'k--'); hold on;
axis([-1, 1, -1, 1]);
xlabel('fuza600');ylabel('fuza680');

SI1 = [chSpikeLfp(10).chSPK.CSI];
SI2 = [chSpikeLfp(12).chSPK.CSI];
mSubplot(Fig00, 6, 3, 13, [1 1]);
plot(SI1, SI2, 'k.', 'MarkerSize', 14); hold on;
plot([0 0], [-1, 1], 'k--'); hold on; plot([-1, 1], [0 0], 'k--'); hold on;
axis([-1, 1, -1, 1]);
xlabel('J50|50');ylabel('J0|10');
% save
print(Fig00, strcat(FIGPATH, '\CSI'), "-djpeg", "-r300");

close all;
