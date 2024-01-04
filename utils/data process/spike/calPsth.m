function [resPsth, count] = calPsth(data, binpara, scaleFactor, varargin)
mIp = inputParser;
mIp.addRequired("data", @(x) isnumeric(x) | iscell(x));
mIp.addRequired("binpara", @isstruct);
mIp.addOptional("scaleFactor", 1e3, @isnumeric);
mIp.addParameter("NTRIAL", 1, @isnumeric);
mIp.addParameter("EDGE", [], @isnumeric);

mIp.parse(data,binpara,scaleFactor, varargin{:});
NTRIAL = mIp.Results.NTRIAL;
EDGE = mIp.Results.EDGE;
parseStruct(binpara);

if iscell(data)
    cellData = data;
    NTRIAL = length(cellData);
    data = cell2mat(cellData);
else
    if numel(data) == length(data)
        lengths = diff([0; find(diff([data; -inf]) < 0)]);
        chInfo = cellfun(@(x) x*ones(lengths(x), 1), num2cell(1:length(lengths))', "UniformOutput", false);
        data = [data, cell2mat(chInfo)];
        cellData = cellfun(@(x) data(data(:, 2) == x, :), num2cell(1:max([length(lengths), NTRIAL]))', "UniformOutput", false);
    else
        cellData = cellfun(@(x) data(data(:, 2) == x, :), num2cell([unique(data(:, 2)); (-1:-1:-1*(NTRIAL - length(unique(data(:, 2)))))']), "UniformOutput", false);
    end
end
cellData(cellfun(@isempty, cellData)) = {EDGE(1)-100};
if isempty(EDGE)
    EDGE = [min(data), max(data)];
end

edgeBuffer = EDGE(1):binstep:EDGE(2);
edges(:,1) = edgeBuffer;
edges(:,2) = edges(:,1)+binsize;
edges(:,3) = mean(edges,2);
resX = edges(: ,3);
if ~isempty(data)
    count = cell2mat(cellfun(@(y) cell2mat(cellfun(@(x) max([0, histcounts(y(:, 1), edges(x, [1, 2]))]), num2cell(1:size(edges, 1))', "UniformOutput", false)), cellData, "uni",false)')';
    resY = mean(count, 1)/binsize*scaleFactor;
else
    resY = [];
end

if ~isempty(resY)
    resPsth = [resX resY'];
else
    resPsth = [resX zeros(length(resX), 1)];
end


