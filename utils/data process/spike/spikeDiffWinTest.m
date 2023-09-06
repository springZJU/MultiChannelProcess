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

[frRes.frMean_Resp, frRes.frSE_Resp, frRes.countRaw_Resp] = calFR(spike, win1, trials);
[frRes.frMean_Base, frRes.frSE_Base, frRes.countRaw_Base] = calFR(spike, win2, trials);
[H, frRes.P] = ttest(frRes.countRaw_Resp(:, 1), frRes.countRaw_Base(:, 1), "Tail", Tail, "Alpha", Alpha);
if isnan(H)
    H = 0;
end
frRes.H = H & frRes.frMean_Resp>1000/diff(win1);
% frRes.H = H & frRes.frMean_Resp>1000/diff(win1) & frRes.frMean_Resp > frRes.frMean_Base + 3*std(frRes.countRaw_Base(:, 1)*1000/diff(win1));

end