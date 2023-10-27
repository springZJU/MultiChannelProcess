function [RS, vs] = RayleighStatistic(spikes,T,trialNum)
if ~isnan(spikes)
    piBuffer = 2*pi*spikes/T;
    n = length(spikes);
    vs = 1/n*sqrt((sum(cos(piBuffer)))^2 + (sum(sin(piBuffer)))^2);
    RS = 2*n*vs^2/trialNum;
else
    vs = 0;
    RS = 0;
end
end