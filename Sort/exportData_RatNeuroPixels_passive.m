clear ; clc
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");

%% TODO
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "SPR_RNP_TBOffset_Recording.xlsx");

%% load excel
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);


sort = {recordInfo.sort}';
exported = {recordInfo.exported}';
selIdx = find(cell2mat(cellfun(@(x, y) isequal(x, 1) & isequal(y, 0), sort, exported, "uni", false)));

%% export sorted and unprocessed spike data
for i = selIdx'
    disp(strcat("processing ", recordInfo(i).BLOCKPATH, "... (", num2str(i), "/", num2str(max(selIdx)), ")"));
    try
        saveXlsxRecordingData_RatNP("I:\neuroPixels", recordInfo, 24, recordPath);
    end
end