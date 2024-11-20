%% NoiseAdaptation
clear;clc;
set(0, 'DefaultFigureWindowState', 'maximized');

MATPATH = 'O:\MonkeyLA\MAT DATA\CM\CTL_New';
fileNames = dir(fullfile(MATPATH, 'Noise-ITI-0.25s'));
DateAndPos = {fileNames(3:end).name}';

FIGPATH = 'O:\Project\ANALYSIS_202312_MonkeyLA_MSTIReg\Figure\NoiseAdapatation';
TrialTypes = ["Noise-ITI-2s", "Noise-ITI-1s", "Noise-ITI-0.5s", "Noise-ITI-0.25s"];

%% 
plotWin = {[-100, 150], [-100, 150], [-100, 150], [-100, 150]};
baseWin = [-50, 0];
respWin = [0, 50];
psthPara.binsize = 3;
psthPara.binstep = 0.3;

%% plot setting
rowNum = 2; % row1:raster; row2:PSTH;
colNum = numel(TrialTypes) + 1;

%%
for dateIdx = 1 : numel(DateAndPos)
    SAVEPath = fullfile(FIGPATH, DateAndPos{dateIdx});
    mkdir(SAVEPath);
    % process
    spkRes = []; CHspkRes = []; Res = [];
    for ITITypeIdx = 1 : numel(TrialTypes)
        Res(ITITypeIdx).NoiseITI = TrialTypes(ITITypeIdx);
        [Res(ITITypeIdx).spkRes, Res(ITITypeIdx).sigRes] = MLA_NoiseAdaptation(fullfile(MATPATH, TrialTypes(ITITypeIdx), DateAndPos{dateIdx}, 'data.mat'), ...
                                                          baseWin, respWin, "plotWin", plotWin{ITITypeIdx});    
    end

    i = 0; prev = []; next = []; CompRes = [];
    while i < numel(Res) - 1
        i = i + 1;
        prev = [Res(i).sigRes.CH]';
        next = [Res(i + 1).sigRes.CH]';
        CompRes = intersect(prev, next, "rows", "stable");
    end
    for typeIdx = 1 : numel(Res)
        Res(typeIdx).spkRes(~ismember([Res(typeIdx).sigRes.CH]', CompRes)) = [];
        Res(typeIdx).sigRes(~ismember([Res(typeIdx).sigRes.CH]', CompRes)) = [];        
    end
    spkRes = cellfun(@(CH) ...
                cellfun(@(Dev) ...
                        cell2mat(cellfun(@(x) cell2mat(x), {Res(Dev).spkRes(CH).noiseSpike}', "UniformOutput", false)'), ...
                    num2cell(1 : numel(Res))', "UniformOutput", false), ...
                num2cell(1 : numel(Res(1).spkRes)), "UniformOutput", false)';

    % for empty raster
    for cIdx = 1 : numel(spkRes)
        spkRes{cIdx, 1}(cellfun(@(x) isempty(x), spkRes{cIdx})) = {[-100000, -1]};
    end
        
    CHspkRes = cell2struct([cellstr({Res(1).sigRes.CH}'), ...
                 cellfun(@(CH) cell2struct([cellstr([Res.NoiseITI]') ,...
                                            spkRes{CH}, ...
                                            cellfun(@(spkData, Dev) calFr(spkData, respWin, "trials", unique(spkData(:, 2))), spkRes{CH}, num2cell(1 : numel(Res))', "UniformOutput", false), ...
                                            cellfun(@(spkData, Dev) calPsth(spkData, psthPara, 'scaleFactor', 1e3, 'EDGE', plotWin{Dev}), ...
                                                    spkRes{CH}, num2cell(1 : numel(plotWin))', "UniformOutput", false), ...
                                            cellfun(@(Dev) Res(Dev).sigRes(CH), num2cell(1 : numel(Res))', "UniformOutput", false)], ...
                                            ["stimStr", "Raster", "NoiseFr", "PSTH", "sigtest"], 2), ...
                 num2cell(1 : numel(Res(1).spkRes)), "UniformOutput", false)'],...
                ["CH", "spkRes"], 2);

    % plot
    for cIdx = 1 : numel(CHspkRes)
        spkTemp = CHspkRes(cIdx).spkRes;
        figure;
        for ITITypeIdx = 1 : numel(spkTemp)
            sitmStr = string(spkTemp(ITITypeIdx).stimStr);
            % raster
            mSubplot(rowNum, colNum, ITITypeIdx);
            plot(spkTemp(ITITypeIdx).Raster(:, 1), spkTemp(ITITypeIdx).Raster(:, 2), 'r.', 'MarkerSize', 10);
            xlim(plotWin{ITITypeIdx});
            if ITITypeIdx == 1; ylabel("Trials"); end
            xlabel("Time(ms)");
            title(sitmStr);
            % PSTH
            PSTHAxes(ITITypeIdx) = mSubplot(rowNum, colNum, colNum + ITITypeIdx);
            plot(spkTemp(ITITypeIdx).PSTH(:, 1), spkTemp(ITITypeIdx).PSTH(:, 2));
            xlim(plotWin{ITITypeIdx}); 
            if ITITypeIdx == 1; ylabel("Firing rate(Hz)"); end
            xlabel("Time(ms)");            
        end
        mSubplot(rowNum, colNum, colNum);
        sigIdx = find(cellfun(@(x) x.H == 1, {spkTemp.sigtest}'));
        plot(1 : numel(spkTemp), [spkTemp.NoiseFr], 'b--o');hold on;
        if ~isempty(sigIdx)
            scatter(sigIdx, [spkTemp(sigIdx).NoiseFr], 20, 'blue', 'filled');hold on;
        end
        xticklabels(TrialTypes);

        % scaleAx
        scaleAxes(PSTHAxes(:), "y", "on");

        % print
        print(gcf, fullfile(SAVEPath, strcat(CHspkRes(cIdx).CH, ".jpg")), '-djpeg', '-r300');
        close;
    end
    %% save
    save(fullfile(SAVEPath, "CHspkRes.mat"), "CHspkRes", "-mat");
end

