function RLA_CSD(MATPATH, FIGPATH, badCH_File)
narginchk(2, 3);
if nargin < 3
    try
    badCH_File = evalin("base", "badCH_File");
    catch
    badCH_File = "nan";
    end
end

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

[badCh, dz] = badCH_Config(badCH_File, MATPATH);



% get lfp and wave data
[trialAll, LFPDataset] = CSD_Preprocess(MATPATH);
trialAll(1) = [];
[~, WAVEDataset] = MUA_Preprocess(MATPATH);
window = [-100 500];
selWin = [-20 , 150];
trialsLFP = selectEcog(LFPDataset, trialAll, "trial onset", window);
trialsWAVE = selectEcog(WAVEDataset, trialAll, "trial onset", window);
try
    chSel = evalin("base", "chSel");
    trialsLFP  = cellfun(@(x) x(chSel, :), trialsLFP, "UniformOutput", false);
    trialsWAVE = cellfun(@(x) x(chSel, :), trialsWAVE, "UniformOutput", false);
end

for mIndex = 1 : length(CSD_Methods)

    CSD_Method = CSD_Methods(mIndex);

    % diff banks
    bandIdx = {[1:2:size(trialsLFP{1}, 1)]; [2:2:size(trialsLFP{1}, 1)]};
    for bIndex = 1 : 2
    
    FIGNAME = strcat(FIGPATH, "\", CSD_Method, "_Bank", num2str(bIndex));
    if exist(strcat(FIGNAME, ".jpg"), "file")
        continue
    end

    tempLFP = cellfun(@(x) x(bandIdx{bIndex}, :), trialsLFP, "UniformOutput", false);
    tempWave = cellfun(@(x) x(bandIdx{bIndex}, :), trialsWAVE, "UniformOutput", false);
    tempBadCh = ceil(badCh(mod(badCh, 2) == 2-bIndex)/2);
    % compute CSD and MUA
    [CSD, LFP] = CSD_Process(tempLFP, window, CSD_Method, tempBadCh, dz);
    MUA = MUA_Process(tempWave, window, selWin, WAVEDataset.fs);

    % plot LFP_Wave, LFP_Image, CSD and MUA
    FigCSD = MLA_Plot_LFP_CSD_MUA(LFP, CSD, MUA, selWin);
    mkdir(FIGPATH);
    print(FigCSD, FIGNAME, "-djpeg", "-r300");
    
    end
    close all;
end

end