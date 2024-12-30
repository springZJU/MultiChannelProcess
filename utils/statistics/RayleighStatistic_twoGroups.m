function [RS, vs] = RayleighStatistic_twoGroups(spikes1, spikes2, ISI, winRS, trialNum1, trialNum2)
narginchk(3, 6);

if iscell(spikes1)
    trialNum1 = length(spikes1);
    trialNum2 = length(spikes2);
    spikes1 = cell2mat(spikes1);
    spikes2 = cell2mat(spikes2);
end

if isempty(spikes1) || isempty(spikes2)
    vs = 0;
    RS = 0;
    return;
end

if nargin >= 4
    spikes1 = spikes1(spikes1 >= winRS(1) & spikes1 <= winRS(2));
    spikes2 = spikes2(spikes2 >= winRS(1) & spikes2 <= winRS(2));
end

if ~exist("trialNum1", "var")
    error("trialNum should be provided if input is a vector!");
end
    % 计算第一段的相位中心
    piBuffer1 = 2 * pi * spikes1 / ISI;
    theta_c1 = atan2(sum(sin(piBuffer1)), sum(cos(piBuffer1)));  % 计算第1段的相位中心
    % 将第1段的spike数据相位对齐
    spikes1 = spikes1 - (theta_c1 * ISI / (2 * pi));

    % 计算第二段的相位中心
    piBuffer2 = 2 * pi * spikes2 / ISI;
    theta_c2 = atan2(sum(sin(piBuffer2)), sum(cos(piBuffer2)));  % 计算第2段的相位中心
    % 将第2段的spike数据相位对齐
    spikes2 = spikes2 - (theta_c2 * ISI / (2 * pi));

    % 合并对齐后的spike数据
    combinedSpikes = [spikes1; spikes2];
    totalTrials = trialNum1 + trialNum2;  % 总的试次数量

    % 计算对齐后的VS和R

    [RS, vs] = RayleighStatistic(combinedSpikes, ISI, [min(combinedSpikes, max(combinedSpikes))], totalTrials);



end
