load("..\..\Sort\process\config\PKU128_kilosortChanMap.mat");
if isequal(chanMap, sort(chanMap))
    load(".\RHD_CH_Patch.mat");
    for i = 1 : length(chanMap)
        chanMap(ch_native_custom(i, 2)) = ch_native_custom(i, 1);
    end
end
save("..\..\Sort\process\config\PKU128_kilosortChanMap.mat", "chanMap", "chanMap0ind", "xcoords", "ycoords", "shankInd", "connected", "name");
