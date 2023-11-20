function [R,iR] = makeRaster(A,i,win)
    %
    % [R,iR] = makeRaster(A,i,win)
    % 
    % Function to create raster aligned to specific indices.
    % INPUTS:
    % A = Continuous signal to create raster from
    % i = Indices to align raster on
    % win = number of sample to take around stim (Ex.: win = [-100 203]);
    
    % -------------------------------------------------------------------------
    s = size(A);
    if s(1) == 1;
        A = A';
    end
    
    if isempty(i)
        R = nan(length(win(1):win(2)));
        iR = nan;
        return
    end
    
    % Create a matrix of iR
    iR = repmat(win(1):win(2),length(i),1);
    s = size(i);
    if s(1) == 1;
        i = i';
    end
    iR = bsxfun(@plus,iR,i); % for output
    idx = iR;
    
    % Pad A with NaNs at beginning or end
    if any(idx(:) < 1)
        A = [nan(sum(idx(:) < 1),1); A];
        idx = idx + sum(idx(:) < 1);
    end
    if any(idx(:) > length(A))
        A = [A; nan(sum(idx(:) > length(A)),1)];
    end
    R = A(idx);
