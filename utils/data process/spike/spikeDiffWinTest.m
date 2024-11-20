function frRes = spikeDiffWinTest(spike, winResp, winBase, varargin)
% Description: test if firing rate of two windows are significantly different
% Input:
%     trialData: 2-D numeric vector, column1:time; column2:trial number
%     win1: the first window
%     win2: the second window
%     tail: do one-tailed(left/right) or two-tailed test 
%     alpha: significance level

% Output:
%     h: Testing decision of null hypothesis
%     p: p value

mIp = inputParser;
mIp.addRequired("spike", @(x) isnumeric(x)&size(x, 2)==2 | iscell(x));
mIp.addRequired("winResp", @isnumeric);
mIp.addRequired("winBase", @isnumeric);
mIp.addOptional("trials", [], @isnumeric);
mIp.addParameter("Tail", "both", @(x) any(validatestring(x, {'both', 'left', 'right'})));
mIp.addParameter("Alpha", 0.05, @isnumeric);
mIp.addParameter("absThr", 10, @isnumeric);
mIp.addParameter("sdThr", 1, @isnumeric);

mIp.parse(spike, winResp, winBase, varargin{:});
trials = mIp.Results.trials;
Tail = mIp.Results.Tail;
Alpha = mIp.Results.Alpha;
absThr = mIp.Results.absThr;
sdThr = mIp.Results.sdThr;

if isnumeric(spike)
    if isempty(trials)
        error("Please supply trial info !");
    elseif ~iscolumn(trials)
        trials = trials';
    end
    spikesTemp = findWithinInterval(spikes, window, 1);
    spikeCell = rowFcn(@(x) spikesTemp(spikesTemp(:, 2) == x), trials, "UniformOutput", false);
elseif iscell(spike)
    spikeCell = spike;
end
[frRes.frMean_Resp, frRes.frSE_Resp, frRes.countRaw_Resp] = calFr(spikeCell, winResp);
[frRes.frMean_Base, frRes.frSE_Base, frRes.countRaw_Base] = calFr(spikeCell, winBase);
[H, frRes.P] = ttest2(frRes.countRaw_Resp(:, 1), frRes.countRaw_Base(:, 1), "Tail", Tail, "Alpha", Alpha);
if isnan(H)
    H = 0;
end 
frRes.H = H & frRes.frMean_Resp > absThr;
% frRes.H = H & frRes.frMean_Resp > absThr & frRes.frMean_Resp > frRes.frMean_Base + sdThr * std(frRes.countRaw_Base(:, 1)*1000/diff(win1));

end