cd(fileparts(mfilename("fullpath")));
datapath = "F:\RNP\MAT Data\Rat1_SPR\CTL_New\RNP_RandSeq\Rat1SPR20230505_AC1\data.mat";
order = dlmread("orderRandSeq.txt");
load(datapath);
if ~isfield(data.epocs, "ordr")
    data.epocs.ordr.data = order;
    data.epocs.ordr.onset = data.epocs.Swep.onset;
    data.epocs.ordr.offset = data.epocs.Swep.offset;
    save(datapath, "data", "-v7.3");
end
