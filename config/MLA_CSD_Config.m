function [badCh, dz] = MLA_CSD_Config(MATPATH)
if contains(MATPATH, "SPR")
    recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\RatSiliconRecording\SPR_RLA_TBOffset_Recording.xlsx");
elseif contains(MATPATH, "DXY")
    recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\RatSiliconRecording\DXY_RLA_TBOffset_Recording.xlsx");
elseif contains(MATPATH, "ZYY")
    recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\RatSiliconRecording\ZYY_RLA_TBOffset_Recording.xlsx");
end
recordInfo = table2struct(readtable(recordPath));

temp = strsplit(MATPATH, "\");
dateStr = string(temp{end - 1});
Date = string(strsplit(dateStr, "_"));
Date = Date(1);

BLOCKPATH = string({recordInfo.BLOCKPATH})';
dIndex = contains(BLOCKPATH, Date);
if any(dIndex)
    badCh = unique([recordInfo(dIndex).badChannel]);
    if badCh <= 0
        badCh = [];
    end
    dz = unique([recordInfo(dIndex).dz])/1000;
else
    badCh = 9;
    dz = 0.15;
end
return
end


