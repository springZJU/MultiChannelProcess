function [RS, vs] = RayleighStatistic(spikes, ISI, winRS, trialNum)
narginchk(2, 4);

if iscell(spikes)
    trialNum = length(spikes);
%     spikes = cell2mat(spikes);
end

if isempty(spikes)
    vs = 0;
    RS = 0;
    return;
end

if nargin >= 3
    spikes = spikes(spikes >= winRS(1) & spikes <= winRS(2));
end

if ~exist("trialNum", "var")
    error("trialNum should be provided if input is a vector!");
end
% RS_total = 0;
% vs_total = 0;
% for i = 1:trialNum
%     current_spikes = spikes{i};
%     piBuffer = 2 * pi * current_spikes / ISI;
%     n = length(current_spikes);
%     sumCos = sum(cos(piBuffer));
%     sumSin = sum(sin(piBuffer));
%     vs = sqrt(sumCos^2 + sumSin^2) / n;
%     vs_total = vs_total + vs;
%     RS = n * vs^2;
%     RS_total = RS_total + RS;
% end
% RS_avg = RS_total / trialNum;
% vs_avg = vs_total/trialNum;
% % 计算 p 值
% p = exp(-RS_avg);


piBuffer = 2 * pi * cell2mat(spikes) / ISI;
n = length(cell2mat(spikes));
sumCos = sum(cos(piBuffer));
sumSin = sum(sin(piBuffer));
vs = sqrt(sumCos^2 + sumSin^2) / n;
RS = 2 * n * vs^2;
end
