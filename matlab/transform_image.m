%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform the original image to the desired coordinates.
% 
% Inputs:
%   image_in         - Image to be transformed
%   position_in      - Array of points (row, column) in the input image
%   position_desired - Array of points (row, column) in the aligned image
%   desired_size     - Size/coordinates of the aligned image.  If
%           desired_size is a 2-by-2 array, it is assumed to have the
%           format [min_row, min_column; max_row, max_column].  If it is a
%           2-element vector, it is assumed that the first element is
%           max_row and the second element is max_column, and the minimum
%           values are 1.  If it is a single value, it is assumed that the
%           maximum values are the same single value, and the minimum
%           values are both 1.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [image_aligned, position_aligned] = transform_image(image_in, position_in, position_desired, desired_size, triangles, debug_mode)

    % Process inputs
    if (nargin() == 4)
        [xy_in, xy_desired, desired_size, new_tri, debug_mode] = process_inputs(position_in, position_desired, desired_size, [], []);
    elseif (nargin() == 5)
        [xy_in, xy_desired, desired_size, new_tri, debug_mode] = process_inputs(position_in, position_desired, desired_size, triangles, []);
    elseif (nargin() == 6)
        [xy_in, xy_desired, desired_size, new_tri, debug_mode] = process_inputs(position_in, position_desired, desired_size, triangles, debug_mode);
    else
        error('Must have 4, 5 or 6 inputs!');
    end
    
    % Verify number of outputs
    use_position = (nargout() == 2);
    
    if (false)
        % Calculate the piecewise linear transformations (forward and inverse)
        transform_in_to_desired = cp2tform(xy_in, xy_desired, 'piecewise linear');
        if (use_position)
            transform_desired_to_in = cp2tform(xy_desired, xy_in, 'piecewise linear');
        end
    else
        % Create temporary transform to get the structure data
        num_points = size(position_in, 1);
        selected_points = create_random_index_array(4, num_points);
        try
            transform_in_to_desired = cp2tform(position_in(selected_points,:), position_desired(selected_points,:), 'piecewise linear');
        catch exception
            while (~isempty(exception))
                exception = [];
                selected_points = create_random_index_array(4, num_points);
                try
                    transform_in_to_desired = cp2tform(position_in(selected_points,:), position_desired(selected_points,:), 'piecewise linear');
                catch exception
                    if ((~strcmp(exception.identifier,'Images:cp2tform:foldoverTriangles')) && (isempty(strfind(exception.message,'At least 4 points'))))
                        keyboard;
                    end
                end
            end
        end
        
        % Calculate the piecewise linear transformations (forward and inverse)
        transform_in_to_desired = piecewise_linear_transform(transform_in_to_desired, position_in(:,[2 1]), position_desired(:,[2 1]), triangles, debug_mode);
        if (use_position)
            transform_desired_to_in = piecewise_linear_transform(transform_in_to_desired, position_desired(:,[2 1]), position_in(:,[2 1]), triangles, debug_mode);
        end
    end
    
    if (use_position)
        % Transform the control points into the new coordinate system
        [x_des, y_des] = tforminv(transform_desired_to_in, position_in(:,2), position_in(:,1));
        
        % Move points into the new image coordinates
        xy_aligned = [x_des y_des];
        
        % Convert to (r,c) coordinates
        position_aligned = xy_aligned(:, [2 1]);
    end
    
    % Transform the image into the default texture image
    image_aligned = imtransform(image_in, transform_in_to_desired, 'Xdata', [desired_size(1,1) desired_size(2,1)], 'YData', [desired_size(1,2) desired_size(2,2)], 'XYscale', 1);
    
    % Zero any pixels with NaN values
    image_aligned(isnan(image_aligned)) = 0;

end % transform_image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the inputs, converting them to the desired size/shape.
% 
%   The input and desired points are converted from (row,column) format to
%       (x,y) format and "pre-processed" to remove any fold-over triangles
%       that might cause a problem for the piecewise linear transformation
%       used to transform the image.
%   The desired size is verified to be 2-by-2, with the first column
%       containing the 'x' coordinates (column data) and the second column 
%       containing the 'y' coordinates (row data).
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xy_in, xy_desired, desired_size, triangles, debug_mode] = process_inputs(rc_in, rc_desired, desired_size, triangles, debug_mode)

    % Adjust size of alignment input to match the expected size
    [num_rows, num_columns] = size(desired_size);
    if (num_rows == 1)
        if (num_columns == 1)
            % If one value, assume we're given both maxima and minima are 1
            desired_size = [1 1; desired_size*[1 1]];
        elseif (num_columns == 2)
            % If one row, assume we are given maxima, and minima are 1
            desired_size = [1 1; desired_size];
        else
            error('Cannot understand alignment size!');
        end
    elseif (num_rows == 2)
        if (num_columns == 1)
            % If one column, assume we are given maxima, and minima are 1
            desired_size = [1 1; desired_size'];
        elseif (num_columns ~= 2)
            error('Cannot understand alignment size!');
        end
    else
        error('Cannot understand alignment size!');
    end
    
    % Default value for debug_mode
    if (isempty(debug_mode))
        debug_mode = false;
    end
    
    % Convert point coords and desired size from (row,column) into (x,y)
    xy_in_pre = rc_in(:, [2 1]);
    xy_desired_pre = rc_desired(:, [2 1]);
    desired_size = desired_size(:, [2 1]);
    
    % Remove control points which give folded-over triangles for cp2tform
    [xy_in, xy_desired, triangles] = PreProcessCp2tform(xy_in_pre, xy_desired_pre, triangles);
    [xy_desired, xy_in, triangles] = PreProcessCp2tform(xy_desired, xy_in, triangles);
    [xy_in, xy_desired, triangles] = PreProcessCp2tform(xy_in, xy_desired, triangles);

end % process_inputs
