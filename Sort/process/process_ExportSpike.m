clearvars -except selInfo  NPYPATH nIndex customInfo
parseStruct(customInfo);
temp = strsplit(NPYPATH(nIndex), "\");
MERGEPATH = strjoin(temp(1:end-2), "\");
load(fullfile(MERGEPATH,'mergePara.mat'));
fs = selInfo(nIndex).fs;
npypath = char(NPYPATH(nIndex));
[spikeIdx, clusterIdx, templates, spikeTemplateIdx] = parseNPY(npypath);

%% cluster_info.tsv, for preview and selection
IDs = tabulate(clusterIdx);
idToDel = IDs(IDs(:, 2) < 1000, 1);
run("alignIdCh.m");
idx = idCh(:, 1);
ch = idCh(:, 2);

%% split sort data into different blocks

%%
kiloSpikeAll = cellfun(@(x) [double(spikeIdx(clusterIdx == x))/fs, ch(idx == x)*ones(sum(clusterIdx == x), 1)], num2cell(idx), "UniformOutput", false);
save([npypath, '\selectCh.mat'], 'ch', 'idx', '-mat');

if ~exist("BLOCKPATH", "var")
    BLOCKPATH = BLOCKPATHTEMP;
end
if exist("waveLength", "var")
    segPoint = cumsum(cell2mat(cellfun(@(x) sum(x), waveLength, "UniformOutput", false)));
end

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
    [~,selectIdx] = findWithinInterval(sortdataBuffer(:,1), t);
    sortdata = sortdataBuffer(selectIdx,:);
    sortdata(:,1) = sortdata(:,1) - t(1);

    %% export waveform
    if exportSpkWave
        onsetIdx = ceil(t(1) * fs);
        wfWin = [-30, 30];
        IDandCHANNEL = [idx, zeros(length(idx), 1), ch];
        disp(strcat("Processing blocks (", num2str(blks), "/", num2str(length(BLOCKPATH)), ") ..."));
        spkWave = getWaveForm_singleID_v2(fs, BLOCKPATH{blks}, npypath, idx, IDandCHANNEL, wfWin, onsetIdx);
    end

        %%
        if exist("spkWave", "var")
            save([BLOCKPATH{blks} '\sortdata.mat'], 'sortdata', 'spkWave', '-v7.3');
        else
            save([BLOCKPATH{blks} '\sortdata.mat'], 'sortdata', '-v7.3');
        end

end



