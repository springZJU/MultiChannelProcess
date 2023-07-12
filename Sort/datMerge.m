clc; clear
% add path to the top
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))), "-begin");
% set params
xlsxPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "SPR_RNP_TBOffset_Recording.xlsx");
tankSel = "Rat2SPR20230708";
dataType = "int16";
binSec = 10; % sec per segment
rowNum = 385;
% load excel
[~, opts] = getTableValType(xlsxPath, "0");
recordInfo = table2struct(readtable(xlsxPath, opts));
selData = recordInfo(contains([recordInfo.BLOCKPATH]', tankSel));
BLOCKPATH = cellstr([selData.BLOCKPATH]');
TANKNAME = strsplit(selData(1).BLOCKPATH, "Block");
TANKNAME = TANKNAME(1);
datName = string(cellfun(@(x, y) strcat(x, "\", y, "-AP\continuous.dat"), [selData.datPath]', [selData.hardware]', "UniformOutput", false));
sampleName = string(cellfun(@(x, y) strcat(x, "\", y, "-AP\sample_numbers.npy"), [selData.datPath]', [selData.hardware]', "UniformOutput", false));
fs = unique([selData.SR_AP]');
binSize = round(fs*binSec);
timer = 1;


blockGroup = {[1:4, 6:11]};
for mIndex = 1 : length(blockGroup)
    MERGEPATH = strcat(TANKNAME, "Merge", num2str(mIndex));
    mkdir(MERGEPATH);
    MERGEFILE = strcat(MERGEPATH, "\Wave.bin");
    fidOut = fopen(MERGEFILE, 'wb');
    blockN = 0;
    for bIndex = 1 : length(blockGroup{mIndex})
        blockN = blockN + 1;
        segPoint(blockN) = timer/fs;
        fidRead = fopen(datName(bIndex), 'r');
        segN = 0;
        while ~feof(fidRead)
            segN = segN + 1;
            dataRead = fread(fidRead, rowNum*binSize, dataType);
            fwrite(fidOut, dataRead, 'integer*2');
            fprintf('Wrote seg %d of BLOCK %d output file\n', segN, blockN);
        end
        fclose(fidRead);

        sample_numbers = readNPY(sampleName(bIndex));
        timer = timer + length(sample_numbers);
    end
    fclose(fidOut);
    BLOCKPATHTEMP = BLOCKPATH;
    save(strcat(MERGEPATH, "\mergePara.mat"),'segPoint','BLOCKPATHTEMP');
end


