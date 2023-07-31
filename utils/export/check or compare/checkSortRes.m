data = TDTbin2mat('F:\spr\TBOffsetRat1_SPR\rat1_20230216\Block-3');
sortdata = data.sortdata;
chs = unique(sortdata(:, 2));
window = [data.epocs.Swep.onset(1:end), data.epocs.Swep.offset(1:end)];
plotBuffer = [];
ch = 3;
temp = sortdata(sortdata(:, 2) == chs(ch), :);
for tIndex = 1 : size(window, 1)
    buffer = findWithinInterval(temp(:, 1), window(tIndex, :))-window(tIndex, 1);
    buffer(:, 2) = ones(length(buffer),1)*tIndex;
    plotBuffer = [plotBuffer; buffer];
end

scatter(plotBuffer(:, 1), plotBuffer(:, 2), 10, "black", "filled");
xlim([0, 0.1])


