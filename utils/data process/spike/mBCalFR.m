% MATLAB代码：计算每个trial的平均发放率和标准误

% 输入：spikeTimes - 一个n*2的矩阵，第一列为spike时间，第二列为trial编号
%       windowStart - 窗口时间，单位为秒

function [meanFiringRate, semFiringRate] = mBCalFR(spikeTimes, window)

    % 获取所有的trial编号
    trials = unique(spikeTimes(:,2));
    
    % 初始化存储各trial发放率的数组
    firingRates = zeros(length(trials), 1);
    
    % 计算每个trial的发放率
    for i = 1:length(trials)
        trial = trials(i);
        
        % 提取当前trial的spike时间
        trialSpikes = spikeTimes(spikeTimes(:,2) == trial, 1);
        
        % 计算在指定时间窗口内的spike数量
        numSpikes = sum(trialSpikes >= window(1) & trialSpikes < window(2));
        
        % 计算发放率 (spikes per second)
        windowSize = window(2) - window(1); % 窗口大小
        firingRate = (numSpikes / windowSize)*1000;
        
        % 存储当前trial的发放率
        firingRates(i) = firingRate;
    end
    
    % 计算所有trial的平均发放率
    meanFiringRate = mean(firingRates);
    
    % 计算标准误 (Standard Error of the Mean)
    semFiringRate = std(firingRates) / sqrt(length(trials));
    
end
