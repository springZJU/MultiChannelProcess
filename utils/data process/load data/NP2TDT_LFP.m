function data = NP2TDT_LFP(LFP_Path, SR_LFP, fd_lfp)
    fId = fopen(strcat(LFP_Path, "\continuous.dat"), "r");
    temp.lfp.data = fread(fId, [385, inf], "int16") / 1e6;
    fclose(fId);
    temp.lfp.fs = SR_LFP;
    temp.lfp.channels = 1:385;
    temp.lfp.name = 'Llfp';
    temp.lfp.startTime = 0;
    data = ECOGResample(temp.lfp, fd_lfp);
end