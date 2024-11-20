function data = RHD2TDT_LFP(LFP_Path, SR_LFP, fd_lfp)
fileName = LFP_Path;
dataInfo = dir(fileName);
dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
dataTypeNBytes = numel(typecast(cast(0, dataType), 'uint8')); % determine number of bytes per sample
nCh = 128;
nSamp = fix(dataInfo.bytes/(nCh * dataTypeNBytes));  % Number of samples per channel
mmf = memmapfile(fileName,'Format', {dataType, [nCh nSamp], 'x'}, 'Offset', 0, 'Repeat', 1);
lfp.fs = SR_LFP;
lfp.name = 'Llfp';
lfp.startTime = 0;
% dataBuffer = zeros(nCh, nSamp);
groups = num2cell(reshape(1:nCh, 32, []), 1);
if nSamp > 3e6
    lfp.channels = 1:32;
    for gIndex = 1 : length(groups)
        chData = mmf.Data.x(groups{gIndex}, :);
        lfp.data = double(chData)/1e6;
        resampleRes = ECOGResample(lfp, fd_lfp);
        dataBuffer(groups{gIndex}, :) = resampleRes.data;
        clc
    end
    data = lfp;
    data.data = dataBuffer;
    data.channels = 1:nCh;
    data.fs       = resampleRes.fs;
else
    lfp.channels = 1:nCh;
    fId = fopen(fileName, "r");
    lfp.data = fread(fId, [nCh, inf], "int16") / 1e6;
    fclose(fId);
    data = ECOGResample(lfp, fd_lfp);
end
