clearvars -except selInfo  NPYPATH nIndex customInfo
parseStruct(customInfo);
temp = strsplit(NPYPATH(nIndex), "\");
MERGEPATH = strjoin(temp(1:end-2), "\");
load(fullfile(MERGEPATH,'mergePara.mat'));
parseStruct(selInfo);
npypath = char(NPYPATH(nIndex));

try
    BLOCKPATH = BLOCKPATHTEMP;
catch
    BLOCKPATHTEMP = BLOCKPATH;
end
temp = char(selInfo(nIndex).TANKNAME);
BLOCKPATH = cellstr(strrep(BLOCKPATH, BLOCKPATH{1}(1:3), temp(1:3)));

if all(cellfun(@(x) exist([x '\sortdata.mat'], "file"), BLOCKPATH)) 
    return
end

%% cluster_info.tsv, for preview and selection
run("process_PostMerge.m");
clusterIdx = idCh(:, 1);
chIdx = idCh(:, 2)+1;

%% split sort data into different blocks
kiloSpikeAll = cellfun(@(x) [spikeTime(clusterAll == x), chIdx(clusterIdx == x)*ones(sum(clusterAll == x), 1)], num2cell(clusterIdx), "UniformOutput", false);
save([npypath, '\selectCh.mat'], 'chIdx', 'clusterIdx', '-mat');

if exist("waveLength", "var")
    segPoint = [0, cumsum(cell2mat(cellfun(@(x) sum(x), waveLength, "UniformOutput", false)))];
end

%% load excel
[~, opts] = getTableValType(recordPath, "0");
recordInfo = table2cell(readtable(recordPath, opts));
recordInfo(1, cell2mat(cellfun(@(x) isequaln(x, NaN), recordInfo(1, :), "uni", false))) = {["double"]};
recordInfo = cell2struct(recordInfo, opts.SelectedVariableNames, 2);
idSel = ismember([recordInfo.ID]', customInfo.idSel) & contains(string({recordInfo.BLOCKPATH}'), BLOCKPATH);
recordInfo = recordInfo(idSel);

%%
for blks = 1:length(BLOCKPATH)
    clear sortdata
    if exist([BLOCKPATH{blks} '\sortdata.mat'], "file") && ~reExportSpk 
        continue
    end

    if blks == length(BLOCKPATH)
        t = [segPoint(blks), inf] - segPoint(1);
    else
        t = [segPoint(blks), segPoint(blks + 1)] - segPoint(1);
    end

    sortdataBuffer = cell2mat(kiloSpikeAll);
    if isempty(sortdataBuffer)
        sortdata = [];
    else
        [~,selectIdx] = findWithinInterval(sortdataBuffer(:,1), t);
        sortdata = sortdataBuffer(selectIdx,:);
        sortdata(:,1) = sortdata(:,1) - t(1);
    end

    save([BLOCKPATH{blks} '\sortdata.mat'], 'sortdata', '-v7.3');

    %% export waveform
    if exportSpkWave
        blkTemp = BLOCKPATH{blks};
        temp = strsplit(BLOCKPATH{blks}, "\");
        animalID = temp{end - 2};
        dateStr = temp{end - 1};
        paradigm = recordInfo(matches(string({recordInfo.BLOCKPATH}'), BLOCKPATH{blks})).paradigm;
        sitePos = recordInfo(matches(string({recordInfo.BLOCKPATH}'), BLOCKPATH{blks})).sitePos;
        SAVEPATH = strcat(MATPATH, animalID, "\CTL_New\", paradigm, "\", dateStr, "_", sitePos);
        mkdir(SAVEPATH);
        if ~exist(fullfile(SAVEPATH, "spkWave.mat"), "file")
            sampleRange = fix(t * fs(nIndex));
            wfWin = [-30, 60]; % ms
            IDandCHANNEL = [clusterIdx, zeros(length(clusterIdx), 1), chIdx];
            disp(strcat("Processing blocks (", num2str(blks), "/", num2str(length(BLOCKPATH)), ") ..."));
            spkWave = getWaveForm_singleID_v2(fs(nIndex), BLOCKPATH{blks}, npypath, clusterIdx, IDandCHANNEL, wfWin, sampleRange);
            save(fullfile(SAVEPATH, "spkWave.mat"), "spkWave", "-v7.3");
        end
    end

end




