function weights = find_weights_asm(point_array)

    % Determine size of input
    [num_points, num_images] = size(point_array);
    num_points = num_points / 2;
    
    % Process each point
    weights = zeros(num_points,1);
    for pointIdx = 1:num_points
        % Initialize the current sum variable
        current_sum = 0;
        
        % Find the variance in distances for this point in each image
        for imageIdx = 1:num_images
            % Find the current point in the current image
            current_point = [point_array(pointIdx,imageIdx) point_array(num_points + pointIdx,imageIdx)];
            
            % Find distances to all other points
            distances = zeros(num_points,1);
            for otherPointIdx = 1:num_points
                % Do not process the current point
                if (pointIdx ~= otherPointIdx)
                    % Find the other point in the current image
                    other_point = [point_array(otherPointIdx,imageIdx) point_array(num_points + otherPointIdx,imageIdx)];
                    
                    % Calculate the distance
                    distances(otherPointIdx) = norm(current_point - other_point);
                end
            end % otherPointIdx
            
            % Find the variance in the distances and add to the sum
            current_sum = current_sum + var(distances);
        end % imageIdx
        
        % Invert the sum to get the weight
        weights(pointIdx) = 1 / current_sum;
    end % pointIdx

end % function