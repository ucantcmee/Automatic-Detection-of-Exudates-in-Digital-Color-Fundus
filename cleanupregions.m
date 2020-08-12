function [seg, Am] = cleanupregions(seg, areaThresh, connectivity, prioritySeg)

    if ~exist('connectivity','var'), connectivity = 8; end
    if ~exist('prioritySeg','var'), prioritySeg = -1; end
    
    % 1) Ensure every segment is distinct but do not touch segments with a
    % label of 0
    labels = unique(seg(:))';
    maxlabel = max(labels);
    labels = setdiff(labels,0);  % Remove 0 from the label list
    
    for l = labels
        [bl,num] = bwlabel(seg==l, connectivity);  
        
        if num > 1  % We have more than one region with the same label
            for n = 2:num
                maxlabel = maxlabel+1;  % Generate a new label
                seg(bl==n) = maxlabel;  % and assign to this segment
            end
        end
    end

    if areaThresh
    % 2) Merge segments with small areas
    stat = regionprops(seg,'area');  % Get segment areas
    area = cat(1, stat.Area);
    Am = regionadjacency(seg);       % Get adjacency matrix
    labels = unique(seg(:))';
    labels = setdiff(labels,0);  % Remove 0 from the label list
    for n = labels
        if ~isnan(area(n)) && area(n) < areaThresh 
            % Find regions adjacent to n and keep merging with the first element 
            % in the adjacency list until we obtain an area >= areaThresh, 
            % or we run out of regions to merge.
            ind = find(Am(n,:));

            while ~isempty(ind) && area(n) < areaThresh

                if ismember(prioritySeg, ind)
                    [seg, Am, area] = mergeregions(n, prioritySeg, seg, Am, area);
                    prioritySeg = n;
                else
                    [seg, Am, area] = mergeregions(n, ind(1), seg, Am, area);
                end
                
                ind = find(Am(n,:)); % (The adjacency matrix will have changed) 
            end
        end
    end
    
    end
    
    % 3) As some regions will have been absorbed into others and no longer exist
    % we now renumber the regions so that they sequentially increase from 1.
    % We also need to reconstruct the adjacency matrix to reflect the reduced
    % number of regions and their relabeling
    [seg, minLabel, maxLabel] = renumberregions(seg);
    Am = regionadjacency(seg);    
    
%-------------------------------------------------------------------
% Function to merge segment s2 into s1
% The segment image, Adjacency matrix and area arrays are updated.
% We could make this a nested function for efficiency but then it would not
% run under Octave.
function [seg, Am, area] = mergeregions(s1, s2, seg, Am, area)
    
    if s1==s2
        fprintf('s1 == s2!\n')
        return
    end
    
    % The area of s1 is now that of s1 and s2
    area(s1) = area(s1)+area(s2);
    area(s2) = NaN;
    
    % s1 inherits the adjacancy matrix entries of s2
    Am(s1,:) = Am(s1,:) | Am(s2,:);
    Am(:,s1) = Am(:,s1) | Am(:,s2);        
    
    Am(s1,s1) = 0;  % Ensure s1 is not connected to itself

    % Disconnect s2 from the adjacency matrix
    Am(s2,:) = 0;
    Am(:,s2) = 0;
    
    % Relabel s2 with s1 in the segment image
    seg(seg==s2) = s1;
end
    