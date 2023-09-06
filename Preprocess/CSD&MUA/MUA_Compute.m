function res = MUA_Compute(data, bpFilt, lpFilt)
        temp = cellfun(@(x) abs(filtfilt(bpFilt, x)), num2cell(data, 2), "uni", false);
        res = cell2mat(cellfun(@(x) filtfilt(lpFilt, x), temp, "uni", false));
end