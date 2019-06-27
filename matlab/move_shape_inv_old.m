% MOVE_SHAPE Moves a shape to a new location using the rotation (theta),
% scaling factor (scale) and displacement vector ([tx ty]) provided.
% 
% Created by Thomas R. Grieve
% 7 March 2012
% University of Utah
% 

function new_shape = move_shape_inv(old_shape, alignment_structure, options)

    % Extract coordinates and parameters
    if (nargin() == 2)
        [current_x, current_y, num_dirs, use_xy, use_centroid] = process_inputs(old_shape, []);
    elseif (nargin() == 3)
        [current_x, current_y, num_dirs, use_xy, use_centroid] = process_inputs(old_shape, options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Extract alignment parameters
    theta = -alignment_structure.theta;
    scale = 1/alignment_structure.scale;
    tx = -alignment_structure.tx;
    ty = -alignment_structure.ty;
    
    % Move the shape to (0,0) by removing the centroid
    if (use_centroid)
        centroid_x = mean(current_x);
        centroid_y = mean(current_y);
        current_x = current_x - centroid_x;
        current_y = current_y - centroid_y;
    end
    
    % Rotate, scale and translate
    new_x = scale*cos(theta)*current_x - scale*sin(theta)*current_y + tx;
    new_y = scale*sin(theta)*current_x + scale*cos(theta)*current_y + ty;
    
    % Move the shape back to the original centroid
    if (use_centroid)
        new_x = new_x + centroid_x;
        new_y = new_y + centroid_y;
    end
    
    % Store in new point array
    if (num_dirs == 1)
        new_shape = [new_y; new_x];
    else
        if (use_xy)
            new_shape = [new_x new_y];
        else
            new_shape = [new_y new_x];
        end
    end

end % move_shape_inv

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process inputs, verifying size and shape and extracting options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [old_x, old_y, num_dirs, use_xy, use_centroid] = process_inputs(old_shape, options)

    % Determine whether to use position or shape as the processing method
    if (isfield(options,'use_xy'))
        use_xy = options.use_xy;
    else
        use_xy = false;
    end
    if (isfield(options,'use_centroid'))
        use_centroid = options.use_centroid;
    else
        use_centroid = false;
    end
    
    % Determine size of input points
    [num_points, num_dirs] = size(old_shape);
    if ((num_dirs == 1) && (mod(num_points,2) == 0))
        % Extract current shape, assuming the vector of points contains
        % coordinates in [y(1:num_points); x(1:num_points)] format
        num_points = num_points / 2;
        old_x = old_shape(num_points+1:end);
        old_y = old_shape(1:num_points);
    elseif (num_dirs == 2)
        if (use_xy)
            % Extract current position (i.e., assume the array of points
            % contains [x y] coordinates)
            old_x = old_shape(:,1);
            old_y = old_shape(:,2);
        else
            % Extract current shape (i.e., assume the array of points
            % contains [rows columns] or [y x] coordinates)
            old_x = old_shape(:,2);
            old_y = old_shape(:,1);
        end
    else
        error('Old shape is not in a recognizable format!');
    end

end % process_inputs
