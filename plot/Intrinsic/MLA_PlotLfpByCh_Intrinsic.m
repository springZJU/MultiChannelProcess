function Fig = MLA_PlotLfpByCh_Intrinsic(lfpRes, spkRes, CTLParams)   

CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
chNum = length(lfpRes(1).chLFP);

margins = [0.05, 0.05, 0.15, 0.15];
paddings = [0.01, 0.03, 0.03, 0.03];
Fig = figure;
maximizeFig(Fig);

sigRes = evalin("caller", "sigRes");
sigCH  = unique(mod(double(erase([sigRes([sigRes.H] == 1).CH], "CH")), 1000));

for dIndex = 1 : length(lfpRes)
    for cIndex = 1 : chNum
        %% ACG curve
        Axes = mSubplot(Fig, chNum,  3, cIndex*3-2, [1, 1], margins, paddings);
        t = lfpRes(dIndex).acgLFP(cIndex).lfpACG(:, 1);
        temp = lfpRes(dIndex).acgLFP(cIndex).lfpACG(:, 2);
        plot(Axes, t, temp, "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
        plot([0, lfpRes(dIndex).acgLFP(cIndex).acgLfpTime], [1/exp(1), 1/exp(1)], "k:"); hold on
        plot([1, 1] * lfpRes(dIndex).acgLFP(cIndex).acgLfpTime, [0, 1/exp(1)], "k:"); hold on
        xlim([t(1), t(end)]);
        if ismember(cIndex, sigCH)
            title(strcat("CH ", num2str(cIndex), ", Auditory Responsive channel, tau=",  num2str(lfpRes(dIndex).acgLFP(cIndex).acgLfpTime)));
        else
            title(strcat("CH ", num2str(cIndex), ", tau=",  num2str(lfpRes(dIndex).acgLFP(cIndex).acgLfpTime)));
        end 
        if cIndex < chNum
            set(gca, 'xticklabel', '');
        end
        if dIndex > 1
            set(gca, 'yticklabel', '');
        end

        %% tau tuning
        mSubplot(Fig, 1, 3, 2, [1, 1], [0.05, 0.05, 0.01, 0.01], paddings)
        acgLfpTime = [lfpRes(dIndex).acgLFP.acgLfpTime];
        plot([lfpRes(dIndex).acgLFP.acgLfpTime], 1:chNum, "r-"); hold on
        scatter([lfpRes(dIndex).acgLFP.acgLfpTime], 1:chNum, 40, "red"); hold on
        scatter([lfpRes(dIndex).acgLFP(sigCH).acgLfpTime], sigCH, 40, "red", "filled"); hold on
        yticks(1:chNum);
        ylim([0.5, chNum+0.5]);
        xlim([floor(min(acgLfpTime) / 10)*10, ceil(max(acgLfpTime) / 10)*10]);
        set(gca, "YDir", "reverse");
    end
        %% ACG curve
        
        mSubplot(Fig, 2, 3, 3, [1, 1], [0.05, 0.05, 0.01, 0.01], paddings)
        t    = spkRes(dIndex).ACGRes.spkACGMean(:, 1);
        temp = spkRes(dIndex).ACGRes.spkACGMean(:, 2);
        acgSpkTime = mean(spkRes(dIndex).ACGRes.acgSpkTime);
        set(groot, 'defaultAxesNextPlot', 'add');
        cellfun(@(x) plot(x(:, 1), x(:, 2), "Color", "#AAAAAA", "LineStyle", "-", "LineWidth", 0.5), spkRes.ACGRes.spkACG, "UniformOutput", false);
        set(groot, 'defaultAxesNextPlot', 'replace');
        plot([0;t], [1;temp], "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
        plot([0, acgSpkTime], [1/exp(1), 1/exp(1)], "k--"); hold on
        plot([1, 1] * acgSpkTime, [0, 1/exp(1)], "k--"); hold on
        xlim([0, t(end)]);
        ylim([0, 1]);
        title(strcat("tau=",  num2str(acgSpkTime)));
end

% add vertical line
lines(1).X = 0;
lines(1).color = "black";
addLines2Axes(Fig, lines);



