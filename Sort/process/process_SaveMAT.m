
%% load excel
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

sort = {recordInfo.sort}';
lfpExported = {recordInfo.lfpExported}';
spkExported = {recordInfo.spkExported}';
idSel = num2cell(ismember(double(string({recordInfo.ID}))', customInfo.idSel));

selIdx = find(cell2mat(cellfun(@(x, y, z, w) isequal(x, 1) & (isequal(y, 0) | isequal(z, 0) | customInfo.ReSaveMAT) & isequal(w, 1), sort, lfpExported, spkExported, idSel, "uni", false)));
if isempty(selIdx)
    return
end
recTech = recordInfo(selIdx).recTech;
%% export sorted and unprocessed spike data
for i = selIdx'
    disp(strcat("processing ", recordInfo(i).BLOCKPATH, "... (", num2str(i), "/", num2str(max(selIdx)), ")"));
    [~, opts] = getTableValType(recordPath, "0");
    recordInfo = table2cell(readtable(recordPath, opts));
    recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
    recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);
    if matches(recTech, "TDT")
        saveXlsxRecordingData_MonkeyLA(MATPATH, recordInfo, i, recordPath);
    elseif matches(recTech, "NeuroPixel")
        saveXlsxRecordingData_RatNP(MATPATH, recordInfo, i, recordPath);
    elseif matches(recTech, "RHD")
        saveXlsxRecordingData_RHD(MATPATH, recordInfo, i, recordPath);
    end

end
