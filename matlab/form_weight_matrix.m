% FORM_WEIGHT_MATRIX Forms the weight matrix for use in finding the
% Combined Model.
% 
% Created by Thomas R. Grieve
% 7 April 2012
% University of Utah
% 

function weight_matrix = form_weight_matrix(TrainingData, ShapeData, TextureData)

    % Use the method of Stegmann's Thesis (2000)
    texture_variance = sum(TextureData.Evalues);
    shape_variance = sum(ShapeData.Evalues);
    weight_matrix = texture_variance / shape_variance;
    return;
    
    % Verify inputs
    if (nargin() ~= 3)
        error('Must have 3 inputs!');
    end
    
    % Determine size of inputs
    num_training = length(TrainingData);
    num_shapes = length(ShapeData.Evalues);
    num_points = size(TrainingData(1).Vertices,1);
    num_pixels = length(TextureData.g_mean);
    
    % Extract useful parameters from model
    shape_matrix = ShapeData.Evectors;
    mean_shape = ShapeData.x_mean;
    shape_weights = ShapeData.Weights;
    shape_limits = sqrt(ShapeData.Evalues);
    
    % Initialize the output
    error_matrix = zeros(num_training, num_shapes);
    param_values = [-0.5 0.5];
    num_params = length(param_values);
    
    % Determine the amount the gray level of each training image is displaced
    % by a step change in the shape parameters
    for trainingIdx = 1:num_training
        % Extract the training points
        current_shape = [TrainingData(trainingIdx).Vertices(:,1); TrainingData(trainingIdx).Vertices(:,2)];
        
        % Calculate the alignment estimate
        alignment_estimate = find_alignment(mean_shape, current_shape, shape_weights);
        
        % Move the shape to the aligned location
        aligned_shape = move_shape(current_shape, alignment_estimate);
        
        % Extract the shape parameter vector for the current shape
        shape_params = shape_matrix' * (aligned_shape - mean_shape);
        
        % Calculate the approximate shape
        current_shape_estimate = mean_shape + shape_matrix * shape_params;
        
        % Apply the transform previously calculated
        aligned_estimate = move_shape_inv(current_shape_estimate, alignment_estimate);
        aligned_estimate = [aligned_estimate(1:num_points) aligned_estimate(num_points+1:end)];
        
        % Change each shape parameter in turn
        for shapeIdx = 1:num_shapes
            % Initialize a placeholder for the two pixel vectors to be
            % compared
            pixel_vectors = zeros(num_pixels, num_params);
            
            % Process each parameter (a unit step around zero)
            for paramIdx = 1:num_params
                % Extract the current parameter values
                current_params = shape_params;
                
                % Adjust the shape parameter vector to follow the desired step
                desired_step = param_values(paramIdx);% * shape_limits(shapeIdx);
                current_params(shapeIdx) = current_params(shapeIdx) + desired_step;
                
                % Calculate the resulting shape
                current_shape_perturbed = mean_shape + shape_matrix * current_params;
                
                % Apply the transformation previously calculated
                aligned_shape_perturbed = move_shape_inv(current_shape_perturbed, alignment_estimate);
                aligned_shape_perturbed = [aligned_shape_perturbed(1:num_points) aligned_shape_perturbed(num_points+1:end)];
                
                % Transform the image using the perturbed shape
                [gray_offset, warped_shape] = convert_image_to_vector(TrainingData(trainingIdx).I, aligned_shape_perturbed, TextureData.ObjectPixels, TextureData.base_points);
                [pixel_vectors(:,paramIdx), alpha, beta] = normalize_gray_levels(gray_offset);
            end % paramIdx
            
            % Calculate the current error estimate
            pixel_errors = diff(pixel_vectors,[],2);
            error_rms = sqrt(sum(pixel_errors.^2) / num_pixels);
            error_matrix(trainingIdx,shapeIdx) = error_rms;
        end % shapeIdx
    end % trainingIdx
    
    % Sum each column and make the output a diagonal matrix of the sums
    weight_matrix = diag(sqrt(sum(error_matrix.^2) / num_training));

end % form_weight_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the input option structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [image_scale, debug_mode] = process_options(options)

    if (isfield(options,'image_scale'))
        image_scale = options.image_scale;
    else
        image_scale = 1024;
    end
    if (isfield(options,'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end

end % process_options
