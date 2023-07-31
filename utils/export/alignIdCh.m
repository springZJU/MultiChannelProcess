filename = fullfile(npypath, 'cluster_info.tsv');

% 打开.tsv文件进行读取
fileID = fopen(filename, 'r');

% 读取.tsv文件的内容
fieldNames = textscan(fileID, '%s%s%s%s%s%s%s%s%s%s%s', 'HeaderLines', 0);
array = [fieldNames{:}];
fields = array(1, :); fields(9) = [];
values = array(2:end, 1:end-1); 
values(:, [1:3, 5:10]) = cellfun(@(x) str2double(x), values(:, [1:3, 5:10]), "UniformOutput", false);
array = [fields; values];
cluster_info = cell2struct(array(2:end, :), array(1, :), 2);

% 关闭文件
fclose(fileID);

% id和ch对应
id = [cluster_info.cluster_id]';
ch = [cluster_info.ch]' + 1;
idCh = sortrows([id, ch], 2);
idCh(ismember(idCh(:, 1), idToDel), :) = [];
chs = unique(idCh(:, 2));
for cIndex = 1 : length(chs)
    idx = find(idCh(:, 2) == chs(cIndex));
    for index = 1 :length(idx)
        idCh(idx(index), 2) = (index - 1)*1000 + chs(cIndex);
    end
end




