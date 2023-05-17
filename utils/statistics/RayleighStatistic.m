function [RS, vs] = RayleighStatistic(spikes,T)
    piBuffer = 2*pi*spikes/T;
    n = length(spikes);
    vs = 1/n*sqrt((sum(cos(piBuffer)))^2 + (sum(sin(piBuffer)))^2);
    RS = 2*n*vs^2;
end