function [chSpkRes, plotSettingRes] = RLA_PlotRasterLfp_MSTIAnesthesiaProcess(chSpikeLfp, MSTIParams)
parseStruct(MSTIParams);
%% configuration
% compute time from last std to dev 
tStdToDev  = sortrows(unique(cell2mat(cellfun(@(x, y) [roundn(diff(x([end-1, end])), -1), y], {trialAll.StdDevOnset}', {trialAll.devOrdr}', "UniformOutput", false)), "rows"), 2);
% windows for firing rate
winDevResp = repmat([0, 300], length(chSpikeLfp), 1); 
winStdResp = winDevResp - tStdToDev(:, 1);
% PSTH settings
binsize    = 50; % ms
binstep    = 5;  % ms
winPSTH    = plotWin;
tPSTH      = (winPSTH(1) + binsize/2 : binstep : winPSTH(2) - binsize/2)';
% FFT settings
minBaseICI = min(BaseICI, [], "all");
binsizeFFT = roundn(minBaseICI / 2, -1); % ms
stepFFT    = 1; % ms
tFFTPSTH   = (winPSTH(1) + binsizeFFT/2 : stepFFT : winPSTH(2) - binsizeFFT/2)';
fFFT       = linspace(0, 500 / stepFFT, floor(length(tFFTPSTH) / 2) + 1);
FFTCursor  = 1000./double(strrep(regexpi(chSpikeLfp(1).stimStr, "\d*o?\d", "match"), "o", "."));

plotSettingRes.tStdToDev = tStdToDev;
plotSettingRes.tPSTH = tPSTH;
plotSettingRes.fFFT = fFFT;

% plot settings
% rowNum     = 4; % 4 types of blocks
% colNum     = 8; % see below for details
% magginLeft = 0.1;
% dispWin    = [-3500, 1000]; % for raw raster/PSTH plot
% syncWin    = {[1, 6], [min(FFTCursor)-30, max(FFTCursor)+30]}; % {[freqBand for change rate], [freqBand for single click]}
% cmpGroup   = {[1, 3]; [2, 4]; [3, 1]; [4, 2]}; % [dev std]
% cmpDevStr  = cellfun(@(x) strjoin([regexpi(chSpikeLfp(x(1)).stimStr, ".*reg", "match"), regexpi(chSpikeLfp(x(1)).stimStr, "Dev.*ms", "match")], " ,"), cmpGroup, "UniformOutput", false);
% cmpWin     = [0, 300]; % for SSA
% RIDGroup    = {[1, 2], [1, 2], [3, 4], [3, 4]};
% RIDStr      = cellfun(@(x) regexpi(chSpikeLfp(x(1)).stimStr, "Dev.*ms", "match"), RIDGroup, "UniformOutput", false);
% RISGroup    = {[1, 2], [1, 2], [3, 4], [3, 4]};
% RISStr      = cellfun(@(x) regexpi(chSpikeLfp(x(1)).stimStr, "Std.*ms-", "match"), RISGroup, "UniformOutput", false);

%% process
spkCH =   cellfun(@(ch) ...
                cellfun(@(devOrdr) ...
                    cellfun(@(x) chSpikeLfp(devOrdr).chSPK(ch).spikePlot(chSpikeLfp(devOrdr).chSPK(ch).spikePlot(:, 2) == x, 1), num2cell(chSpikeLfp(devOrdr).trialsRaw), "UniformOutput", false), ...
                num2cell(1:length(chSpikeLfp))', "UniformOutput", false), ...
          num2cell(1:length(chSpikeLfp(1).chSPK))', "UniformOutput", false);


chSpkRes = cell2struct([
                        cellstr({chSpikeLfp(1).chSPK.info}'), ... % channel number
                        cellfun(@(spkDev) cell2struct([ ... % inner cell2struct
                                                        cellstr([chSpikeLfp.stimStr]'), ... % stimStr
                                                        cellfun(@(spkTrial)  cell2mat(cellfun(@(spk, trialNum) [spk, trialNum*ones(length(spk), 1)], spkTrial, num2cell(1:length(spkTrial))', "UniformOutput", false)), spkDev, "UniformOutput", false) ... % plotRaster
                                                        cellfun(@(spkTrial, devWins) mean(calFR(spkTrial, devWins)), spkDev, num2cell(winDevResp, 2), "UniformOutput", false) ... % fring rate for winDevResp
                                                        cellfun(@(spkTrial, stdWins) mean(calFR(spkTrial, stdWins)), spkDev, num2cell(winStdResp, 2), "UniformOutput", false) ... % fring rate for winStdResp
                                                        cellfun(@(spkTrial, devWins) calFR(spkTrial, devWins), spkDev, num2cell(winDevResp, 2), "UniformOutput", false) ... % fring rate for winDevResp
                                                        cellfun(@(spkTrial, stdWins) calFR(spkTrial, stdWins), spkDev, num2cell(winStdResp, 2), "UniformOutput", false) ... % fring rate for winStdResp                                                        
                                                        cellfun(@(spkTrial) calPSTH(spkTrial, winPSTH, binsize, binstep), spkDev, "UniformOutput", false) ... % PSTH
                                                        cellfun(@(spkTrial) mean(cell2mat(cellfun(@(x) mfft(calPSTH({x}, winPSTH, binsizeFFT, stepFFT), 1000/stepFFT), spkTrial, "UniformOutput", false))), spkDev, "UniformOutput", false) ...
                                                        cellfun(@(spkTrial, devWins) cellfun(@(spk) sum(spk >= devWins(1) & spk <= devWins(2)), spkTrial), spkDev, num2cell(winDevResp, 2), "UniformOutput", false) ... % spk count in devWin
                                                        cellfun(@(spkTrial, stdWins) cellfun(@(spk) sum(spk >= stdWins(1) & spk <= stdWins(2)), spkTrial), spkDev, num2cell(winStdResp, 2), "UniformOutput", false) ... % spk count in stdWin
                                                        ] ... % cell array boundary for inner struct
                                                        , ["stimStr", "raster", "devFR", "stdFR", "devTrialFR", "stdTrialFR", "PSTH", "trialsPsthFFT_Mean", "devCount", "stdCount"], 2), ... % end of inner cell2struct
                        spkCH, "UniformOutput", false)] ... % cell array boundary for outer struct
                        , ["CH", "spkRes"], 2); % end of outer cell2struct

%% plot figures (4 rows * 8 columns)
% column 1-2: raster plots
% column 3-4: PSTH
% column   5: synchronization of single clicks (FFT, level 1)
% column   6: syschronization of change responses (FFT, level 2)
% column   7: SSA of the DEV in the block (PSTH, level 3)
% column   8: Regularity Idex for the DEV and STD in the block (PSTH, level 4)
% for cIndex = 1 : length(chSpkRes)
%     figure;
%     maximizeFig;
%     for dIndex = 1 : length(chSpkRes(1).spkRes)
%         spkTemp = chSpkRes(cIndex).spkRes(dIndex);
% 
%         % column 1-2: raster plots
%         rasterAxes(dIndex) = mSubplot(rowNum, colNum, (dIndex-1)*colNum+1, [2, 1], "alignment", "bottom-left");
%         col1_2_X = spkTemp.raster(:, 1); col1_2_Y = spkTemp.raster(:, 2);
%         scatter(col1_2_X, col1_2_Y, 5, "black", "filled"); hold on
%         xlim(dispWin);
%         if dIndex < length(chSpkRes(1).spkRes); xticklabels(""); end
%         title(strcat(spkTemp.stimStr, "raster plot"));
% 
%         % column 3-4: PSTH
%         PSTHAxes(dIndex) = mSubplot(rowNum, colNum, (dIndex-1)*colNum+3, [2, 1], "alignment", "bottom-left");
%         col3_4_X = tPSTH; col3_4_Y = spkTemp.PSTH;
%         plot(col3_4_X, col3_4_Y, "k-"); hold on
%         xlim(dispWin);
%         if dIndex < length(chSpkRes(1).spkRes); xticklabels(""); end
%         title(strcat(spkTemp.stimStr, "PSTH"));
% 
%         % column 5: synchronization of single clicks (FFT, level 1)
%         FFTSingleAxes(dIndex) = mSubplot(rowNum, colNum, (dIndex-1)*colNum+5, "margin_left", magginLeft);
%         col5_6_X = fFFT; col5_6_Y = spkTemp.trialsPsthFFT_Mean;        
%         plot(col5_6_X, col5_6_Y, "k-"); hold on
%         xlim(syncWin{2});
%         if dIndex < length(chSpkRes(1).spkRes); xticklabels(""); end
%         title("FFT of single clicks");
% 
%         % column 6: syschronization of change responses (FFT, level 2)
%         FFTChangeAxes(dIndex) = mSubplot(rowNum, colNum, (dIndex-1)*colNum+6, "margin_left", magginLeft);
%         plot(col5_6_X, col5_6_Y, "k-"); hold on
%         xlim(syncWin{1});
%         if dIndex < length(chSpkRes(1).spkRes); xticklabels(""); end
%         title("FFT of change responses");
% 
%         % column 7: SSA of the DEV in the block (PSTH, level 3)
%         SSAAxes(dIndex) = mSubplot(rowNum, colNum, (dIndex-1)*colNum+7, "margin_left", magginLeft);
%         devRes = chSpkRes(cIndex).spkRes(cmpGroup{dIndex}(1)); stdRes = chSpkRes(cIndex).spkRes(cmpGroup{dIndex}(2));
%         col7_devX = tPSTH; col7_devY = devRes.PSTH;
%         col7_stdX = tPSTH+tStdToDev(cmpGroup{dIndex}(2)); col7_stdY = stdRes.PSTH;
%         plot(col7_devX, col7_devY, "r-", "DisplayName", "As Dev"); hold on % as dev
%         plot(col7_stdX, col7_stdY, "k-", "DisplayName", "As Std"); hold on % as std
%         xlim(cmpWin); legend;
%         if dIndex < length(chSpkRes(1).spkRes); xticklabels(""); end
%         title(strcat("SSA:", cmpDevStr{dIndex}, ", SI:", num2str((devRes.devFR-stdRes.stdFR)/(devRes.devFR+stdRes.stdFR))));
%         [~, p_SSA] = ttest2(devRes.devTrialFR, stdRes.stdTrialFR, "Tail", "right");
%         text("string", strcat("p=", string(roundn(p_SSA, -4))), 'Units', 'normalized', 'position', [0.55,0.7]);
% 
%         % column 8: Regularity Idex for the DEV and STD in the block (PSTH, level 4)
%         % row 1/3: RID (Regularity Index for Dev); row 2/4 RIS (Regularity Index for Std)
%         RIAxes(dIndex) = mSubplot(rowNum, colNum, (dIndex-1)*colNum+8, "margin_left", magginLeft);
%         RegRes = chSpkRes(cIndex).spkRes(RIDGroup{dIndex}(1)); IrregRes = chSpkRes(cIndex).spkRes(RIDGroup{dIndex}(2));
%         col8_RegX = tPSTH + mod(dIndex+1, 2) * tStdToDev(cmpGroup{dIndex}(1)); col8_RegY = RegRes.PSTH;
%         col8_IrregX = tPSTH + mod(dIndex+1, 2) * tStdToDev(cmpGroup{dIndex}(2)); col8_IrregY = IrregRes.PSTH;       
%         plot(col8_RegX, col8_RegY, "k-", "DisplayName", "In Reg"); hold on;
%         plot(col8_IrregX, col8_IrregY, "r-", "DisplayName", "In Irreg"); hold on;
%         xlim(cmpWin); legend;   
%         if dIndex < length(chSpkRes(1).spkRes); xticklabels(""); end
%         if mod(dIndex+1, 2) % for std
%             title(strcat(RISStr{dIndex}, ", RI:", num2str((RegRes.stdFR-IrregRes.stdFR)/(RegRes.stdFR+IrregRes.stdFR))));
%             [~, p_RIS] = ttest2(RegRes.stdTrialFR, IrregRes.stdTrialFR);
%             text("string", strcat("p=", string(roundn(p_RIS, -4))), 'Units', 'normalized', 'position', [0.55, 0.7]);
%         else % dev
%             title(strcat(RIDStr{dIndex}, ", RI:", num2str((RegRes.devFR-IrregRes.devFR)/(RegRes.devFR+IrregRes.devFR))));
%             [~, p_RID] = ttest2(RegRes.devTrialFR, IrregRes.devTrialFR);
%             text("string", strcat("p=", string(roundn(p_RID, -4))), 'Units', 'normalized', 'position', [0.55, 0.7]);
%         end
% 
%         % CDR plot
%         CDRplot(dIndex, 1).TrialStim = spkTemp.stimStr;
%         CDRplot(dIndex, 1).Raster = [col1_2_X, col1_2_Y];
%         CDRplot(dIndex, 1).PSTH = [col3_4_X, col3_4_Y];
%         CDRplot(dIndex, 1).FFT = [col5_6_X', col5_6_Y'];
%         CDRplot(dIndex, 1).SSA.Dev = [col7_devX, col7_devY];
%         CDRplot(dIndex, 1).SSA.Std = [col7_stdX, col7_stdY];
%         CDRplot(dIndex, 1).Regularity.Reg = [col8_RegX, col8_RegY];
%         CDRplot(dIndex, 1).Regularity.Ireg = [col8_IrregX, col8_IrregY];        
% 
%     end
%     CellCDRInfo(cIndex, 1).ID = chSpkRes(cIndex).CH;
%     CellCDRInfo(cIndex, 1).CDRplot = CDRplot;
%     % scale axes
%     REGIdx = cellfun(@isempty, regexp([chSpikeLfp.stimStr]', "I", "start"));
%     scaleAxes(rasterAxes(REGIdx), "y");    scaleAxes(rasterAxes(~REGIdx), "y"); 
%     scaleAxes(PSTHAxes, "y");              scaleAxes(FFTSingleAxes, "y"); 
%     scaleAxes(FFTChangeAxes, "y");  scaleAxes(SSAAxes, "y");  scaleAxes(RIAxes, "y");
% 
%     % add vertical lines
%     addLines2Axes(FFTSingleAxes, cell2struct(num2cell(FFTCursor)', "X", 2));
%     addLines2Axes(FFTChangeAxes, cell2struct(num2cell(1000./[unique(tStdToDev(:, 1)); 300]), "X", 2));
%     for dIndex = 1 : length(chSpkRes(1).spkRes)
%         addLines2Axes([rasterAxes(dIndex), PSTHAxes(dIndex)], cell2struct(num2cell((-5:1:0)'*tStdToDev(dIndex)), "X", 2));
%     end
% 
%     % text axes for CSI and RI
%     textAxes = mSubplot(1, 1, 1,  "padding_top", 0);
%     set(textAxes, "Visible", "off");
%     
%     spkTemp = chSpkRes(cIndex).spkRes;
%     text(0.1, 1.03, ['CSI-Reg = ', num2str((sum([spkTemp(REGIdx).devFR]) - sum([spkTemp(REGIdx).stdFR])) / (sum([spkTemp(REGIdx).devFR]) + sum([spkTemp(REGIdx).stdFR]))), ...
%                      ', CSI-Irreg = ', num2str((sum([spkTemp(~REGIdx).devFR]) - sum([spkTemp(~REGIdx).stdFR])) / (sum([spkTemp(~REGIdx).devFR]) + sum([spkTemp(~REGIdx).stdFR]))), ...
%                      ', RID = ', num2str((sum([spkTemp(~REGIdx).devFR]) - sum([spkTemp(REGIdx).devFR])) / (sum([spkTemp(REGIdx).devFR]) + sum([spkTemp(~REGIdx).devFR]))), ...
%                      ', RIS = ', num2str((sum([spkTemp(~REGIdx).stdFR]) - sum([spkTemp(REGIdx).stdFR])) / (sum([spkTemp(REGIdx).stdFR]) + sum([spkTemp(~REGIdx).stdFR])))], ...
%                      "FontSize", 20);
% 
%     print(gcf, strcat(FIGPATH, strrep(string(chSpkRes(cIndex).CH), "CH", "ID"), ".jpg"), "-djpeg", "-r200");
%     close;
% end
% % close all;
% save(strcat(FIGPATH, "CDRplot.mat"), "CDRplot");
end
