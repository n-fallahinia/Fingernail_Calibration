function figAppearance = display_gray_modes(TextureData, options)

    % Unpack the options
    if (nargin() == 1)
        [num_eigs, num_imgs, num_std, default_position] = process_options([]);
    elseif (nargin() == 2)
        [num_eigs, num_imgs, num_std, default_position] = process_options(options);
    else
        error('Must have 1 or 2 inputs!');
    end
    
    % Extract various parameters
    mask_image = TextureData.ObjectPixels;
    [num_rows, num_columns] = size(mask_image);
    num_colors = length(TextureData.g_mean) / sum(mask_image(:));
    std_vals = sqrt(TextureData.Evalues);
    
    fig_rows = ceil(sqrt(num_eigs));
    fig_cols = ceil(num_eigs / fig_rows);
    
    % Initialize the figure
    figAppearance = figure;
    set(figAppearance,'Position', default_position);
    set(figAppearance,'Name','Texture Variation');
    set(figAppearance,'Visible','off');
    
    % Extract the default image
    mean_gray = TextureData.g_mean;
    
    % Process each mode
    for eigIdx = 1:num_eigs
        % Initialize the mode image
        imgEig = zeros(num_rows, num_imgs*num_columns, num_colors);
        
        % Process each image
        for imageIdx = 1:num_imgs
            % Calculate the current weighted Appearance eigenvector
            current_std = (2*num_std / (num_imgs-1)) * (imageIdx - num_imgs) + num_std;
            current_eig = current_std * std_vals(eigIdx) * TextureData.Evectors(:, eigIdx);
            
            % Appply this eigenvector the base image
            current_texture = denormalize_gray_levels(mean_gray + current_eig);
            
            % Calculate the starting index of the current image
            startIdx = (imageIdx-1)*num_columns;
            
            % Form the current image
            imgCurrent = convert_vector_to_image(current_texture, mask_image, options);
            
            % Insert the current image into the mode image
            imgEig(:, startIdx+(1:num_columns), :) = imgCurrent;
        end % imageIdx

        % Display the resultant image
        subplot(fig_rows, fig_cols, eigIdx);
        imshow(imgEig);
    end % eigIdx
    set(figAppearance,'Visible','on');

end % display_gray_modes

function [num_eigs, num_imgs, num_std, default_position] = process_options(options)

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

end % process_options
