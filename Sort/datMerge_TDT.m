%% TODO
xlsxPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "SPR_RNP_TBOffset_Recording.xlsx");
tankSel = "Rat2SPR20230708";
blockGroup = {[1:4, 6:11]};

%% merge data
[~, opts] = getTableValType(xlsxPath, "0");
recordInfo = table2struct(readtable(xlsxPath, opts));
selData = recordInfo(contains([recordInfo.BLOCKPATH]', tankSel));
BLOCKPATH = cellstr([selData.BLOCKPATH]');
TANKNAME = strsplit(selData(1).BLOCKPATH, "Block");
TANKNAME = TANKNAME(1);

for mIndex = 1 : length(blockGroup)
    MERGEPATH = strcat(TANKNAME, "Merge", num2str(mIndex));
    MERGEFILE = strcat(MERGEPATH, "\Wave.bin");
    if ~exist(MERGEFILE,'file')
        TDT2binMerge(BLOCKPATH,MERGEPATH);
    end
end


