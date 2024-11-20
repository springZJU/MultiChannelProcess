%% FHC Process (after running 'mexportData_FHC.m') SingleBlock
clear;clc;
Project = 'MSTIRegularity-0.3s-BG-10.8ms-Si-9ms-Sii-13.0ms';
protStr = "MSTIRegularity-0.3s-BG-10.8ms-Si-9ms-Sii-13.0ms-StdNum-6";%用来找config里面的画图参数
AnimalName = 'CM';
MATROOTPATH = ['J:\YHT\MSTIReg\MAT DATA\', AnimalName, '\', Project];
FIGROOTPATH = ['J:\YHT\MSTIReg\Figure\', Project];
DateAndPos = {};
MATDirs = dir(MATROOTPATH); MATDirs = MATDirs(3:end);
TargetfileIdx = [];
if ~isempty(DateAndPos)
    for fileIdx = 1 : numel(DateAndPos)
        TargetfileIdx = [find(contains({MATDirs.name}, DateAndPos{fileIdx})) TargetfileIdx];
    end
else
    TargetfileIdx = find(~contains({MATDirs.name}, '.'));
end
MATDirs = MATDirs(TargetfileIdx);
for DateIdx = 1 : numel(MATDirs)
    DateMATPATH = [MATROOTPATH, '\', MATDirs(DateIdx).name];
    SortMATDirs = dir(DateMATPATH);
    SortMATDirs = SortMATDirs(3:end);
    for SortIdx = 1 : numel(SortMATDirs)
        MATPATH = [MATROOTPATH, '\', MATDirs(DateIdx).name, '\', SortMATDirs(SortIdx).name];
        FIGPATH = [FIGROOTPATH, '\', MATDirs(DateIdx).name, '\', SortMATDirs(SortIdx).name, '\'];
        MLA_MSTIRegProcess(MATPATH, FIGPATH);
    end
end