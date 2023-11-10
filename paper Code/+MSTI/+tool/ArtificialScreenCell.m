function CleanIdx = ArtificialScreenCell(Datatemp, xlsPath)
    if ~isstruct(Datatemp)
        error("Wrong Data type! Need a structure.");
    elseif ~all(ismember({'Date', 'Position', 'Area', 'ID'}, fieldnames(Datatemp)))
        error("Need 'Date', 'Position', 'Area' and 'ID' infomation to find the cell that you want to exclude.");
    end

    CleanInfo = readtable(xlsPath);
    Cleanlist = cellfun(@(x, y, z, w) strjoin({x, y, z, char(strcat("CH", string(w)))}, "_"), CleanInfo.Date, ...
        CleanInfo.Position, CleanInfo.Area, num2cell(CleanInfo.ID), "UniformOutput", false);
    Datalist = arrayfun(@(x) strjoin({x.Date, x.Position, x.Area, x.ID}, "_"), Datatemp, "UniformOutput", false)';
    CleanIdx = find(ismember(string(Datalist), string(Cleanlist)));
    
    return;
end
