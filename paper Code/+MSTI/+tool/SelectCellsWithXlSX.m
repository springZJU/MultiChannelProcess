clear;clc;

%% select all Dir name and sort it, generate .xlsx file
RootPath = "K:\ANALYSIS_202311_MonkeyLA_MSTI\FigCollectForCell\MSTI_Recording2";
if contains(RootPath, "MSTI_Recording1")
    spatialName = "Re1";
elseif contains(RootPath, "MSTI_Recording2")
    spatialName = "Re2";
end
fixXlsxName = "2023-12-12CommentTable.xlsx";
% select choice
ReExclude = true;
MonkeyName = "ddz"; 
Area = "MGB";
%
AllcellInfo = dir(RootPath);
AllcellInfo(~[AllcellInfo.isdir] | strcmp(string({AllcellInfo.name}), '.') | strcmp(string({AllcellInfo.name}), '..')) = [];
sortname = rowFcn(@(x) {x}, natsort(string({AllcellInfo.name}))');
CellInfo = struct2table(struct("CellInfo", sortname, "Exclude", cell(size(sortname)), "ChooseForExample", cell(size(sortname))));
reGenerateXLSX = true;
if ~exist(strcat(RootPath, "\CommentTable.xlsx"), "file") & reGenerateXLSX
    writetable(CellInfo, strcat(RootPath, "\CommentTable.xlsx"));
end

%% 
reply_Exclude = []; reply_ChooseForExample = [];
FixStruct = table2struct(readtable(strcat(RootPath, "\", fixXlsxName)));
NewStruct = FixStruct;
TargetCellIdx = find(contains(string({NewStruct.CellInfo})', MonkeyName) & contains(string({NewStruct.CellInfo})', Area));
for Idx = 1 : numel(TargetCellIdx)
    cellIdx = TargetCellIdx(Idx);
    cellName = NewStruct(cellIdx).CellInfo;
    disp(strcat("Make a comment of ", cellName, "..."));
    if (ReExclude & ismember(NewStruct(cellIdx).Exclude, [0])) | isnan(NewStruct(cellIdx).Exclude) | ~ismember(NewStruct(cellIdx).Exclude, [1, 0]) | isempty(NewStruct(cellIdx).Exclude)
        NewStruct(cellIdx).Exclude = validateInput(strcat("Exlucde ", cellName, "? [1/0] (1:exlude 0:maintain): "), ...
                                @(x) validateattributes(x, 'numeric', ...
                                {'>=', 0, '<=', 1, 'numel', 1, 'integer'}));
    elseif ismember(NewStruct(cellIdx).Exclude, [1, 0]) & ~ReExclude
        disp(strcat("Already Done 'Exclude', keep the latest comment..."));
    end
    
    if NewStruct(cellIdx).Exclude == 0 & isempty(NewStruct(cellIdx).ChooseForExample)
        NewStruct(cellIdx).ChooseForExample = validateInput(strcat("Choose '", cellName, "' as an Example? [G/J/N] (G:good | J:just so so | N:reject): "), ...
                                @(x) any(validatestring(x, {'G', 'J', 'N'})), 's');
    elseif NewStruct(cellIdx).Exclude == 0 & ismember(NewStruct(cellIdx).ChooseForExample, {'G', 'J', 'N'})
        disp(strcat("Already Done 'ChooseForExample', keep the latest comment..."));

    elseif NewStruct(cellIdx).Exclude == 1
        disp(strcat("This cell is excluded..."));
        NewStruct(cellIdx).ChooseForExample = 'NN';

    end
    
    writetable(struct2table(NewStruct), strcat(RootPath, "\", string(datetime('now', 'Format', 'yyyy-MM-dd')), "CommentTable.xlsx"));
end


