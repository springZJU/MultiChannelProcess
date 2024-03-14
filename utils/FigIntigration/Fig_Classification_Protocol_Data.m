warning off
FIGPATH = "H:\SPR Paper\Two-Photo Imaging\electrophysiological\Figure\CTL_New\";
temp = dir(FIGPATH);
temp(matches({temp.name}, [".", "..", "Fiugre_Integration"]) | ~[temp.isdir])= [];

dateTemp = rowFcn(@(x) dir(fullfile(x.folder, x.name)), temp, "UniformOutput", false);
dates    = unique(mCell2mat(cellfun(@(x) string({x(~matches({x.name}, [".", ".."])).name}'), dateTemp, "UniformOutput", false)));

for dIndex = 1:length(dates)
protRes = cellfun(@(x, y, z) dir(fullfile(x, y, dates(dIndex))), {temp.folder}, {temp.name}, "UniformOutput", false);
figures = cell2mat(protRes');
figures(matches({figures.name}, [".", "..", "res.mat"])) = [];
chAll = unique({figures.name}');
cellfun(@(x) Figure_Integration(FIGPATH, [char(dates(dIndex)) ,'.*', x]), chAll, "uni", false);
end

function Figure_Integration(FIGPATH, CH)
    filePath = dirItem(FIGPATH, CH, "folderOrFile", "file");
    filePart = cellfun(@(x) string(strsplit(x, '\')), filePath, "UniformOutput", false);
    fileCopy = cellfun(@(x) strjoin([x(1:end-3), "Fiugre_Integration", x(end-1), erase(x(end), ".jpg"), strcat(x(end-2), ".jpg")], "\"), filePart, "UniformOutput", false);
    cellfun(@(x) mkdir(fileparts(x)), fileCopy, "UniformOutput", false);
    cellfun(@(x, y) copyfile(x, y), filePath, fileCopy, "UniformOutput", false)
end