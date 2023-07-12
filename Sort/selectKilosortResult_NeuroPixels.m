clear; clc
cd(fileparts(mfilename("fullpath")));

%%
for mIndex = 1
    clearvars -except mIndex
    MERGEPATH = strcat("I:\neuroPixels\TDTTank\Rat2_SPR\Rat2SPR20230708\Merge", num2str(mIndex));
    load(fullfile(MERGEPATH,'mergePara.mat'));
    chAll = 384;
    fs = 30000;

    NPYPATH = char(fullfile(MERGEPATH, "th9_7")); % the path including ks_result
    % ch =  [0 1 4 7 8 1008 9 10 12 13 14 16 17 20 21 23 24 25 26 27 28 29 30]; % channels index of kilosort, that means chKs = chTDT - 1;
    % idx = [25 24 23 22 19 20 18 21 16 17 15 13 14 12 11 9 8 7 10 6  3 2 0]; % the corresponding id
    % kiloSpikeAll = cell(max([chAll ch]),1);

    [spikeIdx, clusterIdx, templates, spikeTemplateIdx] = parseNPY(NPYPATH);
    IDs = tabulate(clusterIdx);
    idToDel = IDs(IDs(:, 2) < 1000, 1);
    run("alignIdCh.m");
    
    idx = idCh(:, 1);
    ch = idCh(:, 2);
    temp = [clusterIdx, spikeIdx];
    kiloSpikeAll = cellfun(@(x) [double(spikeIdx(clusterIdx == x))/fs, ch(idx == x)*ones(sum(clusterIdx == x), 1)], num2cell(idx), "UniformOutput", false);
    

    
    save([NPYPATH, '\selectCh.mat'], 'ch', 'idx', '-mat');

    %% split sort data into different blocks
    if ~exist("BLOCKPATH", "var")
        BLOCKPATH = BLOCKPATHTEMP;
    end
    for blks = 1:length(BLOCKPATH)
        clear sortdata;
        if blks == length(BLOCKPATH)
            t = [segPoint(blks), inf] - segPoint(1);
        else
            t = [segPoint(blks), segPoint(blks + 1)] - segPoint(1);
        end

        sortdataBuffer = cell2mat(kiloSpikeAll);
        [~,selectIdx] = findWithinInterval(sortdataBuffer(:,1),t);
        sortdata = sortdataBuffer(selectIdx,:);
        sortdata(:,1) = sortdata(:,1) - t(1);

        onsetIdx = ceil(t(1) * fs);
        wfWin = [-30, 30];
        IDandCHANNEL = [idx, zeros(length(idx), 1), ch];
        disp(strcat("Processing blocks (", num2str(blks), "/", num2str(length(BLOCKPATH)), ") ..."));
        % spkWave = getWaveForm_singleID_v2(fs, BLOCKPATH{blks}, NPYPATH, idx, IDandCHANNEL, wfWin, onsetIdx);
        % save([BLOCKPATH{blks} '\sortdata.mat'], 'sortdata', 'spkWave');
        save([BLOCKPATH{blks} '\sortdata.mat'], 'sortdata', '-v7.3');
    end
end

% %% update recording excel
% [mPath,mName]=fileparts(mfilename('fullpath'));
% cd(mPath);
% if contains(TANKPATH, "dxy", "IgnoreCase", true)
%     recordPath = "..\utils\RatSiliconRecording\DXY_RLA_TBOffset_Recording.xlsx";
% elseif contains(TANKPATH, "zyy", "IgnoreCase", true)
%     recordPath = "..\utils\RatSiliconRecording\ZYY_RLA_TBOffset_Recording.xlsx";
% elseif contains(TANKPATH, "spr", "IgnoreCase", true)
%     recordPath = "..\utils\RatSiliconRecording\SPR_RLA_TBOffset_Recording.xlsx";
% end
% recordInfo = table2struct(readtable(recordPath));
% changeIdx = find(matches({recordInfo.BLOCKPATH}', BLOCKPATH'));
% for i = changeIdx'
%     recordInfo(i).sort = 1;
%     recordInfo(i).ks_ChSel = strjoin(string(ch), ",");
%     recordInfo(i).ks_ID = strjoin(string(idx), ",");
% end
% writetable(struct2table(recordInfo), recordPath);



function [resVal,idx] = findWithinInterval(value,range)
idx = find(value>range(1) & value<range(2));
resVal = value(idx);
end
