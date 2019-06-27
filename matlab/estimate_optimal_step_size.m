function [error_estimate, step_size] = estimate_optimal_step_size(error_current, appearance_params, appearance_displacement)

    % Initialize iteration values
    accept_estimate = false;
    step_sizes = [1.0 1.5 0.5 0.25 .125 .0625];
    num_steps = length(step_sizes);
    stepIdx = 1;
    while ((~accept_estimate) && (stepIdx <= num_steps))
        % Set initial step size
        step_size = step_sizes(stepIdx);
        fprintf('Processing Step Size %6.3f', step_size);

        % Predict new model parameters (c1 = c0 - k*delta_c)
        appearance_params_new = appearance_params - step_size * appearance_displacement(1:num_appearance);

        % Predict new alignment parameters
        sx = alignment_estimate.scale*cos(alignment_estimate.theta);
        sy = alignment_estimate.scale*sin(alignment_estimate.theta);
        alignment_estimate_new.tx = alignment_estimate.tx - step_size * appearance_displacement(num_appearance+1);
        alignment_estimate_new.ty = alignment_estimate.ty - step_size * appearance_displacement(num_appearance+2);
        sx_new = sx - step_size * appearance_displacement(num_appearance+3);
        sy_new = sy - step_size * appearance_displacement(num_appearance+4);
        alignment_estimate_new.scale = sqrt(sx_new^2 + sy_new^2);
        alignment_estimate_new.theta = atan2(sy_new, sx_new);

        %%%%%%%%%%%%%%%%%%%%%%%%
        % Estimate new error
        %%%%%%%%%%%%%%%%%%%%%%%%

        % Estimate the new combined vector
        combined_vector_model_new = AppearanceData.b_mean + AppearanceData.Evectors * appearance_params_new;

    %     % Extract the texture parameters
    %     texture_params_model_new = combined_vector_model_new((num_shapes+1):end);
    %     gray_normalized_model_new = TextureData.g_mean + TextureData.Evectors * texture_params_model_new;
    %     
    %     % Calculate the modeled gray values
    %     gray_vector_model_new = denormalize_gray_levels(gray_normalized_model_new);

        % Calculate the new modeled shape/position
        shape_params_model_new = combined_vector_model_new(1:num_shapes);
        aligned_shape_model_new = ShapeData.x_mean + ShapeData.Evectors * shape_params_model_new;
        aligned_position_model_new = [aligned_shape_model_new((num_points+1):end) aligned_shape_model_new(1:num_points)];
        contour_position_model_new = move_shape(aligned_position_model_new, alignment_estimate_new);

        % Sample the image using the new contour position
        gray_vector_new = convert_image_to_vector(sample_image, contour_position_model_new, TextureData.ObjectPixels, mean_position, ShapeData.Tri, options);
        gray_normalized_new = normalize_gray_levels(gray_vector_new);

    %     % Calculate pixel error vector (delta_g1 = gs - gm1)
    %     gray_error_new = gray_normalized_new - gray_vector_model_new;
        % Calculate pixel error vector (delta_g1 = gs1 - gm)
        gray_error_new = gray_normalized_new - gray_vector_model;

        % Evaluate magnitude of current error (E1 = |delta_g1|^2)
        error_current_new = gray_error_new' * gray_error_new;
        fprintf(' | %5.2e\n', error_current_new);

        % If less than current error, accept new estimate.
        if (error_current_new < error_current)
            % Accept new estimate
            accept_estimate = true;
        else
            % Otherwise, try a new step size
            stepIdx = stepIdx + 1;
        end
    end

end % estimate_optimal_step_size
