clear ; clc
%% DDZ
ROOTPATH = "H:\MLA_A1补充\MAT Data\";
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "XHX_MLA_Recording.xlsx");


%% load excel
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

sort = {recordInfo.sort}';
% exported = {recordInfo.exported}';
% selIdx = find(cell2mat(cellfun(@(x, y) isequal(x, 1) & isequal(y, 0), sort, exported, "uni", false)));
lfpexported = {recordInfo.lfpExported}';
spkexported = {recordInfo.spkExported}';
selIdx = find(cell2mat(cellfun(@(x, y, z) (isequal(y, 0) | isequal(z, 0)) & isequal(x, 1), sort, lfpexported, spkexported, "uni", false)));

%% export sorted and unprocessed spike data
for i = selIdx'
    disp(strcat("processing ", recordInfo(i).BLOCKPATH, "... (", num2str(i), "/", num2str(max(selIdx)), ")"));
    [~, opts] = getTableValType(recordPath, "0");
    recordInfo = table2cell(readtable(recordPath, opts));
    recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
    recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

    saveXlsxRecordingData_MonkeyLA(ROOTPATH, recordInfo, i, recordPath);
end



