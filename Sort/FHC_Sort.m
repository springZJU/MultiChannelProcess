ccc


idSel = 4;

run('D:\Lab members\Public\code\MATLAB Utils - integrated\initMATLABUtils.m');
xlsxPath = 'D:\Lab members\Public\code\MultiChannelProcess\utils\recordingExcel\SPR\SPR_MouseLA_Recording_202509.xlsx';
opts = detectImportOptions(xlsxPath);
opts = setvartype(opts, 'string');
configTable = table2struct(readtable(xlsxPath, opts));
BLOCKPATHs = [configTable.BLOCKPATH]';
sitePoses  = [configTable.sitePos]';
paradigm   = [configTable.paradigm]';
ch         = 14;
for sIndex = idSel
    index    = find(matches([configTable.ID]', string(sIndex)));
    blocks   = BLOCKPATHs(index);
    sites    = sitePoses(index);
    protStrs = paradigm(index);
    for rIndex = 1 : length(index)
        DATAPATH = char(blocks(rIndex));
        SAVEPATH = [mu.getrootpath(DATAPATH, 3), '\MAT Data\TDT\CTL_New\'];
        sitePos  = char(sites(rIndex));
        protName = char(protStrs(rIndex));
        data  = TDTbin2mat(DATAPATH);
        dataCopy = data;
        dateStr  = erase(char(regexp(DATAPATH, 'TDT\\.*\\','match')), 'TDT');
        dateStr(end) = '_';
        clear data

        % spkData
        if matches(protName, 'Noise')
            sortData = mysort(dataCopy, ch, "reselect", "preview");
            refData  = sortData;
        else
            sortData = templateMatching(dataCopy, refData, ch);
        end
        data.epocs    = dataCopy.epocs;
        data.sortdata = [sortData.spikeTimeAll(logical(sortData.clusterIdx)), sortData.clusterIdx(logical(sortData.clusterIdx))];
        mkdir([SAVEPATH, protName, dateStr, sitePos])
        save([SAVEPATH, protName, dateStr, sitePos, '\spkData.mat'], "data");

        % lfpData
        data = rmfield(data, "sortdata");
        temp    = fields(dataCopy.streams);
        lfpName = temp(matches(temp, ["Llfp", "Lfpr"]));
        data.lfp = dataCopy.streams.(string(lfpName));

        save([SAVEPATH, protName, dateStr, sitePos, '\lfpData.mat'], "data");
    end
    clear sortData
end

