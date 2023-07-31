    recIdx = find(contains([recordInfo.BLOCKPATH]', dateSel) & ismember([recordInfo.ID]', recID(rIndex)));
    recData = recordInfo(recIdx);
    TANKNAME = strsplit(recData(1).BLOCKPATH, "Block");
    TANKNAME = TANKNAME(1);
    fs = unique([recData.SR_AP]');
    recTech = unique([recData.recTech]');
    selInfo(rIndex).fs = fs;
    selInfo(rIndex).chNum = unique([recData.chNum]');
    selInfo(rIndex).TANKNAME = TANKNAME;

    selIdx = find(contains([recordInfo.BLOCKPATH]', dateSel) & ismember([recordInfo.ID]', recID(rIndex)) & ~logical([1, recordInfo(2:end).sort]'));
    selData = recordInfo(selIdx);
    selInfo(rIndex).selIdx = selIdx;
    
   

    if isfield(selData, "datPath")
        DATAPATH = cellstr([selData.datPath]');
    end
    try
        BLOCKPATH = cellstr([selData.BLOCKPATH]');
    end
    MERGEPATH = strcat(TANKNAME, "Merge", num2str(rIndex));
    MERGEFILE = strcat(MERGEPATH, "\Wave.bin");
    