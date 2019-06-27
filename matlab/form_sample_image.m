% FORM_SAMPLE_IMAGE Creates a sample image for use in AAM.  The shape_array
% is a set of points (in real-world coordinates) to be converted into an
% image of size image_size ([num_rows num_columns]) whose x-direction
% parameters correspond to the limits specified by limits_x ([min(x)
% max(x)]).  The final input is a Boolean indicating whether or not to draw
% the xy-axes on the image.
% 
% Created by Thomas R. Grieve
% 7 March 2012
% University of Utah
% 

function sample_image = form_sample_image(shape_array, image_size, limits_x, stdNoise, debug_mode)

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
    
    % Preallocate the output
    sample_image = uint8(255*ones(num_rows, num_columns, 3));
    
    % Calculate interpolation parameters
    limits_y = limits_x*num_rows/num_columns;
    x_to_columns = ((num_columns-1)/(limits_x(2)-limits_x(1)));
    y_to_rows = ((num_rows-1)/(limits_y(1)-limits_y(2)));
    col_offset = num_columns/2;
    row_offset = num_rows/2;
    
    % Transform the points to the image coordinates
    single_layer = zeros(num_rows, num_columns);
    image_shape = zeros(size(shape_array));
    for pointIdx = 1:num_points
        % Transform the point into image coordinates
        colIdx = round(x_to_columns*shape_array(pointIdx,1) + col_offset);
        rowIdx = round(y_to_rows*shape_array(pointIdx,2) + row_offset);
        
        % Set point to blue
        if (debug_mode)
            try
                single_layer(rowIdx,colIdx) = 1;
            catch exception
                error('You most likely need to choose a different set of x-direction image limits!');
            end
        end
        
        % Save the point coordinates
        image_shape(pointIdx,:) = [rowIdx colIdx];
    end % pointIdx
    
    % Find the points inside the image boundary
    [all_columns, all_rows] = meshgrid(1:num_columns,1:num_rows);
    inside_pixels = inpolygon(all_rows,all_columns,image_shape(:,1),image_shape(:,2));
    single_layer = single_layer+inside_pixels;
    
    % Blur the image
    single_layer = conv2(single_layer, fspecial('gaussian', 15, 5.0), 'same');
    
    % Assemble the image
    sample_image(:,:,2) = 255*(1-single_layer);
    sample_image(:,:,3) = 255*(1-single_layer);
    
    % Corrupt the image with noise
    sample_image = uint8(double(sample_image) + randn(size(sample_image))*stdNoise);
    
    % Put the axes on the image
    if (debug_mode)
        col_start = round(col_offset);
        col_end = round(x_to_columns+col_offset);
        row_start = round(row_offset);
        row_end = round(y_to_rows+row_offset);
        sample_image(row_start,col_start:col_end,:) = 0;
        sample_image(row_start:-1:row_end,col_start,:) = 0;
    end

end % function