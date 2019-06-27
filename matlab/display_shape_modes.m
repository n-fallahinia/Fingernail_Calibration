function [figShapes, figLines] = display_shape_modes(ShapeData, TextureData, options)

    % Unpack the options
    if (nargin() == 2)
        [num_eigs, num_imgs, num_std, default_position, line_width] = process_options([]);
    elseif (nargin() == 3)
        [num_eigs, num_imgs, num_std, default_position, line_width] = process_options(options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Extract various parameters
    if (isfield(ShapeData,'Weights'))
        num_pts = length(ShapeData.Weights);
    elseif (isfield(ShapeData,'MeanVertices'))
        num_pts = size(ShapeData.MeanVertices, 1);
    else
        error('ShapeData is not in a recognizable format!');
    end
    mask_image = TextureData.ObjectPixels;
    [num_rows, num_columns] = size(mask_image);
    num_colors = length(TextureData.g_mean) / sum(mask_image(:));
    std_vals = sqrt(ShapeData.Evalues);
    Lines = ShapeData.Lines;
    
    % Initialize the figures
    figShapes = figure;
    set(figShapes,'Position',default_position);
    set(figShapes,'Name','Shape Variation (Using Textures)');
    set(figShapes,'Visible','off');
    figLines = figure;
    set(figLines,'Position',default_position);
    set(figLines,'Name','Shape Variation (Lines Only)');
    set(figLines,'Visible','off');
    
    % Extract the default image
    mean_gray = denormalize_gray_levels(TextureData.g_mean);
    imgCentroid = convert_vector_to_image(mean_gray, mask_image);
    
    % Extract the zero positions
    base_shape = TextureData.base_points;
    zero_shape = [ShapeData.x_mean(1:num_pts) ShapeData.x_mean((num_pts+1):end)];
    
    % Process each mode
    for eigIdx = 1:num_eigs
        % Initialize the mode image
        imgEig = zeros(num_rows, num_imgs*num_columns, num_colors);
        current_eig = std_vals(eigIdx) * [ShapeData.Evectors(1:num_pts, eigIdx) ShapeData.Evectors((num_pts+1):end, eigIdx)];
        
        % Process each image
        for imageIdx = 1:num_imgs
            % Calculate the current weighted Shape eigenvector
            current_std = (2*num_std / (num_imgs-1)) * (imageIdx - num_imgs) + num_std;
            current_offset = current_std * current_eig;
            
            % Appply this eigenvector to the zero positions
            %current_shape = base_shape + current_offset*scale_factor;
            image_shape = base_shape + current_offset;
            lines_shape = zero_shape + current_offset;
            
            % Calculate the starting index of the current image
            startIdx = (imageIdx-1)*num_columns;
            
            % Form the current image
            [imgCurrent, aligned_points] = transform_image(imgCentroid, base_shape, image_shape, [num_rows num_columns], ShapeData.Tri);
            
            % Insert the current image into the mode image
            imgEig(:, startIdx+(1:num_columns), :) = imgCurrent;
            
            % Calculate x-direction offset
            x_offset = num_columns * (imageIdx-(num_imgs+1)/2);
            
            % Draw the lines in the appropriate image
            V1 = lines_shape(Lines(:,1),:);
            V2 = lines_shape(Lines(:,2),:);
            figure(figLines);
            subplot(num_eigs, 1, eigIdx);
            plot([V1(:,2) V2(:,2)]' + x_offset, [V1(:,1) V2(:,1)]', 'k-', 'LineWidth', line_width);
            hold on;
            axis equal;
        end % imageIdx
        
        % Display the resultant image
        figure(figShapes);
        subplot(num_eigs, 1, eigIdx);
        imshow(imgEig);
    end % eigIdx
    set(figShapes,'Visible','on');
    set(figLines,'Visible','on');

end % display_shape_modes

function [num_eigs, num_imgs, num_std, default_position, line_width] = process_options(options)

    if (isfield(options,'num_modes'))
        num_eigs = options.num_modes;
    else
        num_eigs = 3;
    end
    if (isfield(options,'num_imgs'))
        num_imgs = options.num_imgs;
    else
        num_imgs = 3;
    end
    if (isfield(options,'num_std'))
        num_std = options.num_std;
    else
        num_std = 3.0;
    end
    if (isfield(options,'default_position'))
        default_position = options.default_position;
    else
        default_position = [45 45 1000 750];
    end
    if (isfield(options,'line_width'))
        line_width = options.line_width;
    else
        line_width = 1;
    end

end % process_options
