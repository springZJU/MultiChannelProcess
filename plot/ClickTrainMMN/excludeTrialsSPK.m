function [tIdx, chIdx =excludeTrialsSPK(trialsData, varargin)  % by zyy
% 假设spikeCounts是一个数组，每个元素代表一个trial的spike计数
meanSpikes = mean(spikeCounts);
stdSpikes = std(spikeCounts);

% 设定阈值，例如为平均值加上3倍标准差
threshold = meanSpikes + 3 * stdSpikes;

% 找出超过阈值的trial
outlierTrials = spikeCounts > threshold;

% 排除异常的trial
spikeCountsFiltered = spikeCounts(~outlierTrials);


Q1 = prctile(spikeCounts, 25);
Q3 = prctile(spikeCounts, 75);
IQR = Q3 - Q1;

% 定义异常值的界限
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

% 识别异常值
outlierTrials = spikeCounts < lowerBound | spikeCounts > upperBound;

% 排除异常的trial
spikeCountsFiltered = spikeCounts(~outlierTrials);
