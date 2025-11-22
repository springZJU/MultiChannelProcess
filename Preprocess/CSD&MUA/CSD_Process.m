function [CSD, LFP] = CSD_Process(trialsLFP, window, varargin)

%% Validate input
mInputParser = inputParser;
mInputParser.addRequired("trialsLFP");
mInputParser.addRequired("window");
mInputParser.addOptional("CSD_Method", "kCSD", @(x) any(validatestring(x, {'five point','three point', 'kCSD'})));
mInputParser.addOptional("badCh", [], @(x) validateattributes(x, {'numeric'}, "2d"));
mInputParser.addOptional("dz", 150, @(x) validateattributes(x, {'numeric'}, {'numel', 1}));

mInputParser.parse(trialsLFP, window, varargin{:});
CSD_Method = mInputParser.Results.CSD_Method;
badCh = mInputParser.Results.badCh;
dz = mInputParser.Results.dz;
%% handle bad channel
tIdx = linspace(window(1), window(2), size(trialsLFP{1}, 2));
[~, baseIdx] = findWithinInterval(tIdx', [window(1), 0]);
trialsLFP = cellfun(@(x) x./SE(x(:, baseIdx), 2), trialsLFP, "UniformOutput", false);
temp = changeCellRowNum(trialsLFP);

badCh  = sort(badCh);
idx    = [1, find(diff(badCh) > 1)+1]';
idx    = [idx, [idx(2:end)-1; length(badCh)]];
if ~isempty(badCh)
    badCHs = rowFcn(@(x) badCh(x(1): x(2)), idx, "UniformOutput", false); 
    for badIdx = 1 :length(badCHs)
        A = temp{badCHs{badIdx}(1)-1, 1};
        B = temp{badCHs{badIdx}(end)+1, 1};
        k = (badCHs{badIdx}(end)+1) - (badCHs{badIdx}(1)-1) + 1;
        t = linspace(0,1,k);                    % 插值系数 [0, 1]
        matrices = A .* reshape(1-t,1,1,[]) + B .* reshape(t,1,1,[]);
        for mIndex = 1 : size(matrices, 3)
            temp{badCHs{badIdx}(1)-2+mIndex, 1} = matrices(:, :, mIndex);
        end
    end
end
trialsLFP = changeCellRowNum(temp);
goodCH = find(~ismember(1:size(trialsLFP{1}, 1), badCh));
trialsLFP_CSD = cellfun(@(x) x(min(goodCH): max(goodCH), :), trialsLFP, "UniformOutput", false);

%% compute CSD
switch string(CSD_Method)
    case "five point"
        W = -1*[0.23, 0.08, -0.62, 0.08, .23];
        Boundary = 2;
        dz = 2 * dz;
    case "three point"
        W = -1*[ 0.23, -0.54, 0.23];
        Boundary = 1;
        dz = 2 * dz;
    case "kCSD" %
        W = -0.4 * [1, -2, 1];
        Boundary = 1;
end
[CSD_Raw, CSD_Wave] = cellfun(@(x) CSD_Compute(x, Boundary, W, dz), trialsLFP_CSD, "UniformOutput", false);

CSD.Data = cell2mat(cellfun(@mean, changeCellRowNum(CSD_Raw), "uni", false));
CSD.Chs = Boundary + min(goodCH) : max(goodCH) - Boundary;
CSD.t = linspace(window(1), window(2), size(CSD.Data, 2));
CSD.Boundary = Boundary;
CSD.tWave = linspace(window(1), window(2), size(CSD_Wave{1}, 2));
CSD.Wave = CSD_Wave;

%% compute lfp image data
temp = cellfun(@(x) interp2(x, 3), trialsLFP, "UniformOutput", false);
LFP.Data = cell2mat(cellfun(@mean, changeCellRowNum(temp), "UniformOutput", false));
LFP.Chs = 1 : size(trialsLFP{1}, 1);
LFP.Raw = double(cell2mat(cellfun(@mean, changeCellRowNum(trialsLFP), "UniformOutput", false)));
LFP.tImage = linspace(window(1), window(2), size(LFP.Data, 2));
LFP.tWave = linspace(window(1), window(2), size(LFP.Raw, 2));













