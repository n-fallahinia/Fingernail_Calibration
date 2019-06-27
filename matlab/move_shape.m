% MOVE_SHAPE Moves a shape to a new location using the parameters in the
% alignment structure, which are:
% 
%   theta   - rotation angle (radians), where positive rotations appear
%             clockwise on the image plane.
%   scale   - scaling factor
%   (tx,ty) - displacement vector (in pixels), where tx represents
%             horizontal (column) displacement and ty represents vertical
%             (row) displacement, with positive tx to the right and
%             positive ty downward.
% 
% Created by Thomas R. Grieve
% 7 March 2012
% University of Utah
% 

function new_shape = move_shape(old_shape, alignment_structure, options)

    % Extract coordinates and parameters
    if (nargin() == 2)
        [current_x, current_y, num_dirs, use_xy] = process_inputs(old_shape, []);
    elseif (nargin() == 3)
        [current_x, current_y, num_dirs, use_xy] = process_inputs(old_shape, options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Extract alignment parameters
    theta = alignment_structure.theta;
    scale = alignment_structure.scale;
    tx = alignment_structure.tx;
    ty = alignment_structure.ty;
    
    % Remove the original centroid and scale the shape
    current_x = (current_x - tx(2)) / scale(2);
    current_y = (current_y - ty(2)) / scale(2);
    
    % Rotate the shape
    new_x = cos(theta)*current_x + sin(theta)*current_y;
    new_y = -sin(theta)*current_x + cos(theta)*current_y;
    
    % Scale the shape and move it to the new centroid
    new_x = scale(1)*new_x + tx(1);
    new_y = scale(1)*new_y + ty(1);
    
    % Store in a point array following the input format, guided by the
    % parameters found when processing inputs
    if (num_dirs == 1)
        new_shape = [new_y; new_x];
    else
        if (use_xy)
            new_shape = [new_x new_y];
        else
            new_shape = [new_y new_x];
        end
    end

end % move_shape

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process inputs, verifying size and shape and extracting options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [old_x, old_y, num_dirs, use_xy] = process_inputs(old_shape, options)

    % Determine whether to use position or shape as the processing method
    if (isfield(options,'use_xy'))
        use_xy = options.use_xy;
    else
        use_xy = false;
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
