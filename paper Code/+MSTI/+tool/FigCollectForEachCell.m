clear; clc;

SaveRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\";

% SearchRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
% SearchRootPath = "H:\MLA_A1补充\Figure\CTL_New_补充\";
% SearchRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\Figure\MSTI_Recording1\";
SearchRootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\Figure\MSTI_Recording2\";
ProtocolInfo = dir(SearchRootPath);
ProtocolInfo(~[ProtocolInfo.isdir]' | strcmp(string({ProtocolInfo.name}'), '.') | strcmp(string({ProtocolInfo.name}'), '..')) = [];
AllProtocols = string({ProtocolInfo.name})';

SearchPath1 = fullfile(SearchRootPath, AllProtocols(contains(AllProtocols, "BG-3")));
SearchPath2 = fullfile(SearchRootPath, AllProtocols(contains(AllProtocols, "BG-14") | contains(AllProtocols, "BG-18")));    

SmallBGCellsTable = MSTI.tool.GetCellInfoTable(SearchPath1);
LargeBGCellsTable = MSTI.tool.GetCellInfoTable(SearchPath2);
UnionCellTable = MSTI.tool.GetUnionCellTable(SmallBGCellsTable, "SmallBG", LargeBGCellsTable, "LargeBG");

for CellNumIdx = 1 : numel(UnionCellTable)
    TargetCellDirName = strcat(string(UnionCellTable(CellNumIdx).Shank), "_ID", string(UnionCellTable(CellNumIdx).ID));
    TargetCellPath = fullfile(strrep(SearchRootPath, "Figure", "FigCollectForCell"), TargetCellDirName);
    if ~exist(TargetCellPath, "dir")
        mkdir(TargetCellPath);
    else
        cd(TargetCellPath);
    end
    if UnionCellTable(CellNumIdx).InSmallBG & UnionCellTable(CellNumIdx).InLargeBG
        CopySourceInPath1 = true;
        CopySourceInPath2 = true;
    elseif UnionCellTable(CellNumIdx).InSmallBG & ~UnionCellTable(CellNumIdx).InLargeBG
        CopySourceInPath1 = true;
        CopySourceInPath2 = false;
    elseif ~UnionCellTable(CellNumIdx).InSmallBG & UnionCellTable(CellNumIdx).InLargeBG
        CopySourceInPath1 = false;
        CopySourceInPath2 = true;
    end

    if CopySourceInPath1
        ProtocolShortStr = strrep(string(regexpi(SearchPath1, "(BG.*?)ms", "tokens")), ".", "o");
        AllCellFigsTemp = dir(fullfile(SearchPath1, UnionCellTable(CellNumIdx).Shank));
        TargetCellFigNames = {AllCellFigsTemp(contains({AllCellFigsTemp.name}, ".jpg")' & ...
            ~cellfun(@isempty, regexpi({AllCellFigsTemp.name}', strcat("ID", string(UnionCellTable(CellNumIdx).ID), "\D"), "match"))).name}';
        % copy raster Figure
        CopySource_RasterFig = fullfile(SearchPath1, string(UnionCellTable(CellNumIdx).Shank), ...
                               TargetCellFigNames(contains(TargetCellFigNames, "kilo")));
        copyfile(CopySource_RasterFig, strcat(TargetCellPath, "\", ProtocolShortStr, "_Raster_ID", string(UnionCellTable(CellNumIdx).ID), ".jpg"));
        % copy Fig7_Example
        CopySource_ExampleFig = fullfile(SearchPath1, string(UnionCellTable(CellNumIdx).Shank), ...
                                TargetCellFigNames(contains(TargetCellFigNames, "Example")));
        copyfile(CopySource_ExampleFig, strcat(TargetCellPath, "\", ProtocolShortStr, "_Example_ID", string(UnionCellTable(CellNumIdx).ID), ".jpg"));
    end
    pause(1);

    if CopySourceInPath2
        ProtocolShortStr = strrep(string(regexpi(SearchPath2, "(BG.*?)ms", "tokens")), ".", "o");
        AllCellFigsTemp = dir(fullfile(SearchPath2, UnionCellTable(CellNumIdx).Shank));
        TargetCellFigNames = {AllCellFigsTemp(contains({AllCellFigsTemp.name}, ".jpg")' & ...
            ~cellfun(@isempty, regexpi({AllCellFigsTemp.name}', strcat("ID", string(UnionCellTable(CellNumIdx).ID), "\D"), "match"))).name}';
        % copy raster Figure
        CopySource_RasterFig = fullfile(SearchPath2, string(UnionCellTable(CellNumIdx).Shank), ...
                               TargetCellFigNames(contains(TargetCellFigNames, "kilo")));
        copyfile(CopySource_RasterFig, strcat(TargetCellPath, "\", ProtocolShortStr, "_Raster_ID", string(UnionCellTable(CellNumIdx).ID), ".jpg"));
        % copy Fig7_Example
        CopySource_ExampleFig = fullfile(SearchPath2, string(UnionCellTable(CellNumIdx).Shank), ...
                                TargetCellFigNames(contains(TargetCellFigNames, "Example")));
        copyfile(CopySource_ExampleFig, strcat(TargetCellPath, "\", ProtocolShortStr, "_Example_ID", string(UnionCellTable(CellNumIdx).ID), ".jpg"));
    end

    pause(1);
end

