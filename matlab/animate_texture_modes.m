function figTexture = animate_texture_modes(AppearanceData, options)

    % Unpack the options
    if (nargin() == 1)
        options = [];
    elseif (nargin() ~= 2)
        error('Must have 1 or 2 inputs!');
    end
    [num_std, num_frames, eigIdx, default_position] = process_options(options);
    mask_image = AppearanceData.ObjectPixels;
    std_vals = sqrt(AppearanceData.Evalues);
    
    % Initialize the figure
    figTexture = figure;
    set(figTexture,'Position',default_position);
    set(figTexture,'Name','Texture Variation');
    
    % Extract the default image
    mean_gray = AppearanceData.g_mean;
    selected_eig = std_vals(eigIdx) * AppearanceData.Evectors(:, eigIdx);
    
    % Process each frame
    for frameIdx = [1:num_frames (num_frames-1):-1:1]
        % Calculate the amount through the eigenvector
        current_std = (2*num_std / (num_frames-1)) * (frameIdx - num_frames) + num_std;
        
        % Calculate the current weighted Texture eigenvector
        current_eig = current_std * selected_eig;
        
        % Denormalize the texture
        current_texture = denormalize_gray_levels(mean_gray + current_eig);
        
        % Form the current image
        imgCurrent = convert_vector_to_image(current_texture, mask_image, options);
        
        % Display the resultant image
        subplot(1,1,1);
        imshow(imgCurrent);
        drawnow();
    end % imageIdx

end % display_shape_modes

function [num_std, num_frames, eigIdx, default_position] = process_options(options)

    if (isfield(options,'num_std'))
        num_std = options.num_std;
    else
        num_std = 3;
    end
    if (isfield(options,'num_frames'))
        num_frames = options.num_frames;
    else
        num_frames = 20;
    end
    if (isfield(options,'mode'))
        eigIdx = options.mode;
    else
        eigIdx = 1;
    end
    if (isfield(options,'default_position'))
        default_position = options.default_position;
    else
        default_position = [45 45 1000 750];
    end

end % process_options
