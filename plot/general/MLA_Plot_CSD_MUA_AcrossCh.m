function Fig = MLA_Plot_CSD_MUA_AcrossCh(chAll, CTLParams)
CTLFields = string(fields(CTLParams));
for fIndex = 1 : length(CTLFields)
    eval(strcat(CTLFields(fIndex), "= CTLParams.", CTLFields(fIndex), ";"));
end
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.05];
%%
Fig = figure;
maximizeFig(Fig);
plotRows = 2;

for dIndex = 1 : length(chAll)
    CSD = chAll(dIndex).chCSD;
    MUA = chAll(dIndex).chMUA;
   

        %% plot CSD and corresponding MUA wave
         AxesCSD(dIndex) = mSubplot(Fig, plotRows,  ceil(length(chAll)/plotRows)*2, 2*dIndex-1, [1, 1], margins, paddings);
        box(AxesCSD(dIndex), "off");

        CData = flipud(CSD.Data);
        imagesc('XData', CSD.t, 'CData', CData); hold on
        colormap(AxesCSD(dIndex), "jet");
        ylim([1, size(CSD.Data, 1)]);
        xlim(selWin);
        cRange = scaleAxes(AxesCSD(dIndex), "c");
        scaleAxes(AxesCSD(dIndex), "c", [-max(abs(cRange)), max(max(cRange))]);
        csdYTick = linspace(1, size(CSD.Data, 1), length(CSD.Chs));
        set(AxesCSD(dIndex), "ytick", csdYTick);
        set(AxesCSD(dIndex), "yticklabel", string(num2cell(flip(CSD.Chs))'));
        colorbar

        % plot MUA Wave
        tIndex = MUA.tWave >= selWin(1) & MUA.tWave <= selWin(2);
        waveTemp = MUA.Wave(CSD.Boundary+1 : end-CSD.Boundary, tIndex);
        scaleFactor = 0.8* unique(diff(csdYTick)) / max(max(waveTemp, [], 2) - min(waveTemp, [], 2));
        waveTemp = scaleFactor * waveTemp;
        waveTemp = waveTemp - repmat(min(waveTemp ,[], 2), 1, size(waveTemp, 2));
        adds = repmat(flip(csdYTick)', 1, size(waveTemp, 2));
        temp = waveTemp  + adds;
        plot(MUA.tWave(tIndex), temp, "k-", "LineWidth", 1); hold on
        title(AxesCSD(dIndex), strcat(stimStr(dIndex)));


        %% plot MUA Image
        AxesMUA(dIndex) = mSubplot(Fig, plotRows,  ceil(length(chAll)/plotRows)*2, 2*dIndex, [1, 1], margins, paddings);
        CData = flipud(MUA.Data);
        imagesc('XData', MUA.tImage, 'CData', CData);
        colormap(AxesMUA(dIndex), "hot");
        ylim([1, size(MUA.Data, 1)]);
        xlim(selWin);
        cRange = scaleAxes(AxesMUA(dIndex), "c", "on");
        scaleAxes(AxesMUA(dIndex), "c", [0, 0.9] * cRange(2));
        % scaleAxes(Axes, "c", [0, 1]);
        set(AxesMUA(dIndex), "ytick", linspace(1, size(MUA.Data, 1), length(MUA.Chs)));
        set(AxesMUA(dIndex), "yticklabel", string(num2cell(flip(MUA.Chs))'));
        title(AxesMUA(dIndex), "MUA Color Map");
%         colorbar
    %     legend;
end

setAxes(AxesMUA, "Tag", "MUA");
setAxes(AxesCSD, "Tag", "CSD");

% add vertical line
lines(1).X = 0;
lines(1).color = "red";
addLines2Axes(Fig, lines);

end
