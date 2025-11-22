function [RS, vs, pValue] = RayleighStatistic(spikes, ISI, winRS)
% 计算 Rayleigh Statistic、Vector Strength 及其 p 值
% 输入：
%   spikes : n×1 cell，每个元素为某次 trial 的 spike 时刻
%   ISI    : 循环周期（单位与 spike 相同）
%   winRS  : 可选，时间窗口 [t_start, t_end]
% 输出：
%   RS     : Rayleigh Statistic
%   vs     : Vector Strength
%   pValue : 对应的显著性 p 值（p = exp(-RS)）

if nargin < 2
    error('至少需要 spikes 和 ISI 两个输入');
end

if isempty(spikes)
    RS = 0; vs = 0; pValue = 1;
    return;
end

% 筛选时间窗口
if nargin >= 3
    for i = 1:length(spikes)
        spikes{i} = spikes{i}(spikes{i} >= winRS(1) & spikes{i} <= winRS(2)) - winRS(1);
    end
end

% 合并所有 spike
allSpikes = cell2mat(spikes(:));
n = length(allSpikes);

% 转换为相位（单位弧度）
theta = mod(allSpikes, ISI) * 2 * pi / ISI;

% spike 数量
n = numel(theta);

% 计算 vector strength
vs = abs(mean(exp(1i * theta)));

% Rayleigh statistic
RS = 2 * n * vs^2;

% 近似 p 值（适用于较大 n）
pValue = exp(-RS);

end