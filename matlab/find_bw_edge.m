% FIND_BW_EDGE Finds the edge points in a black-and-white image (i.e., an
% image that only contains ones and zeros).  This assumes that the edge
% points will be in areas where the 3-by-3 neighborhood is not uniquely
% black or white.
% 
% Written by Thomas R. Grieve
% 8 March 2012
% University of Utah
% 

function imgEdge = find_bw_edge(imgGray)

    % Add a border to the image.  This prevents the parts of objects along
    % the edge of the image from being identified as edges.
    imgGray = [imgGray(1,1) imgGray(1,:) imgGray(1,end);
        imgGray(:,1) imgGray imgGray(:,end);
        imgGray(end,1) imgGray(end,:) imgGray(end,end)];
    
    % Define filter
    filter_add = ones(3);
    
    % Convolve the image and the filter to determine the sum of each
    % neighborhood
    sums = conv2(double(imgGray), filter_add, 'same');
    
    % (sums < 9) finds all places where the neighborhood is not uniquely
    % ones.  Logical AND of this with the original image will give the edge
    % points.
    imgEdge = ((imgGray) & (sums < 9));
    
    % Remove the border
    imgEdge([1 end],:) = [];
    imgEdge(:,[1 end]) = [];

end % function