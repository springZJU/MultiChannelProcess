FIGPATH = "I:\neuroPixels\Figure\CTL_New\Rat1ZYY20230902_IC1";
temp = dir(FIGPATH);
temp(matches({temp.name}, [".", "..", "Fiugre_Integration"]) | ~[temp.isdir])= [];

protRes = cellfun(@(x, y) dir(fullfile(x, y)), {temp.folder}, {temp.name}, "UniformOutput", false);
figures = cell2mat(protRes');
figures(matches({figures.name}, [".", "..", "res.mat"])) = [];
chAll = unique({figures.name}');
cellfun(@(x) Figure_Integration(FIGPATH, x), chAll, "uni", false);

function Figure_Integration(FIGPATH, CH)
    filePath = dirItem(FIGPATH, CH, "folderOrFile", "file");
    filePart = cellfun(@(x) string(strsplit(x, '\')), filePath, "UniformOutput", false);
    fileCopy = cellfun(@(x) strjoin([x(1:end-2), "Fiugre_Integration", erase(x(end), ".jpg"), strcat(x(end-1), ".jpg")], "\"), filePart, "UniformOutput", false);
    mkdir(fileparts(fileCopy{1}));
    cellfun(@(x, y) copyfile(x, y), filePath, fileCopy, "UniformOutput", false)
end