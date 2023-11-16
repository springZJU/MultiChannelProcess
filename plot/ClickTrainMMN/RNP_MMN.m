function RNP_MMN(MATPATH,FIGPATH)  % RNP_MMN FOR MMN protocol from zyy, update 23/11/14

%% Paramter setting
windowParams.stimuliDuration = 200; % ms
windowParams.ratio = [9 1]; % ms
windowParams.stimStr = ["REG4", "Ascend", "Descend", "J 0-10", "J 30-40", ...
    "J 50-60", "J 10-10", "J 30-30", "J 50-50", "J 70-70", ...
    "fuza600", "fuza680"];
windowParams.labelStr = ["0_250", "m15_0", "0_50", "50_200", "200_250"];
windowParams.winStr = ["frWin", "frWinBase", "frWinOnset", "frWinLate", "frWinOffset"];
windowParams.spkFrWin = {[0, 250], [-15, 0], [0, 50], [50, 200], [200, 250]}; % ms

windowParams.colors = generateColorGrad(7,'rgb','blue', 1:4,'red', [5 6],'black', 7);
windowParams.colorDec = {[0.5, 0.5, 0.5], [1, 0, 0], [0, 0, 1], [0, 0, 0]};

windowParams.spkWindow = [-50 250]; % ms
windowParams.spkPlotWindow = [-50 250]; % ms
windowParams.spkPsthBin = 5; % ms

windowParams.lfpWindow = [-50 2500]; % to add, ... later

windowParams.processFcn = @PassiveProcess_ClickTrainMMN;

%%
ResaveSpkmat = 1;
if ResaveSpkmat
    %% Load data
    [trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(MATPATH, windowParams);
    disp('Load data from MAT sucess.');
    windowParams.TypesStr = unique({trialAll.oddballType}');

    %% process lfp and save res.mat
    % chLfpRes = lfpProcessMMN(trialAll, lfpDataset, windowParams);  % mei xie!
    % SAVENAME = strcat(FIGPATH, "\lfpRes.mat");
    % save(SAVENAME, "chLfpRes", "trialAll", "-mat");

    %% process spk and save res.mat
    chSpkRes = spkProcessMMN(trialAll, spikeDataset, windowParams, ResaveSpkmat);
    if exist(FIGPATH, "dir")
        disp('The file already Exists.')
        disp('Resave spkRes.mat ...')
    else
        mkdir(FIGPATH);
        disp('Save spkRes.mat ...')
    end
    SAVENAME = strcat(FIGPATH, "\spkRes.mat");
    save(SAVENAME, "chSpkRes", "trialAll", "windowParams", "-mat");
    disp('Success.')
end

%% spk plot and save figure
load(strcat(FIGPATH, "\spkRes.mat"), 'chSpkRes');
dataOnly = 0;
ResaveSpkFigure = 1;
if ~dataOnly
    spkPlotMMN(FIGPATH, chSpkRes, windowParams, ResaveSpkFigure);
end

end

