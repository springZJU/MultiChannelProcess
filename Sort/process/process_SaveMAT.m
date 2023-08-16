
%% load excel
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

sort = {recordInfo.sort}';
lfpExported = {recordInfo.lfpExported}';
spkExported = {recordInfo.spkExported}';
selIdx = find(cell2mat(cellfun(@(x, y, z) isequal(x, 1) & (isequal(y, 0) | isequal(z, 0)), sort, lfpExported, spkExported, "uni", false)));

%% export sorted and unprocessed spike data
for i = selIdx'
    disp(strcat("processing ", recordInfo(i).BLOCKPATH, "... (", num2str(i), "/", num2str(max(selIdx)), ")"));
    [~, opts] = getTableValType(recordPath, "0");
    recordInfo = table2cell(readtable(recordPath, opts));
    recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
    recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);
    if matches(animal, ["MLA", "RLA"])
        saveXlsxRecordingData_MonkeyLA(MATPATH, recordInfo, i, recordPath);
    elseif matches(animal, "RNP")
        saveXlsxRecordingData_RatNP(MATPATH, recordInfo, i, recordPath);
    end

end