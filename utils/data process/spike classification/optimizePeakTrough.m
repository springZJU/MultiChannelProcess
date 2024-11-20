function res = optimizePeakTrough(peakTroughInfo, troughTimeRange)
narginchk(1, 2);
if nargin < 2
    troughTimeRange = [2, 3];
end
    % 2ms - 3ms只会有一个波谷，选最小值
    troughRange = find(peakTroughInfo(:, 1) > troughTimeRange(1) & peakTroughInfo(:, 1) < troughTimeRange(2) & peakTroughInfo(:, 3) == -1);
    [~, temp] = min(peakTroughInfo(troughRange, 2));
    troughIdx = troughRange(temp(1));
    peakEarly = find(peakTroughInfo(:, 2) == max(peakTroughInfo(peakTroughInfo(:, 1) <= peakTroughInfo(troughIdx, 1), 2)), 1, "first");
    peakLate  = find(peakTroughInfo(peakTroughInfo(:, 1) > peakTroughInfo(troughIdx, 1), 2) == max(peakTroughInfo(peakTroughInfo(:, 1) > peakTroughInfo(troughIdx, 1), 2)), 1, "first") + troughIdx;
    res = peakTroughInfo([peakEarly; troughIdx; peakLate], :);
end