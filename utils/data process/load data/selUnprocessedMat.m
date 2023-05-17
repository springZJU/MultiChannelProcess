function [MATPATH, recordInfo, excelIdx] = selUnprocessedMat(MATPATH, recordPath)
%% read excel
recordInfo = table2struct(readtable(recordPath));
BLOCKPATH = {recordInfo.BLOCKPATH}';
processed = [recordInfo.processed]';
paradigm = {recordInfo.paradigm}';

%% split MATPATH
temp = cellfun(@(x) strsplit(x, "\"), MATPATH, "uni", false);
protocol = string(cellfun(@(x) x(end - 2), temp, "UniformOutput", false));
dateTemp = cellfun(@(x) strsplit(x(end - 1), "_"), temp, "UniformOutput", false);
DateStr = string(cellfun(@(x) x(end - 1), dateTemp, "UniformOutput", false));

%% find unprocessed ones
pIndex = contains(BLOCKPATH, DateStr) & matches(paradigm, protocol);
MATPATH = MATPATH(processed(pIndex) ~= 0);
excelIdx = find(processed(pIndex) ~= 0);




