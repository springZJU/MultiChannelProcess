function [frMean, frSE, countRaw, frSD, trials] = calFR(spikes, window, trials)
if ~iscolumn(trials)
    trials = trials';
end
trialN = length(trials);
spikes(~(spikes(:,1) >= window(1) & spikes(:,1) <= window(2)),:) = [];
if size(spikes, 2) == 1
    temp = tabulate(spikes(:, 1));
elseif size(spikes, 2) == 2
    temp = tabulate(spikes(:, 2));
end

if ~isempty(spikes)
    temp(temp(:, 2)==0,:) = [];
    countRaw = sortrows([[temp(:, 2); zeros(trialN-size(temp,1), 1)], [temp(:,1); trials(~ismember(trials, temp(:,1)))]], 2);
%     trials = countRaw(:, 2);
%     countRaw = countRaw(:, 1);
    frMean = mean(countRaw(:, 1))*1000 / diff(window);
    frSE = std(countRaw(:, 1))*1000 / (diff(window)*sqrt(trialN));
    frSD = std(countRaw(:, 1))*1000 / diff(window);
else
    countRaw = [zeros(trialN, 1), trials] ;
    frMean = 0;
    frSE = 0;
    frSD = 0;
end

end
