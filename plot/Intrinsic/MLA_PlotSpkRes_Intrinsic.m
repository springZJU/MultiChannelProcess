function Fig = MLA_PlotSpkRes_Intrinsic(spkRes, CTLParams)   

parseStruct(CTLParams);
CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end

margins = [0.05, 0.05, 0.15, 0.15];
paddings = [0.01, 0.03, 0.03, 0.03];
Fig = figure;
maximizeFig(Fig);

for dIndex = 1 : length(spkRes)

        %% ACG curve
        Axes = mSubplot(Fig, 1,  1, 1, [1, 1], margins, paddings);
        t    = spkRes(dIndex).ACGRes.spkACGMean(:, 1);
        temp = spkRes(dIndex).ACGRes.spkACGMean(:, 2);
        acgSpkTime = mean(spkRes(dIndex).ACGRes.acgSpkTime);
        plot(Axes, [0;t], [1;temp], "Color", "red", "LineStyle", "-", "LineWidth", 1.5); hold on;
        plot([0, acgSpkTime], [1/exp(1), 1/exp(1)], "k--"); hold on
        plot([1, 1] * acgSpkTime, [0, 1/exp(1)], "k--"); hold on
        xlim([0, t(end)]);
        title(strcat("tau=",  num2str(acgSpkTime)));
end

% add vertical line
lines(1).X = 0;
lines(1).color = "black";
addLines2Axes(Fig, lines);



