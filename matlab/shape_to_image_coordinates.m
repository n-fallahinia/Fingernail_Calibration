function transformed_shape = shape_to_image_coordinates(shape_array, image_size, limits_x)

    % Extract information from the inputs
    num_rows = image_size(1);
    num_columns = image_size(2);
    [num_points, num_dirs] = size(shape_array);
    if (num_dirs == 1)
        % Extract current shape
        num_points = num_points / 2;
        shape_array = [shape_array(1:num_points) shape_array(num_points+1:end)];
    elseif (num_dirs ~= 2)
        error('Old shape is not in a recognizable format!');
    end
    
    % Calculate interpolation parameters
    limits_y = limits_x*num_rows/num_columns;
    x_to_columns = ((num_columns-1)/(limits_x(2)-limits_x(1)));
    y_to_rows = ((num_rows-1)/(limits_y(1)-limits_y(2)));
    col_offset = num_columns/2;
    row_offset = num_rows/2;
    
    % Transform the points to the image coordinates
    transformed_shape = zeros(num_points,2);
    for pointIdx = 1:num_points
        % Transform the point into image coordinates
        colIdx = round(x_to_columns*shape_array(pointIdx,1) + col_offset);
        rowIdx = round(y_to_rows*shape_array(pointIdx,2) + row_offset);
        
        % Save the point coordinates
        transformed_shape(pointIdx,:) = [rowIdx colIdx];
    end % pointIdx
    
    % Reshape as needed
    if (num_dirs == 1)
        transformed_shape = [transformed_shape(:,1); transformed_shape(:,2)];
    end

end % function