recIdx = find(ismember([recordInfo.ID]', idSel) & ismember([recordInfo.ID]', recID(rIndex)));
recData = recordInfo(recIdx);
TANKNAME = strsplit(recData(1).BLOCKPATH, "Block");
TANKNAME = TANKNAME(1);
fs = unique([recData.SR_AP]');
recTech = unique([recData.recTech]');
selInfo(rIndex).fs = fs;
selInfo(rIndex).chNum = unique([recData.chNum]');
selInfo(rIndex).ID = unique([recData.ID]');
selInfo(rIndex).TANKNAME = TANKNAME;

if any([customInfo.exportSpkWave, customInfo.ReSaveMAT, customInfo.reExportSpk])
    selIdx = find(ismember([recordInfo.ID]', idSel) & ismember([recordInfo.ID]', recID(rIndex)));
else
    selIdx = find(ismember([recordInfo.ID]', idSel) & ismember([recordInfo.ID]', recID(rIndex)) & ~logical([1, recordInfo(2:end).sort]'));
end
selData = recordInfo(selIdx);
selInfo(rIndex).selIdx = selIdx;

%     if isfield(selData, "datPath")
%         DATAPATH = cellstr([selData.datPath]');
%     end
try
    BLOCKPATH = cellstr([selData.BLOCKPATH]');
    DATAPATH = cellstr([selData.datPath]');
end
MERGEPATH = strcat(TANKNAME, "Merge", num2str(selInfo(rIndex).ID));
MERGEFILE = strcat(MERGEPATH, "\Wave.bin");
customInfo.MERGEFILE(rIndex, 1) = MERGEFILE;
