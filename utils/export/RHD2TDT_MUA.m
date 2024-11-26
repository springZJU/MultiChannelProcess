function data = RHD2TDT_MUA(WAVE_Path, SR_AP, fd_lfp)
fileName = WAVE_Path;
dataInfo = dir(fileName);
dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
dataTypeNBytes = numel(typecast(cast(0, dataType), 'uint8')); % determine number of bytes per sample
nCh = 128;
nSamp = fix(dataInfo.bytes/(nCh * dataTypeNBytes));  % Number of samples per channel
mmf = memmapfile(fileName,'Format', {dataType, [nCh nSamp], 'x'}, 'Offset', 0, 'Repeat', 1);
mua.name = 'MUA';
mua.startTime = 0;
% dataBuffer = zeros(nCh, nSamp);
groups = num2cell(reshape(1:nCh, 8, []), 1);
if nSamp > 3e6
    mua.channels = 1:8;
    for gIndex = 1 : length(groups)
        chData = mmf.Data.x(groups{gIndex}, :);
        [dataTemp, fs] = cellfun(@(x) pickUpMUA(double(x), SR_AP, [300, min([4500, SR_AP/2-500])], 500, 2, fd_lfp), num2cell(chData, 2), "UniformOutput", false);
        mua.data = cell2mat(dataTemp);
        mua.fs   = fs{1};
        dataBuffer(groups{gIndex}, :) = mua.data;
        clc
    end
    data = mua;
    data.data = dataBuffer;
    data.channels = 1:nCh;
else
    fId = fopen(fileName, "r");
    raw_wave = fread(fId, [nCh, inf], "int16");
    fclose(fId);
    [dataTemp, fs] = cellfun(@(x) pickUpMUA(double(x), SR_AP, [300, min([4500, SR_AP/2-500])], 500, 2, fd_lfp), num2cell(raw_wave, 2), "UniformOutput", false);
    data.data = cell2mat(dataTemp);
    data.channels = 1:nCh;
    data.name = 'MUA';
    data.startTime = 0;
    data.fs = fs{1};
end
