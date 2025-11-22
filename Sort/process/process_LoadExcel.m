[~, opts] = getTableValType(recordPath, "0");
opts.VariableTypes{1} = 'double';
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {"double"};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);

% selData = recordInfo(contains([recordInfo.BLOCKPATH]', dateSel));
selData = recordInfo(ismember([recordInfo.ID]', idSel));
if length(selData) == length(recordInfo)
    selData(1) = [];
end
recID = unique([selData.ID]', 'stable');