function Fig = MLA_PlotLfpByCh_Intrinsic_4Shanks(lfpRes, spkRes, CTLParams)

CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
chNum = length(lfpRes(1).chLFP);

margins = [0.05, 0.05, 0.15, 0.15];
paddings = [0.01, 0.03, 0.03, 0.03];
Fig = figure;
maximizeFig(Fig);
shankN = 4;
sigRes = evalin("caller", "sigRes");
if any([sigRes.H] == 1)
%     if max(unique(mod(double(erase([sigRes([sigRes.H] == 1).CH], "CH")), 1000))) == length(lfpRes(1).acgLFP)
        sigCH  = unique(mod(double(erase([sigRes([sigRes.H] == 1).CH], "CH")), 1000));
%     else
%         sigCH  = unique(mod(double(erase([sigRes([sigRes.H] == 1).CH], "CH")), 1000))+1;
%     end
else
    sigCH = [];
end
if max(sigCH) > 192
sigCH(sigCH > 192) = sigCH(sigCH > 192)+1;
end
shankCH = {3:shankN:chNum; 1:shankN:chNum; 4:shankN:chNum; 2:shankN:chNum};
for sIndex = 1 : length(shankCH)
    for dIndex = 1 : length(lfpRes)
        %% tau tuning
        mSubplot(Fig, 1, shankN, sIndex, [1, 1], [0.05, 0.05, 0.01, 0.01], paddings)
        acgLfpTime = [lfpRes(dIndex).acgLFP(shankCH{sIndex}).acgLfpTime];
        plot(acgLfpTime, ceil(shankCH{sIndex}/shankN), "r-"); hold on
        scatter(acgLfpTime, ceil(shankCH{sIndex}/shankN), 40, "red"); hold on
        scatter(acgLfpTime(ismember(shankCH{sIndex}, sigCH)), ceil(sigCH(ismember(sigCH, shankCH{sIndex}))/shankN), 40, "red", "filled"); hold on
        yticks(1:chNum/shankN);
        yticklabels(string(shankCH{sIndex}));
        ylim([0.5, chNum/shankN+0.5]);
        xlim([floor(min(acgLfpTime) / 10)*10, ceil(max(acgLfpTime) / 10)*10]);
        set(gca, "YDir", "reverse");

    end
end






