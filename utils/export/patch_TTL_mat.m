ccc
temp     = dir('D:\Lab members\GSR\Offset\BDF Data\RAT_AC\**\TTL.mat');
TTLPATH  = {temp.folder}';
temp     = dir('D:\Lab members\GSR\Offset\BDF Data\RAT_AC\**\*.rhd');
RHDPATH  = {temp.folder}';
TODOPATH = rowFcn(@(x) fullfile(x.folder, x.name), temp(~matches(RHDPATH, TTLPATH)), "UniformOutput", false); 
SAVEPATH = rowFcn(@(x) x.folder, temp(~matches(RHDPATH, TTLPATH)), "UniformOutput", false); 
for i = 1 : length(TODOPATH)
    [~, ~, board_dig_in_data] = load_Intan_RHD2000_file(TODOPATH{i});
    save(fullfile(SAVEPATH{i}, 'TTL.mat'), "board_dig_in_data");
end

