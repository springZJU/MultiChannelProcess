function BLOCK = MLA_GetMatBlock(MATPATH)

%% select excel
if contains(MATPATH, "SPR")
    recordPath = strcat(fileparts(fileparts(fileparts(mfilename("fullpath")))), "\recordingExcel\SPR_RNP_TBOffset_Recording.xlsx");
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