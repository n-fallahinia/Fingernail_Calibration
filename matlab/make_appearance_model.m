function AppearanceData = make_appearance_model(TrainingData, ShapeData, options)

    % Extract options
    if (nargin() == 2)
        [texture_scale, contour_array, verbose] = process_options([]);
    elseif (nargin() == 3)
        [texture_scale, contour_array, verbose] = process_options(options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Coordinates of mean contour
    base = [ShapeData.x_mean(1:end/2) ShapeData.x_mean(end/2+1:end)];
    
%     % To mess things up, rotate the base points by some amount
%     theta_desired = options.theta_desired;
%     th0 = -124.7805;
%     theta = th0-theta_desired;
%     cp_in = [0 0; 1 0];
%     cp_out = [0 0; cosd(theta) sind(theta)];
%     tform = cp2tform(cp_in, cp_out, 'linear conformal');
%     [x,y] = tformfwd(tform, base(:,2), base(:,1));
%     base = [y x];
    
    % Determine number of contours
    num_contours = length(contour_array);
    if (num_contours == 0)
        contour_array.array = 1:size(base,1);
    end
    
    % Normalize the base points to the desired texture size
    original_base = normalize_shape(base, ShapeData.TextureSize);
    
    % Rotate the shape so that it lies flush with the nearest edge
    new_base = rotate_shape(original_base, contour_array, ShapeData.TextureSize, verbose);
    
    % Recalculate TextureSize
    ts = ceil(max(max(new_base) - min(new_base)) * texture_scale);
    ShapeData.TextureSize = [ts ts];
    
    % Draw the contour(s) as closed white line(s) and fill the resulting object
    AppearanceData.base_points = new_base;
    AppearanceData.ObjectPixels = drawObject(AppearanceData.base_points, ShapeData.TextureSize, TrainingData(1).Lines);

end % make_appearance_model

function normalized_shape = normalize_shape(original_shape, texture_size)

    % Determine size of input
    num_points = size(original_shape, 1);
    
    % Calculate the minimum and maximum size of the shape
    min_shape = min(original_shape);
    max_shape = max(original_shape) - min_shape;
    
    % Normalize the shape to the range [0,1]
    shape_no_offset = original_shape - repmat(min_shape, num_points, 1);
    shape_normalized = shape_no_offset ./ repmat(max_shape, num_points, 1);
    
    % Transform normalized points into the coordinates in the texture
    % image.
    normalized_shape(:,1) = 1 + (texture_size(1) - 1) * shape_normalized(:,1);
    normalized_shape(:,2) = 1 + (texture_size(2) - 1) * shape_normalized(:,2);

end % normalize_shape

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rotate the base shape so that the base rests flat against 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function new_shape = rotate_shape(original_shape, contour_array, texture_scale, verbose)

    % Extract input parameters
    num_rows = texture_scale(1);
    num_columns = texture_scale(2);
    
    % Determine the angle between the bottom of the finger and the left
    % side of the image (the y-axis)
    start_point = original_shape(contour_array(1).array(1),[2 1]);
    end_point = original_shape(contour_array(1).array(end),[2 1]);
    input_points = [start_point; end_point];
    end_translated = end_point - start_point;
    base_angle = atan2(end_translated(1), end_translated(2));
    
    % Determine which way to rotate the finger
    end_offset = norm(end_translated);
    if ((base_angle <= -3*pi/4) || (base_angle > 3*pi/4))
        % Finger points right, need to rotate base to the left side
        base_points = [1 end_offset+1; 1 1];
    elseif ((base_angle > -3*pi/4) && (base_angle <= -pi/4))
        % Finger points up, need to rotate base to the bottom
        base_points = [end_offset+1 num_rows; 1 num_rows];
    elseif ((base_angle > -pi/4) && (base_angle <= pi/4))
        % Finger points left, need to rotate base to the right side
        base_points = [num_columns 1; num_columns end_offset+1];
    else
        % Finger points down, need to rotate base to the top
        base_points = [1 1; end_offset+1 1];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rotate the mean contour points so the base of the finger is flat
    % along the nearest side of the image
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Check version of Image Processing Toolbox to determine option to use
    if (get_image_processing_toolbox_version() == 0)
        error('Image Processing Toolbox is not installed!');
    elseif (get_image_processing_toolbox_version() <= 6.0)
        transform_type = 'linear conformal';
    else
        transform_type = 'nonreflective similarity';
    end
    
    % Create the transform
    tform = cp2tform(input_points, base_points, transform_type);
    
    % Transform the shape points and form into the new array
    [x,y] = tformfwd(tform, original_shape(:,2), original_shape(:,1));
    new_shape = [y x];
    
    % Translate the shape so it is in the upper-right hand corner
    new_shape = new_shape - repmat(min(new_shape),size(new_shape,1),1) + 1;
    
    if (verbose)
        figure;
        plot(original_shape(contour_array(1).array,2),original_shape(contour_array(1).array,1),'k.-');
        hold on;
        plot(original_shape(contour_array(1).array(1),2),original_shape(contour_array(1).array(1),1),'go');
        plot(original_shape(contour_array(1).array(end),2),original_shape(contour_array(1).array(end),1),'ro');
        plot(new_shape(contour_array(1).array,2),new_shape(contour_array(1).array,1),'b.-');
        plot(new_shape(contour_array(1).array(1),2),new_shape(contour_array(1).array(1),1),'go');
        plot(new_shape(contour_array(1).array(end),2),new_shape(contour_array(1).array(end),1),'ro');
        axis image;
        axis ij;
    end

end % rotate_shape

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [texture_scale, contour_array, verbose] = process_options(options)

    % Extract each option
    if (isfield(options,'texturesize'))
        texture_scale = options.texturesize;
    else
        texture_scale = 1;
    end
    if (isfield(options,'contour_array'))
        contour_array = options.contour_array;
    else
        contour_array = [];
    end
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end

end % find_contour_arrays
