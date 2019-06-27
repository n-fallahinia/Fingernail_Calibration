% FIND_WEIGHTS Calculates the weight vector, as detailed in Section 3.2 of
% Cootes, et. al., "Active Shape Models--Their Training and Application,"
% Computer Vision and Image Understanding, 1992. Specifically, this
% implements Equation 6 of that paper.  The weights are the inverse of the
% sums of the variances in the distances between each point and every other
% point in each image.
% 
% Created by Thomas R. Grieve
% 3 April 2012
% University of Utah
% 

function weights = find_weights(point_array)

    % Determine size of input
    [num_points, num_images] = size(point_array);
    if (mod(num_points,2) ~= 0)
        error('point_array must be a 2*nPoints-by-nImages array!');
    end
    num_points = num_points / 2;
    
    % Process each point
    weights = zeros(num_points,1);
    for pointIdx = 1:num_points
        % Initialize the current sum variable
        current_sum = 0;
        
        % Find the variance in distances for this point in each image
        for imageIdx = 1:num_images
            % Find the (row,column) coordinates of the current point in the
            % current image
            current_point = [point_array(pointIdx,imageIdx) point_array(num_points + pointIdx,imageIdx)];
            
            % Find distances to all other points in the current image
            distances = zeros(num_points,1);
            for otherPointIdx = 1:num_points
                % Do not process the current point
                if (pointIdx == otherPointIdx)
                    continue;
                end
                
                % Find the (row,column) coordinates of the other point in
                % the current image
                other_point = [point_array(otherPointIdx,imageIdx) point_array(num_points + otherPointIdx,imageIdx)];
                
                % Calculate the distance
                distances(otherPointIdx) = norm(current_point - other_point);
            end % otherPointIdx
            
            % Find the variance in the distances and add to the sum
            current_sum = current_sum + var(distances);
        end % imageIdx
        
        % Invert the sum to get the weight
        weights(pointIdx) = 1 / current_sum;
    end % pointIdx

end % find_weights
