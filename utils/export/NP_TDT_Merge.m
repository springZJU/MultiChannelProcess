function NP_TDT_Merge(BLOCKPATH, DATAPATH, MERGEFILE, fs)
narginchk(3, 4);
if nargin < 4
    fs = 30000;
end
if iscell(DATAPATH)
    DATAPATH = string(DATAPATH);
end


dataType = "int16";
binSec = 10; % sec per segment
rowNum = 385;
binSize = round(fs*binSec);
timer = 1;

if length(BLOCKPATH) ~= length(DATAPATH)
    error("BLOCKPATH should have same length with DATAPATH");
end
if contains(DATAPATH{1}, ".ProbeA")
    datName = string(cellfun(@(x) strcat(x, "-AP\continuous.dat"), DATAPATH, "UniformOutput", false));
    sampleName = string(cellfun(@(x) strcat(x, "-AP\sample_numbers.npy"), DATAPATH, "UniformOutput", false));
else
    datName = string(cellfun(@(x) strcat(x, ".0\continuous.dat"), DATAPATH, "UniformOutput", false));
    sampleName = string(cellfun(@(x) strcat(x, ".0\sample_numbers.npy"), DATAPATH, "UniformOutput", false));
end
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
save(strrep(MERGEFILE, 'Wave.bin', 'mergePara.mat'),'segPoint','BLOCKPATH');
end