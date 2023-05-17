function plotFRA(protocolStr)
%% Parameter setting
rootPath = "E:\ratNeuroPixel\matData";
matPath = getSubfoldPath(rootPath, "data.mat" , protocolStr);
reprocess = 0;
for pIndex = 1 : length(matPath)
    dataPath = matPath{pIndex};
    disp(strcat("processing ", protocolStr , "...(", num2str(pIndex), "/", num2str(length(matPath)), ")"));
    DATAPATH = matPath{pIndex};
    if isempty(DATAPATH)
        continue
    end
    temp = strsplit(DATAPATH, "\");
    dateStr = temp{5};
    posStr = temp{6};
    protocolStr = temp{7};
    SAVEPATH = fullfile('E:\ratNeuroPixel\result', dateStr, posStr, protocolStr);
    if exist(SAVEPATH, "dir") && ~reprocess
        continue
    end

    [Fig, ch] = sFRA(dataPath);

    %% save figures
    mkdir(SAVEPATH);
    for cIndex = 1 : length(Fig)
        print(Fig(cIndex), fullfile(SAVEPATH, strcat("ch", num2str(ch(cIndex) + 1))), "-djpeg", "-r300");
    end
    close all
end
end