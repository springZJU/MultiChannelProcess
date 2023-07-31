function MLA_CSD(MATPATH, FIGPATH)

% csd paramters config
temp = string(strsplit(MATPATH, "\"));
if contains(MATPATH, "Block")
    dateStr = temp(end - 2);
else
    dateStr = temp(end - 1);
end




CSD_Methods = ["three point", "five point", "kCSD"];
if all(cellfun(@(x) exist(strcat(FIGPATH, dateStr, "\", x, '.jpg'), "file"), CSD_Methods, "uni", false))
    return
end
[badCh, dz] = MLA_CSD_Config(MATPATH);

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

    close all;
end

end