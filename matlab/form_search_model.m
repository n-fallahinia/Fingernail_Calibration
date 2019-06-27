% FORM_SEARCH_MODEL Creates the search matrix based on the TrainingData,
% ShapeData, TextureData and AppearanceData that can be used to
% search for the model in an image.
% 
% Created by Thomas R. Grieve
% 7 April 2012
% University of Utah
% 

function SearchMatrix = form_search_model(ShapeData, TextureData, AppearanceData, options)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Extraction of inputs, declaration of constants, etc.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Verify inputs
    if (nargin() == 3)
        [num_rows, num_columns, std_noise, default_position, offsets, mahal_max, debug_mode] = process_options([]);
    elseif (nargin() == 4)
        [num_rows, num_columns, std_noise, default_position, offsets, mahal_max, debug_mode] = process_options(options);
    else
        error('Must have 3 or 4 inputs!');
    end
    
    % Determine number of model parameters
    [num_points, num_pixels, num_shapes, num_appearance] = find_model_parameters(ShapeData, TextureData, AppearanceData);
    
    % Define number of example images that will be generated (i.e., number
    % of samples that will be used to generate each entry in the Search
    % Matrix)
    num_offsets = size(offsets, 2);
    num_examples = (num_appearance+4)*num_offsets;
    
    % Define move options
    move_options.use_xy = false;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Extract parameters that will be used repeatedly
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Extract eigenvector matrix from each model
    matrix_shape = ShapeData.Evectors;
    matrix_texture = TextureData.Evectors;
    matrix_appearance = AppearanceData.Evectors;
    
    % Extract standard deviations (eigenvalues) from each model
    eig_shape = ShapeData.Evalues;
    eig_texture = TextureData.Evalues;
    std_appearance = sqrt(AppearanceData.Evalues);
    
    % Extract the mean vector from each model
    mean_shape = ShapeData.x_mean;
    mean_texture = TextureData.g_mean;
    mean_appearance = AppearanceData.b_mean;
    
    % Extract the matrix of weights for the Shape parameters
    weight_matrix = AppearanceData.Ws;
    
    % Extract the mask image for the Texture data
    mask_image = TextureData.ObjectPixels;
    
    % Extract the base (row,column) coordinates
    base_position = TextureData.base_points;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initial steps of the search procedure
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Preallocate the matrices to hold the intermediate calculations
    del_params = zeros(num_examples, num_appearance+4);
    del_gray = zeros(num_examples, num_pixels);
    
    % Calculate the zero shape vector and zero position (x,y) coordinates
    params_shape = weight_matrix \ mean_appearance(1:num_shapes);
    zero_shape = mean_shape + matrix_shape * params_shape;
    zero_position_aligned = [zero_shape(1:num_points) zero_shape(num_points+1:end)];
    
    % Calculate the zero texture vector
    params_texture = mean_appearance(num_shapes+1:end);
    zero_texture = mean_texture + matrix_texture * params_texture;
    zero_gray = denormalize_gray_levels(zero_texture + randn(size(zero_texture))*std_noise);
    
    % Create the aligned zero image
    zero_image_aligned = convert_vector_to_image(zero_gray, mask_image);
    
    % Assign the zero transformation parameters
    zero_alignment = find_alignment(zero_position_aligned, zero_position_aligned, options);
    
    % Move the zero position according to the alignment transformation
    zero_position = move_shape_inv(zero_position_aligned, zero_alignment);
    
    % Transform the aligned zero image into the real image coordinates
    zero_transform = cp2tform(base_position(:,[2 1]), zero_position(:,[2 1]), 'piecewise linear');
    zero_image = imtransform(zero_image_aligned, zero_transform, 'Xdata', [1 num_columns], 'YData', [1 num_rows], 'XYscale', 1);
    zero_image(isnan(zero_image)) = 0;
    
    % Set up image for debug mode
    if (debug_mode)
        % Assemble the zero-position line coordinates
        Lines = ShapeData.Lines;
        zero_x = [zero_position(Lines(:,1),2) zero_position(Lines(:,2),2)]';
        zero_y = [zero_position(Lines(:,1),1) zero_position(Lines(:,2),1)]';
        
        % Initialize the figure and draw the zero image with the zero
        % position
        if (exist('figTransform','var'))
            figure(figTransform);
        else
            figTransform = figure;
        end
        set(figTransform,'Position',default_position);
        fig_rows = ceil(sqrt(num_appearance+5));
        fig_columns = ceil((num_appearance+5)/fig_rows);
        subplot(fig_rows, fig_columns, num_appearance+5);
        imshow(zero_image);
        hold on;
        plot(zero_x, zero_y, 'g-');
        hold off;
        xlabel('Original Image');
    end
    
    % Loop through all offset values to generate example images
    for offsetIdx = 1:num_offsets
        if (debug_mode)
            set(figTransform,'Name',sprintf('Offset %d: Parameter %5.2f | Transform Offset %5.2f | Scale Offset %5.2f', offsetIdx, offsets(1,offsetIdx), offsets(2,offsetIdx), offsets(3,offsetIdx)));
        end
        % Loop through each parameter of the model to generate example images
        for parameterIdx = 1:num_appearance
            % Calculate the row index for adding values to the matrices
            rowIdx = sub2ind([num_offsets num_appearance], offsetIdx, parameterIdx);
            
            % Generate current parameter values
            params_appearance = zeros(num_appearance,1);
            params_appearance(parameterIdx) = offsets(1,offsetIdx) * std_appearance(parameterIdx);
            
            % Extract Shape and Gray-Level parameters
            current_combined = mean_appearance + matrix_appearance * params_appearance;
            params_shape = weight_matrix \ current_combined(1:num_shapes);
            params_texture = current_combined(num_shapes+1:end);
            
            % Scale each parameter vector, if needed
            mahal_shape = sqrt(sum(params_shape .^2 ./ eig_shape));
            if (mahal_shape > mahal_max)
                params_shape = params_shape * mahal_max / mahal_shape;
            end
            mahal_texture = sqrt(sum(params_texture .^2 ./ eig_texture));
            if (mahal_texture > mahal_max)
                params_texture = params_texture * mahal_max / mahal_texture;
            end
            
            % Convert Shape parameters to estimate the current position
            model_shape = mean_shape + matrix_shape * params_shape;
            model_position_aligned = [model_shape(1:num_points) model_shape((num_points+1):end)];
            
            % Transform original image using current position estimate
            model_position = move_shape_inv(model_position_aligned, zero_alignment);
            current_gray = convert_image_to_vector(zero_image, model_position, mask_image, base_position);
            current_texture = normalize_gray_levels(current_gray);
            
            % Approximate the normalized Gray-Level vector using the
            % texture parameters
            model_texture = mean_texture + matrix_texture * params_texture;
            
            % Enter the change in parameter values and the change in gray
            % levels into the appropriate row of the matrices
            del_params(rowIdx,1:num_appearance) = params_appearance;
            del_gray(rowIdx,:) = current_texture - model_texture;
            
            % Display the two images, if desired
            if (debug_mode)
                % Assemble the model-position line coordinates
                model_x = [model_position(Lines(:,1),2) model_position(Lines(:,2),2)]';
                model_y = [model_position(Lines(:,1),1) model_position(Lines(:,2),1)]';
                
                % Convert the modeled texture vector to an image
                model_image = convert_vector_to_image(denormalize_gray_levels(model_texture), mask_image);
                
                % Warp that image to the zero image coordinates
                model_image = imtransform(model_image, zero_transform, 'Xdata', [1 num_columns], 'YData', [1 num_rows], 'XYscale', 1);
                model_image(isnan(model_image)) = 0;
                
                % Calculate the RMS error in the texture vectors
                rms = sqrt(sum((current_texture - model_texture).^2) / num_pixels);
                
                % Plot the current and zero positions on the modeled image
                figure(figTransform);
                subplot(fig_rows,fig_columns,parameterIdx);
                imshow(model_image);
                hold on;
                plot(zero_x, zero_y, 'g-');
                plot(model_x, model_y,'r-');
                hold off;
                xlabel(sprintf('RMS_%d %6.4f', offsetIdx, rms));
            end
        end % parameterIdx
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Now perturb each of the four transformation parameters (scale,
        % orientation and translation)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Perturb x-translation
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        current_alignment = zero_alignment;
        current_alignment.tx(2) = current_alignment.tx(2) + offsets(2, offsetIdx);
        
        % Calculate the base row index for adding values to the matrices
        rowIdx = num_appearance * num_offsets;
        
        % Move the mean shape based on the current parameter change
        current_position = move_shape_inv(zero_position, current_alignment, move_options);
        
        % Transform the actual image using the approximate shape
        current_gray = convert_image_to_vector(zero_image, current_position, mask_image, base_position);
        current_texture = normalize_gray_levels(current_gray);
        
        % Enter the change in parameter values and the change in gray
        % levels into the appropriate rows of the matrices
        del_params(rowIdx+offsetIdx, num_appearance+1) = offsets(2, offsetIdx);
        del_gray(rowIdx+offsetIdx,:) = current_texture - zero_texture;
        
        % Display the image
        if (debug_mode)
            % Assemble the current-position line coordinates
            current_x = [current_position(Lines(:,1),2) current_position(Lines(:,2),2)]';
            current_y = [current_position(Lines(:,1),1) current_position(Lines(:,2),1)]';
            
            % Calculate the RMS error in the texture vectors
            rms = sqrt(sum((current_texture - model_texture).^2) / num_pixels);
            
            % Plot the current position and zero positions on the image
            figure(figTransform);
            subplot(fig_rows,fig_columns,num_appearance+1);
            imshow(zero_image);
            hold on;
            plot(zero_x, zero_y, 'g-');
            plot(current_x, current_y, 'r-');
            hold off;
            xlabel(sprintf('RMS_%d %6.4f', offsetIdx, rms));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Perturb y-translation
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        current_alignment = zero_alignment;
        current_alignment.ty(2) = current_alignment.ty(2) + offsets(2, offsetIdx);
        
        % Calculate the base row index for adding values to the matrices
        rowIdx = (num_appearance+1) * num_offsets;
        
        % Move the mean shape based on the current parameter change
        current_position = move_shape_inv(zero_position, current_alignment, move_options);
        
        % Transform the actual image using the approximate shape
        current_gray = convert_image_to_vector(zero_image, current_position, mask_image, base_position);
        current_texture = normalize_gray_levels(current_gray);
        
        % Enter the change in parameter values and the change in gray
        % levels into the appropriate rows of the matrices
        del_params(rowIdx+offsetIdx, num_appearance+2) = offsets(2, offsetIdx);
        del_gray(rowIdx+offsetIdx,:) = current_texture - zero_texture;
        
        % Display the image
        if (debug_mode)
            % Assemble the current-position line coordinates
            current_x = [current_position(Lines(:,1),2) current_position(Lines(:,2),2)]';
            current_y = [current_position(Lines(:,1),1) current_position(Lines(:,2),1)]';
            
            % Calculate the RMS error in the texture vectors
            rms = sqrt(sum((current_texture - model_texture).^2) / num_pixels);
            
            % Plot the current position and zero positions on the image
            figure(figTransform);
            subplot(fig_rows,fig_columns,num_appearance+2);
            imshow(zero_image);
            hold on;
            plot(zero_x, zero_y, 'g-');
            plot(current_x, current_y, 'r-');
            hold off;
            xlabel(sprintf('RMS_%d %6.4f', offsetIdx, rms));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Perturb scale-x
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        current_alignment = zero_alignment;
        current_alignment.scale(2) = current_alignment.scale(2) + offsets(3, offsetIdx);
        delta_sx = offsets(3, offsetIdx) * cos(current_alignment.theta);
        delta_sy = offsets(3, offsetIdx) * sin(current_alignment.theta);
%         scale_x = current_alignment.scale(2)*cos(current_alignment.theta) + offsets(3, offsetIdx);
%         scale_y = current_alignment.scale(2)*sin(current_alignment.theta);
%         current_alignment.scale(2) = sqrt(scale_x^2 + scale_y^2);
%         current_alignment.theta = atan2(scale_y, scale_x);
        
        % Calculate the base row index for adding values to the matrices
        rowIdx = (num_appearance+2) * num_offsets;
        
        % Move the mean shape based on the current parameter change
        current_position = move_shape_inv(zero_position, current_alignment, move_options);
        
        % Transform the actual image using the approximate shape
        current_gray = convert_image_to_vector(zero_image, current_position, mask_image, base_position);
        current_texture = normalize_gray_levels(current_gray);
        
        % Enter the change in parameter values and the change in gray
        % levels into the appropriate rows of the matrices
%         del_params(rowIdx+offsetIdx, num_appearance+3) = offsets(3, offsetIdx);
        del_params(rowIdx+offsetIdx, num_appearance+(3:4)) = [delta_sx delta_sy];
        del_gray(rowIdx+offsetIdx,:) = current_texture - zero_texture;
        
        % Display the image
        if (debug_mode)
            % Assemble the current-position line coordinates
            current_x = [current_position(Lines(:,1),2) current_position(Lines(:,2),2)]';
            current_y = [current_position(Lines(:,1),1) current_position(Lines(:,2),1)]';
            
            % Calculate the RMS error in the texture vectors
            rms = sqrt(sum((current_texture - model_texture).^2) / num_pixels);
            
            % Plot the current position and zero positions on the image
            figure(figTransform);
            subplot(fig_rows,fig_columns,num_appearance+3);
            imshow(zero_image);
            hold on;
            plot(zero_x, zero_y, 'g-');
            plot(current_x, current_y, 'r-');
            hold off;
            xlabel(sprintf('RMS_%d %6.4f', offsetIdx, rms));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Perturb scale-y
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        current_alignment = zero_alignment;
        current_alignment.theta = current_alignment.theta + offsets(4, offsetIdx);
        delta_sx = current_alignment.scale(2) * (cos(current_alignment.theta) - cos(zero_alignment.theta));
        delta_sy = current_alignment.scale(2) * (sin(current_alignment.theta) - sin(zero_alignment.theta));
%         scale_x = current_alignment.scale(2)*cos(current_alignment.theta);
%         scale_y = current_alignment.scale(2)*sin(current_alignment.theta) + offsets(3, offsetIdx);
%         current_alignment.scale(2) = sqrt(scale_x^2 + scale_y^2);
%         current_alignment.theta = atan2(scale_y, scale_x);
        
        % Calculate the base row index for adding values to the matrices
        rowIdx = (num_appearance+3) * num_offsets;
        
        % Move the mean shape based on the current parameter change
        current_position = move_shape_inv(zero_position, current_alignment, move_options);
        
        % Transform the actual image using the approximate shape
        current_gray = convert_image_to_vector(zero_image, current_position, mask_image, base_position);
        current_texture = normalize_gray_levels(current_gray);
        
        % Enter the change in parameter values and the change in gray
        % levels into the appropriate rows of the matrices
%         del_params(rowIdx+offsetIdx, num_appearance+4) = offsets(3, offsetIdx);
        del_params(rowIdx+offsetIdx, num_appearance+(3:4)) = [delta_sx delta_sy];
        del_gray(rowIdx+offsetIdx,:) = current_texture - zero_texture;
        
        % Display the image
        if (debug_mode)
            % Assemble the current-position line coordinates
            current_x = [current_position(Lines(:,1),2) current_position(Lines(:,2),2)]';
            current_y = [current_position(Lines(:,1),1) current_position(Lines(:,2),1)]';
            
            % Calculate the RMS error in the texture vectors
            rms = sqrt(sum((current_texture - model_texture).^2) / num_pixels);
            
            % Plot the current position and zero positions on the image
            figure(figTransform);
            subplot(fig_rows,fig_columns,num_appearance+4);
            imshow(zero_image);
            hold on;
            plot(zero_x, zero_y, 'g-');
            plot(current_x, current_y, 'r-');
            hold off;
            xlabel(sprintf('RMS_%d %6.4f', offsetIdx, rms));
            drawnow();
        end
    end % offsetIdx
    
    % Perform linear least squares regression
    if (rank(del_gray) < size(del_gray,1))
        fprintf('\n\n\tRank is too low!\n');
        keyboard;
    end
    SearchMatrix = (del_gray \ del_params)';

end % form_search_model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the optional inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [num_rows, num_columns, std_noise, default_position, offsets, mahal_max, debug_mode] = process_options(options)

    % Process standard options
    if (isfield(options, 'image_size'))
        num_rows = options.image_size(1);
        num_columns = options.image_size(2);
    else
        num_rows = 384;
        num_columns = 512;
    end
    if (isfield(options, 'std_noise'))
        std_noise = options.std_noise;
    else
        std_noise = 0;
    end
    if (isfield(options, 'mahal_max'))
        mahal_max = options.mahal_max;
    else
        mahal_max = 3.0;
    end
    if (isfield(options,'default_position'))
        default_position = options.default_position;
    else
        default_position = [75 75 1000 750];
    end
    if (isfield(options, 'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end
    
    % Number of Appearance parameter offsets
    if (isfield(options,'num_offsets'))
        num_offsets = options.num_offsets;
    else
        num_offsets = 6;
    end
    
    % Appearance parameter offsets.  Rows correspond to:
    %   (1) Appearance Model parameters
    %   (2) Translation (x and y)
    %   (3) Scaling and Rotation (Sx)
    if (isfield(options,'offset_limits'))
        offset_limits = options.offset_limits;
    else
        offset_limits = [-0.5 0.5; -6 6; -43 43; -0.09 0.09];
    end
    
    % Generate the offsets matrix
    offsets = [linspace(offset_limits(1,1), offset_limits(1,2), num_offsets);
        linspace(offset_limits(2,1), offset_limits(2,2), num_offsets);
        linspace(offset_limits(3,1), offset_limits(3,2), num_offsets);
        linspace(offset_limits(4,1), offset_limits(4,2), num_offsets)];

end % process_options

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine various sizes from the model data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [num_points, num_pixels, num_shapes, num_appearance] = find_model_parameters(ShapeData, TextureData, AppearanceData)

    % Determine number of points
    num_points = length(ShapeData.Weights);
    
    % Determine number of pixels
    num_pixels = length(TextureData.g_mean);
    
    % Determine number of Shape parameters
    num_shapes = length(ShapeData.Evalues);
    
    % Determine number of Appearance parameters
    num_appearance = length(AppearanceData.Evalues);

end % find_model_parameters
