function wf = getWaveForm_singleID_v2(fs, dataPath, NPYPATH, unitID, IDandCHANNEL, wfWin, onsetIdx)
% Description: Get waveform of each spike from kilosort result
% Input:
%    - fs: sample rate of *.dat
%    - dataPath: full path of *.dat
%    - NPYPATH: full path of *.npy
%    - unitID: id of units sorted from kilosort, 1*1 or n*1
%    - IDandCHANNEL: user-defined m*3 matrix, col 1: ksId; col2: custom; col 3: ksCh
%    - wfWin(optional): [-s, s] samples centered at spike index from spike_times.npy
%    - onsetIdx: if spikeIdx is from merged data while *.dat is for blocks,
%                use onsetIdx to align them. 
% Output:
%    - wf: struct type
% Example:
%     fs = 12207.03125;
%     dataPath = 'G:\ECoG\DD\dd20221122\Merge1';
%     NPYPATH = 'G:\ECoG\DD\dd20221122\Merge1\th7_6';
%     unitID = [2, 3];
%     wfWin = [-30, 30];
%     id = 0 : 10;
%     ch = [1, 3, 6, 5, 6, 7, 9, 11, 12, 13, 14];
%     IDandCHANNEL = [id; zeros(1, 11); ch]';
%     waveform = getWaveForm_singleID_v2(fs, DataPath, NPYPATH, unitID, IDandCHANNEL, wfWin);


narginchk(5, 7);
if nargin < 6
    wfWin = [-30 30]; % Number of samples before and after spiketime to include in waveform
end

if nargin < 7
    onsetIdx = 0;
end


%% load npy files
spikeTimeIdx =    readNPY([NPYPATH, '\spike_times.npy']); % Vector of cluster spike times (in samples) same length as .spikeClusters
spikeClusters = readNPY([NPYPATH, '\spike_clusters.npy']); % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
chMap = readNPY([NPYPATH, '\channel_map.npy'])';               % Order in which data was streamed to disk; must be 1-indexed for Matlab

%% get corresponding channel
MChInID = IDandCHANNEL(ismember(IDandCHANNEL(:,1), unitID), 3) + 1;

%% read data via memory map
fileName = fullfile(dataPath, 'Wave.bin');% .dat file containing the raw
dataInfo = dir(fileName);
dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
dataTypeNBytes = numel(typecast(cast(0, dataType), 'uint8')); % determine number of bytes per sample
nCh = length(unique(chMap));
nSamp = dataInfo.bytes/(nCh * dataTypeNBytes);  % Number of samples per channel
mmf = memmapfile(fileName,'Format', {dataType, [nCh nSamp], 'x'});
data = mmf.Data(1).x;

%% get waveform for each unit
for idIndex= 1 : length(1 : length(unitID))
    disp(strcat("picking up unit ", num2str(unitID(idIndex)), " ..."));
    % compute spike segment index
    SpikeIndex = double(spikeTimeIdx(spikeClusters==unitID(idIndex) & spikeTimeIdx > onsetIdx & spikeTimeIdx <= onsetIdx + size(data, 2))) - onsetIdx;
    SpikeTime = double(SpikeIndex - 1) / fs ;
    spkSegIdx = cell2mat(arrayfun(@(x) x + wfWin, SpikeIndex, "UniformOutput", false));
    if ~isempty(spkSegIdx)
        spkSegIdx(spkSegIdx(: ,1) + wfWin(1) < 0 | spkSegIdx(: ,2) + wfWin(2) > size(data, 2), :) = [];

        % Read spike time-centered waveforms
        chDataSel = data(MChInID(idIndex), :);
        waveForms = double(cell2mat(cellfun(@(x) chDataSel(x(1) : x(2)), num2cell(spkSegIdx, 2) , "UniformOutput", false)));
        wfSmooth = smoothdata(waveForms','gaussian', 10)';
        waveFormsMean = mean(waveForms);
        wfSmMean = mean(wfSmooth);
    

    % Package in wf(idIndex) struct
    wf(idIndex).unitID = unitID(idIndex);
    wf(idIndex).MChInID = MChInID(idIndex);
    wf(idIndex).fs =  fs;
    wf(idIndex).wfWin = [0 wfWin(end)- wfWin(1)] / fs * 1000;
    wf(idIndex).SpikeTime = SpikeTime;
    wf(idIndex).waveForms = waveForms;
    wf(idIndex).waveFormsMean = waveFormsMean;
    wf(idIndex).wfSmooth = wfSmooth;
    wf(idIndex).wfSmMean = wfSmMean;
    disp("DONE!");
    clc;
    end
end
clear mmf
return
end