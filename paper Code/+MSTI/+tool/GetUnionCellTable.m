function UnionCellTable = GetUnionCellTable(Protocol1CellTable, Protocol1, Protocol2CellTable, Protocol2)

CellCount = 0;
for Protocol1CellsIdx = 1 : numel(Protocol1CellTable)
    CellCount = CellCount + 1;
    UnionCellTable(CellCount).Shank = Protocol1CellTable(Protocol1CellsIdx).ShankStr;
    UnionCellTable(CellCount).ID = string(Protocol1CellTable(Protocol1CellsIdx).ID);
    if ismember(Protocol1CellTable(Protocol1CellsIdx).ShankStr, string({Protocol2CellTable.ShankStr})') & ismember(string(Protocol1CellTable(Protocol1CellsIdx).ID), string({Protocol2CellTable.ID})')
        UnionCellTable(CellCount).(strcat("In", Protocol1)) = true;
        UnionCellTable(CellCount).(strcat("In", Protocol2)) = true;
    elseif ~ismember(Protocol1CellTable(Protocol1CellsIdx).ShankStr, string({Protocol2CellTable.ShankStr})')
        UnionCellTable(CellCount).(strcat("In", Protocol1)) = true;
        UnionCellTable(CellCount).(strcat("In", Protocol2)) = false;
    end
end

for Protocol2CellsIdx = 1 : numel(Protocol2CellTable)
    if ismember(Protocol2CellTable(Protocol2CellsIdx).ShankStr, string({Protocol1CellTable.ShankStr})') & ismember(string(Protocol2CellTable(Protocol2CellsIdx).ID), string({Protocol1CellTable.ID})')
        continue;
    elseif ~ismember(Protocol2CellTable(Protocol2CellsIdx).ShankStr, string({Protocol1CellTable.ShankStr})')
        CellCount = CellCount + 1;
        UnionCellTable(CellCount).Shank = Protocol2CellTable(Protocol2CellsIdx).ShankStr;
        UnionCellTable(CellCount).ID = string(Protocol2CellTable(Protocol2CellsIdx).ID);
        UnionCellTable(CellCount).(strcat("In", Protocol1)) = false;
        UnionCellTable(CellCount).(strcat("In", Protocol2)) = true;        
    end
end

return;
end