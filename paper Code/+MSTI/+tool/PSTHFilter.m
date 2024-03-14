function [PSTHDataset, PSTHData] = PSTHFilter(PSTHDataset, bsfreq)
    narginchk(1, 2);
    ft_setPath2Top;

    fs0 = PSTHDataset.fs;
    channels = PSTHDataset.channels;

    cfg = [];
    cfg.trials = true;
    data.trial = PSTHDataset.data;
    data.time = (0:(size(PSTHDataset.data, 2) - 1)) / fs0;
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs0;
    data.trialinfo = 1;
    data.sampleinfo = [1, size(PSTHDataset.data, 2)];
    data = ft_selectdata(cfg, data);

    % Filter
    disp("Filtering...");
    cfg = [];
    cfg.demean = 'no';
    cfg.bsfilter = 'yes';
    cfg.bsfreq = bsfreq;
    cfg.hpfiltord = 3;
    cfg.dftfilter = 'no';
    cfg.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
    data = ft_preprocessing(cfg, data);

    PSTHDataset.data = data.avg;
    PSTHData = data.avg;
    return;
end