function resPsth = calPsth(data,binpara, scaleFactor, varargin)
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
    NTRIAL = length(data);
    data = cell2mat(data);
end
if isempty(EDGE)
    EDGE = [min(data), max(data)];
end

edgeBuffer = EDGE(1):binstep:EDGE(2)-binsize;
edges(:,1) = edgeBuffer;
edges(:,2) = edges(:,1)+binsize;
edges(:,3) = mean(edges,2);
resX = edges(: ,3);
if ~isempty(data(data > -1e6)) && max(data)>binsize
    
    count = cell2mat(cellfun(@(x) histcounts(data(data >-1e6), edges(x, [1, 2])), num2cell(1:size(edges, 1))', "UniformOutput", false));
    resY = count/binsize/NTRIAL*scaleFactor;
    
else
    resY = zeros(size(edges , 1), 1);
end

resPsth = [resX resY];


