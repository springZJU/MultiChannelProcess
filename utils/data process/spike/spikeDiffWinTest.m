function frRes = spikeDiffWinTest(spike, win1, win2, trials, varargin)
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
mIp.addRequired("spike", @(x) isnumeric(x)&size(x, 2)==2);
mIp.addRequired("win1", @isnumeric);
mIp.addRequired("win2", @isnumeric);
mIp.addRequired("trials", @isnumeric);
mIp.addParameter("Tail", "both", @(x) any(validatestring(x, {'both', 'left', 'right'})));
mIp.addParameter("Alpha", 0.05, @isnumeric);

mIp.parse(spike, win1, win2, trials, varargin{:});
Tail = mIp.Results.Tail;
Alpha = mIp.Results.Alpha;

[frRes.frMean_0, frRes.frSE_0, frRes.countRaw_0] = calFR(spike, win1, trials);
[frRes.frMean_1, frRes.frSE_1, frRes.countRaw_1] = calFR(spike, win2, trials);
[H, frRes.P] = ttest(frRes.countRaw_0(:, 1), frRes.countRaw_1(:, 1), "Tail", Tail, "Alpha", Alpha);
if isnan(H)
    H = 0;
end
frRes.H = H & frRes.frMean_0>1000/diff(win1) & frRes.frMean_0 > frRes.frMean_1 + 3*std(frRes.countRaw_1(:, 1));
end