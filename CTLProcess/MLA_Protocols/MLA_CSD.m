function MLA_CSD(MATPATH, FIGPATH)

% csd paramters config
temp = fullfile(MATPATH, "temp");
temp = string(strsplit(temp, "\"));
if contains(MATPATH, "Block")
    dateStr = fullfile(temp(end - 3), temp(end - 2), temp(end -1));
else
    dateStr = fullfile(temp(end - 2), temp(end - 1));
end




CSD_Methods = ["three point", "five point", "kCSD"];
if all(cell2mat(cellfun(@(x) exist(strcat(FIGPATH, dateStr, "\", x, '.jpg'), "file"), CSD_Methods, "uni", false)))
    return
end
try
    badCh = evalin("base", "badCh");
    dz = evalin("base", "dz");
catch
    [badCh, dz] = MLA_CSD_Config(MATPATH);
end


% get lfp and wave data
[trialAll, LFPDataset] = CSD_Preprocess(MATPATH);
trialAll(1) = [];
[~, WAVEDataset] = MUA_Preprocess(MATPATH);
window = [-100 500];
selWin = [-20 , 150];
trialsLFP = selectEcog(LFPDataset, trialAll, "trial onset", window);
trialsWAVE = selectEcog(WAVEDataset, trialAll, "trial onset", window);


for mIndex = 1 : length(CSD_Methods)

    CSD_Method = CSD_Methods(mIndex);
    FIGNAME = strcat(FIGPATH, dateStr, "\", CSD_Method);
    if exist(strcat(FIGNAME, ".jpg"), "file")
        continue
    end
    mkdir(strcat(FIGPATH, dateStr));

    % compute CSD and MUA
    [CSD, LFP] = CSD_Process(trialsLFP, window, CSD_Method, badCh, dz);
    MUA = MUA_Process(trialsWAVE, window, selWin, WAVEDataset.fs);

    % plot LFP_Wave, LFP_Image, CSD and MUA
    FigCSD = MLA_Plot_LFP_CSD_MUA(LFP, CSD, MUA, selWin);
    print(FigCSD, FIGNAME, "-djpeg", "-r300");

%     close all;
end
save(fullfile(FIGPATH, dateStr, "MUARes.mat"), "MUA", "trialsWAVE", "-mat");

spikeRes = sNoise_RNP(MATPATH, strcat(FIGPATH, dateStr));
save(fullfile(FIGPATH, dateStr, "spikeRes.mat"), "spikeRes", "-mat");

end