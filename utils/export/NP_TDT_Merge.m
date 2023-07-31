function NP_TDT_Merge(BLOCKPATH, DATAPATH, MERGEPATH, fs)
narginchk(3, 4);
if nargin < 4
    fs = 30000;
end
if iscell(DATAPATH)
    DATAPATH = string(DATAPATH);
end

mkdir(MERGEPATH);
MERGEFILE = strcat(MERGEPATH, "\Wave.bin");

dataType = "int16";
binSec = 10; % sec per segment
rowNum = 385;
binSize = round(fs*binSec);
timer = 1;

if length(BLOCKPATH) ~= length(DATAPATH)
    error("BLOCKPATH should have same length with DATAPATH");
end
datName = string(cellfun(@(x) strcat(x, "-AP\continuous.dat"), DATAPATH, "UniformOutput", false));
sampleName = string(cellfun(@(x) strcat(x, "-AP\sample_numbers.npy"), DATAPATH, "UniformOutput", false));
fidOut = fopen(MERGEFILE, 'wb');
    for bIndex = 1 : length(BLOCKPATH)
        segPoint(bIndex) = timer/fs;
        fidRead = fopen(datName(bIndex), 'r');
        segN = 0;
        while ~feof(fidRead)
            segN = segN + 1;
            dataRead = fread(fidRead, rowNum*binSize, dataType);
            fwrite(fidOut, dataRead, 'integer*2');
            fprintf('Wrote seg %d of BLOCK %d output file\n', segN, bIndex);
        end
        fclose(fidRead);

        sample_numbers = readNPY(sampleName(bIndex));
        timer = timer + length(sample_numbers);
    end
    fclose(fidOut);
    BLOCKPATHTEMP = BLOCKPATH;
    save(strcat(MERGEPATH, "\mergePara.mat"),'segPoint','BLOCKPATHTEMP');
end