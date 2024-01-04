simThr = 0.7;
QThr = 0.15;
RThr = 0.05;
frThrMean = 1; 
frThr0 = 0.5;

cd(npypath);

idSimilar = readNPY('similar_templates.npy');
clusterAll = double(readNPY('spike_clusters.npy'));
clusterID = unique(clusterAll);

idSimilar = idSimilar(ismember(1:length(idSimilar), clusterID+1), ismember(1:length(idSimilar), clusterID+1));

spikeTime = double(readNPY('spike_times.npy'))/fs;
spikeTrain = cellfun(@(x) spikeTime(clusterAll == x), num2cell(clusterID), "uni", false);
spikeFR    = cellfun(@length, spikeTrain) / (spikeTime(end) - spikeTime(1));

template = readNPY('templates.npy');
simCell = mCell2mat(cellfun(@(x, y) mNchoosek(find(all(spikeFR(x > simThr) > frThr0) & x > simThr & ~ismember(1:length(idSimilar), y)), 1:sum(x > simThr)-1, y), num2cell(idSimilar, 2), num2cell(1:length(idSimilar))', "UniformOutput", false));
if ~isempty(simCell)
similarPool = mUniqueCell(simCell);
segIdx = find(cellfun(@(x, y) max(x) < min(y), similarPool, [similarPool(2:end); similarPool(end)]));
mergePool = cellfun(@(x) similarPool(x(1) : x(2)), num2cell([[1; segIdx+1], [segIdx; length(similarPool)]], 2), "UniformOutput", false);

[K, Qi, Q00, Q01, rir] = cellfun(@(x) cellfun(@(y) ccg(cell2mat(spikeTrain(ismember(1:length(clusterID), y)')), cell2mat(spikeTrain(ismember(1:length(clusterID), y)')), 500, 1/1000), x, "UniformOutput", false), mergePool, "UniformOutput", false);
Q = cellfun(@(x, y, z) cellfun(@(m, n, k) min(m/(max(n, k))), x, y, z), Qi, Q00, Q01,"UniformOutput",false);
R = cellfun(@(x) cellfun(@(y) min(y), x), rir, "UniformOutput",false);
accIdx = cellfun(@(x, y, z) find(x < QThr & y < RThr & cellfun(@(k) mean(spikeFR(k)) > frThrMean, z)), Q, R, mergePool, "UniformOutput", false); 
% bestIdx : the largest set meeting the criterion or the min Q value in several sets with same size
[~, bestIdx] = cellfun(@(x, y, z)  max(sum([2*(cellfun(@length, x(y)) == max(cellfun(@length, x(y)))), z(y)-min(z(y)) == 0], 2)), mergePool, accIdx, Q, "UniformOutput", false);
mergeIdx = mCell2mat(cellfun(@(x, y, z, k) [x(y(z)) k(y(z))], mergePool, accIdx, bestIdx, Q, "UniformOutput", false));
[~, idx]= mUniqueCell(cellfun(@(x) double(clusterID(x)), mergeIdx(:, 1), "UniformOutput", false));
mergeIdx = mergeIdx(idx, :);

if ~isempty(mergeIdx)
    mergeCluster = cellfun(@(x) clusterID(x), mergeIdx(:, 1), "UniformOutput", false);
    for rIndex = 1 : length(mergeCluster)
        clusterAll(ismember(clusterAll, mergeCluster{rIndex}(2:end))) = mergeCluster{rIndex}(1);
        spikeFR(mergeIdx{rIndex}(1)) = mean(spikeFR(mergeIdx{rIndex}));
    end
    idToDel = spikeFR < frThr0 | ismember(clusterID, cell2mat(cellfun(@(x) x(2:end), mergeCluster, "UniformOutput", false)));
else
    idToDel = spikeFR < frThr0;
end
else
    idToDel = spikeFR < frThr0;
end

% 打开cluster_info.tsv文件进行读取
filename1 = fullfile(npypath, 'cluster_info.tsv');
fileID1 = fopen(filename1, 'r');
% 读取.tsv文件的内容
fieldNames1 = textscan(fileID1, '%s%s%s%s%s%s%s%s%s%s%s', 'HeaderLines', 0);
array1 = [fieldNames1{:}]; 
array1 = array1(:, ismember(array1(1, :), ["cluster_id", "ch"]));
fclose(fileID1);

% 打开cluster_group.tsv文件进行读取
filename2 = fullfile(npypath, 'cluster_group.tsv');
fileID2 = fopen(filename2, 'r');
% 读取.tsv文件的内容
fieldNames2 = textscan(fileID2, '%s%s%s%s%s%s%s%s%s%s%s', 'HeaderLines', 0);
array2 = [fieldNames2{:}]; 
array2 = array2(:, ismember(array2(1, :), ["cluster_id", "group"]));
fclose(fileID2);

Samefield = string(intersect(array1(1, :), array2(1, :)));
array = [array1(:, contains(array1(1, :), Samefield)), array1(:, ~contains(array1(1, :), Samefield)), ...
    array2(:, ~contains(array2(1, :), Samefield))];
fields = array(1, :); 
values = array(2:end, 1:end); 
values(:, [1, 2]) = cellfun(@(x) str2double(x), values(:, [1, 2]), "UniformOutput", false);
values(:, 3) = cellfun(@(x) string(x), values(:, 3), "UniformOutput", false);
array = [fields; values];
cluster_info = cell2struct(array(2:end, :), array(1, :), 2);

% id和ch对应
if exist("ExcludeIDLabels", "var") && ~isempty(ExcludeIDLabels)
    id = [cluster_info(~contains([cluster_info.group], ExcludeIDLabels, "IgnoreCase", true) & ~idToDel').cluster_id]';
    ch = [cluster_info(~contains([cluster_info.group], ExcludeIDLabels, "IgnoreCase", true) & ~idToDel').ch]' + 1;
    idCh = sortrows([id, ch], 1);
else
    id = [cluster_info.cluster_id]';
    ch = [cluster_info.ch]' + 1;
    idCh = sortrows([id, ch], 1);
    idCh(idToDel, :) = [];
end

chs = unique(idCh(:, 2));
for cIndex = 1 : length(chs)
    idx = find(idCh(:, 2) == chs(cIndex));
    for index = 1 :length(idx)
        idCh(idx(index), 2) = (index - 1)*1000 + chs(cIndex);
    end
end


