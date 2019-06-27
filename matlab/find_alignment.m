% FIND_ALIGNMENT Calculates the alignment between two images using the
% Procrustes analysis given in Cootes, et. al., "Active Shape Models--Their
% Training and Application," Computer Vision and Image Understanding, 1992.
% This follows the derivation in Appendix A.  The inputs image1 and image2
% are the coordinates of the shapes in the two images, while the third
% input, weights, is a vector of weight parameters for each of the points.
% The output structure contains the angle of rotation theta, the scale,
% and the offset vector [tx ty].
% 
% The transformation will move image2 onto image1.  (In other words, use
% the following commands:
% 
%   image1_approx = move_shape(image2, alignment_structure);
%   image2_approx = move_shape_inv(image1, alignment_structure);
% 
% Created by Thomas R. Grieve
% 3 April 2012
% University of Utah
% 

function alignment_structure = find_alignment(image1, image2, options)

    % Process inputs
    if (nargin() == 2)
        [x1, y1, x2, y2] = process_inputs(image1, image2, []);
    elseif (nargin() == 3)
        [x1, y1, x2, y2] = process_inputs(image1, image2, options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Calculate the centroids of the two shapes
    x1c = mean(x1);
    y1c = mean(y1);
    x2c = mean(x2);
    y2c = mean(y2);
    
    % Form the centered points matrices
    pts1 = [x1-x1c y1-y1c];
    pts2 = [x2-x2c y2-y2c];
    
    % Calculate the scale factors of the two shapes
    scale1 = sqrt(sum(sum(pts1.^2, 2), 1));
    scale2 = sqrt(sum(sum(pts2.^2, 2), 1));
    
    % Calculate the SVD of the points matrix to find theta
    [U,S,V] = svd((pts1 / scale1)' * (pts2 / scale2));
    R = V*U';
    theta = atan2(R(2,1), R(1,1));
    
    % Extract the parameters
    alignment_structure.scale = [scale1 scale2];
    alignment_structure.theta = theta;
    alignment_structure.tx = [x1c x2c];
    alignment_structure.ty = [y1c y2c];

end % find_alignment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process inputs, verifying size and shape
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x1, y1, x2, y2] = process_inputs(image1, image2, options)

    % Determine whether to use position or shape as the processing method
    if (isfield(options,'use_xy'))
        use_xy = options.use_xy;
    else
        use_xy = false;
    end
    
    % Arrange image 1 points in (x1, y1) variables
    [num_points, num_dirs] = size(image1);
    if ((num_dirs == 1) && (mod(num_points,2) == 0))
        % Extract current shape, assuming the vector of points contains
        % coordinates in [y(1:num_points); x(1:num_points)] format
        num_points = num_points / 2;
        x1 = image1(num_points+1:end);
        y1 = image1(1:num_points);
    elseif (num_dirs == 2)
        if (use_xy)
            % Extract current position (i.e., assume the array of points
            % contains [x y] coordinates)
            x1 = image1(:,1);
            y1 = image1(:,2);
        else
            % Extract current shape (i.e., assume the array of points
            % contains [rows columns] or [y x] coordinates)
            x1 = image1(:,2);
            y1 = image1(:,1);
        end
    else
        error('Shape 1 is not in a recognizable format!');
    end
    
    % Verify that the two images' point arrays are of consistent size
    [num_points2, num_dirs] = size(image2);
    if (((num_dirs == 1) && (num_points2/2 ~= num_points)) || ((num_dirs == 2) && (num_points2 ~= num_points)))
        error('Shapes must be of the same size!');
    end
    
    % Arrange image 2 points in (x2, y2) variables
    if (num_dirs == 1)
        % Extract current shape, assuming the vector of points contains
        % coordinates in [y(1:num_points); x(1:num_points)] format
        x2 = image2(num_points+1:end);
        y2 = image2(1:num_points);
    elseif (num_dirs == 2)
        if (use_xy)
            % Extract current position (i.e., assume the array of points
            % contains [x y] coordinates)
            x2 = image2(:,1);
            y2 = image2(:,2);
        else
            % Extract current shape (i.e., assume the array of points
            % contains [rows columns] or [y x] coordinates)
            x2 = image2(:,2);
            y2 = image2(:,1);
        end
    else
        error('Shape 2 is not in a recognizable format!');
    end

end % process_inputs
