clear ; clc
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% SPR
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
            "SPR_RNP_TBOffset_Recording.xlsx");

% load excel
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2struct(readtable(recordPath, opts));
sort = [recordInfo.sort]';
exported = [recordInfo.exported]';
selIdx = find(sort == 1 & exported == 0);

% export sorted and unprocessed spike data 
for i = selIdx'
    disp(strcat("processing ", recordInfo(i).BLOCKPATH, "... (", num2str(i), "/", num2str(max(selIdx)), ")"));
    saveXlsxRecordingData_RatNP("F:\RNP", recordInfo, i, recordPath);
end