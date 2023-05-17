function BLOCK = MLA_GetMatBlock(MATPATH)

%% select excel
if contains(MATPATH, "SPR")
    recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\RatSiliconRecording\SPR_RLA_TBOffset_Recording.xlsx");
elseif contains(MATPATH, "DXY")
    recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\RatSiliconRecording\DXY_RLA_TBOffset_Recording.xlsx");
elseif contains(MATPATH, "ZYY")
    recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\RatSiliconRecording\ZYY_RLA_TBOffset_Recording.xlsx");
end
%% read excel
recordInfo = table2struct(readtable(recordPath));
BLOCKPATH = {recordInfo.BLOCKPATH}';
paradigm = {recordInfo.paradigm}';

%% split MATPATH
temp = string(strsplit(MATPATH, "\"));
protocol = temp(end - 2);
dateTemp = strsplit(temp(end - 1), "_");
DateStr = dateTemp(end - 1);

%% find corresponding block
pIndex = contains(BLOCKPATH, DateStr) & matches(paradigm, protocol);
BLOCK = recordInfo(pIndex).BLOCKPATH;
end