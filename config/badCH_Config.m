function [badCH, dz] = badCH_Config(xlsxPath, MATPATH)
% load excel
if ~exist(xlsxPath, "file")
    badCH = [];
    dz    = 150;
else
    [~, opts] = getTableValType(xlsxPath, "0");
    configTable = table2struct(readtable(xlsxPath, opts));

    index = find(cellfun(@(x) contains(MATPATH, x), {configTable(2:end).Date}'));
    if ~isempty(index)
        badCH = double(strsplit(configTable(index+1).badCH, ","));
        dz    = configTable(index+1).dz;
    else
        badCH = [];
        dz    = 150;
    end
end
end