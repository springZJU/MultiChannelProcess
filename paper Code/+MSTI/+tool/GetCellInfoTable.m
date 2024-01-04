function CellsTable = GetCellInfoTable(SearchPath)

ShankDirInfo = dir(SearchPath);
ShankDirInfo(~[ShankDirInfo.isdir]' | contains(string({ShankDirInfo.name}'), {'.', '..'})) = [];
ShankPath = cellfun(@(x) fullfile(SearchPath, x), {ShankDirInfo.name}, "UniformOutput", false)';
AllCellFigName = cellfun(@(x) {x(~contains({x.name}', 'ID_') & contains({x.name}', 'ID') & contains({x.name}', 'jpg')).name}', ...
    cellfun(@dir, ShankPath, "UniformOutput", false), "UniformOutput", false);
IDNum = cellfun(@(x) unique(x), ...
    cellfun(@(y) cellfun(@(z) double(string(z)), regexpi(string(y)', 'ID(\d*)', 'tokens')'), ...
    AllCellFigName, "UniformOutput", false), "UniformOutput", false);
CellsStruct = struct('Shank', {ShankDirInfo.name}', 'ID', IDNum);
CellCount = 0;
for ShankIdx = 1 : numel(CellsStruct)
    for CellIdx = 1 : numel(CellsStruct(ShankIdx).ID)
        CellCount = CellCount + 1;
        CellsTable(CellCount).ShankStr = string(CellsStruct(ShankIdx).Shank);
        CellsTable(CellCount).ID = CellsStruct(ShankIdx).ID(CellIdx);
    end
end

return;
end