    parseStruct(selInfo, rIndex);
    MERGEPATH = strcat(TANKNAME, "Merge", num2str(selInfo(rIndex).ID));
    binFile = strcat(MERGEPATH, "\Wave.bin");

    %% kilosort
    run([fileparts(mfilename("fullpath")), '\config\configFileMulti.m']);
    switch chNum
        case 16
            % treated as linear probe if no chanMap file
            ops.chanMap = [fileparts(mfilename("fullpath")), '\config\chan16_1_kilosortChanMap.mat'];  %16*1 linear array
            % total number of channels in your recording
            ops.NchanTOT = 16; %16*1 linear array
            % sample rate, Hz
            ops.fs = 12207.03125;

        case 32
            % ops.chanMap = 'config\chan16_2_kilosortChanMap.mat'; %16*2 linear array
            ops.chanMap = [fileparts(mfilename("fullpath")), '\config\chan32_1_kilosortChanMap.mat']; %32*1 linear array
            ops.NchanTOT = 32; %16*2 / 32*1 linear array
            ops.fs = 12207.03125;
        case 385
            ops.chanMap = [fileparts(mfilename("fullpath")), '\config\neuropix385_kilosortChanMap.mat'];
            ops.NchanTOT = 385; %384 CHs + 1 sync
            ops.fs = 30000;
    end

    for tIndex = 1 : size(thr , 1)
        ops.Th = thr(tIndex, :);
        savePath = fullfile(MERGEPATH, ['th', num2str(ops.Th(1))  , '_', num2str(ops.Th(2))]);
        if ~exist(strcat(savePath, "\params.py"), "file")
            mKilosort(binFile, ops, savePath);
        end
    end

    for sIndex = 1 : length(selIdx)
        recordInfo(selIdx(sIndex)).sort = 1;
    end
    writetable(struct2table(recordInfo), recordPath);