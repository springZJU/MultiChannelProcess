function [AnalysisRes, PlotSettingRes] = RLA_MSTIAnesthesia_Analysis(protocolStr, FigRootPath, Date)
    MSTIParams = RLA_ParseMSTIAnesthesiaParams(protocolStr);
    parseStruct(MSTIParams);
    FIGPATH = fullfile(FigRootPath, protocolStr, Date);
    load(fullfile(FIGPATH, "spkRes.mat"));
    MSTIParams.FIGPATH = FIGPATH;
    MSTIParams.trialAll = trialAll;
    [AnalysisRes, PlotSettingRes] = RLA_PlotRasterLfp_MSTIAnesthesiaProcess(chSpikeLfp, MSTIParams);
end 