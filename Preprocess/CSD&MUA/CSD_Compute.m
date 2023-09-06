function [csdRes, csdWave] = CSD_Compute(lfpData, Boundary, W, dz)
    lfpData = double(lfpData);
    temp = zeros(size(lfpData, 1)-Boundary*2, size(lfpData, 2));
    for cIndex = Boundary + 1 : size(lfpData, 1) - Boundary
        temp(cIndex - Boundary,:) = -1 * W * lfpData(cIndex-Boundary : cIndex+Boundary, :) / (2*dz*2*dz);
    end
    csdWave = temp;
    csdRes = interp2(temp, 3);
    return
end

