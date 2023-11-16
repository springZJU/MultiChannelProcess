function [ResY, ResX] = calOriFirate(rasterdata, win, calMethod, varargin)

%% To get parameters
mIp = inputParser;
mIp.addRequired('rasterdata');
mIp.addRequired('win', @(x) validateattributes(x, 'numeric', {'numel', 2}));
mIp.addRequired('calMethod');
mIp.addParameter('binsize', 50, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter('scaleFactor', 1000, @isnumeric);
mIp.addParameter('NTRIAL', 1, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(rasterdata, win, calMethod, varargin{:});
binsize = mIp.Results.binsize;
scaleFactor = mIp.Results.scaleFactor;
NTRIAL = mIp.Results.NTRIAL;
%%
if calMethod == 0
    edges = win;
    binsize = win(2)-win(1);
elseif calMethod == 1
    edges = win(1):binsize:win(2);
end

for i = 1:length(edges)-1
    Frx{1, i} = [edges(i), edges(i+1)];
end

if ~isempty(rasterdata)
    if size(rasterdata, 2) > 1
        rasterdata = rasterdata(:,1);
    end
    count = cellfun(@(x) histcounts(rasterdata, x), Frx);
    Fry = count/binsize/NTRIAL*scaleFactor;
else
    Fry = zeros(1, length(Frx));
end

ResX = Frx;
ResY = Fry;
