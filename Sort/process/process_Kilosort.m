parseStruct(selInfo, rIndex);
MERGEPATH = strcat(TANKNAME, "Merge", num2str(selInfo(rIndex).ID));
binFile = strcat(MERGEPATH, "\Wave.bin");
if all([recordInfo(selIdx).sort]') && ~getOr(customInfo, "reWhiten", false)
    return
end
%% kilosort
run([fileparts(mfilename("fullpath")), '\config\configFileMulti.m']);
switch chNum
    case 4
        % treated as linear probe if no chanMap file
        ops.chanMap             = [fileparts(mfilename("fullpath")), '\config\chan5_5_6_16_kilosortChanMap.mat'];  %16*1 linear array
        % total number of channels in your recording
        ops.NchanTOT            = 32; %5*5*6*16 linear array
        % sample rate, Hz
        ops.fs                  = fs;
        ops.nblocks             = 0;

    case 8
        % treated as linear probe if no chanMap file
        ops.chanMap             = [fileparts(mfilename("fullpath")), '\config\chan8_2_kilosortChanMap.mat'];  %16*1 linear array
        % total number of channels in your recording
        ops.NchanTOT            = 16; %8*2 linear array
        % sample rate, Hz
        ops.fs                  = fs;
        ops.nblocks             = 0;

    case 16
        % treated as linear probe if no chanMap file
        ops.chanMap             = [fileparts(mfilename("fullpath")), '\config\chan16_1_kilosortChanMap.mat'];  %16*1 linear array
        % total number of channels in your recording
        ops.NchanTOT            = 16; %16*1 linear array
        % sample rate, Hz
        ops.fs                  = fs;
        ops.nblocks             = 0;

    case 24
        % treated as linear probe if no chanMap file
        ops.chanMap             = [fileparts(mfilename("fullpath")), '\config\chan24_1_kilosortChanMap.mat'];  %24*1 linear array
        % total number of channels in your recording
        ops.NchanTOT            = 24; %24*1 linear array
        % sample rate, Hz
        ops.fs                  = fs;
        ops.nblocks             = 0;        

    case 24.32
        % treated as linear probe if no chanMap file
        ops.chanMap             = [fileparts(mfilename("fullpath")), '\config\chan24in32_1_kilosortChanMap.mat'];  %24*1 linear array
        % total number of channels in your recording
        ops.NchanTOT            = 32; %24*1 linear array
        % sample rate, Hz
        ops.fs                  = fs;
        ops.nblocks             = 0;  

    case 32
        ops.chanMap = 'config\chan16_2_kilosortChanMap.mat'; %16*2 linear array
        %             ops.chanMap = [fileparts(mfilename("fullpath")), '\config\chan32_1_kilosortChanMap.mat']; %32*1 linear array
        ops.NchanTOT = 32; %16*2 / 32*1 linear array
        ops.fs = fs;
        ops.nblocks = 0;
        
    case 31
        ops.chanMap = 'config\chan16_2_1_kilosortChanMap.mat'; %16*2 linear array
        %             ops.chanMap = [fileparts(mfilename("fullpath")), '\config\chan32_1_kilosortChanMap.mat']; %32*1 linear array
        ops.NchanTOT = 32; %16*2 / 32*1 linear array
        ops.fs = fs;
        ops.nblocks = 0;

    case 385
        ops.chanMap = [fileparts(mfilename("fullpath")), '\config\neuropixPhase3B1_kilosortChanMap.mat'];
        ops.NchanTOT = 385; %384 CHs + 1 sync
        ops.fs = fs;
        ops.nblocks = 5;
        ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
        ops.NT                  = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory).
        ops.whiteningRange      = 32; % number of channels to use for whitening each channel
    case 128
        ops.chanMap = [fileparts(mfilename("fullpath")), '\config\PKU128_kilosortChanMap.mat'];
        ops.NchanTOT = 128; 
        ops.fs = fs;
        ops.nblocks = 0;
        ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
        ops.NT                  = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory).
        ops.whiteningRange      = 16; % number of channels to use for whitening each channel
%         ops.spkTh               = -4;      % spike threshold in standard deviations (-6)
        ops.nfilt_factor        = 6; % max number of clusters per good channel (even temporary ones)
        ops.nPCs                = 5; % how many PCs to project the spikes into


        %         case newCH
        %             ops.chanMap = [];
        %             ops.NchanTOT = []; %384 CHs + 1 sync
        %             ops.fs = [];
end

for tIndex = 1 : size(thr , 1)
    ops.Th = thr(tIndex, :);
    savePath = fullfile(MERGEPATH, ['th', num2str(ops.Th(1))  , '_', num2str(ops.Th(2))]);


    %% this block runs all the steps of the algorithm
    if getOr(customInfo, "reWhiten", false) && all([recordInfo(selIdx).sort]')
        if ~exist(fullfile(fileparts(binFile), 'temp_wh.dat'), "file")
            ops.fproc = fullfile(fileparts(binFile), 'temp_wh.dat'); % proc file on a fast SSD
            ops.fbinary = binFile;
            rez =  preprocessDataSub(ops);
            save(fullfile(fileparts(binFile), 'wh_rez.mat'), "rez");
        end
    else
        mKilosort(binFile, ops, savePath);
    end
end

for sIndex = 1 : length(selIdx)
    recordInfo(selIdx(sIndex)).sort = 1;
end
writetable(struct2table(recordInfo), recordPath);



