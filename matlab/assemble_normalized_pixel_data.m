% ASSEMBLE_PIXEL_DATA Assemble a list of aligned files into a pixel_matrix
% for use in creating a calibration model.  The list should be a structure
% with the following fields:
% 
%   original_image - The filename of the original image file
%   force          - The force associated with the file
%   aligned_image  - The aligned image file
% 
% Written by Thomas R. Grieve
% 19 April 2012
% University of Utah
% 

function [pixel_matrix, mask_image] = assemble_normalized_pixel_data(file_list, original_mask, options)

    % Verify inputs
    if (nargin() == 2)
        [debug_mode, verbose, approx_size, eliminate, default_position] = process_options([],size(file_list,1));
    elseif (nargin() == 3)
        [debug_mode, verbose, approx_size, eliminate, default_position] = process_options(options,size(file_list,1));
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Determine size of input
    num_files = length(file_list);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Resize the mask image and determine the active pixels for the model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [num_rows, num_columns] = size(original_mask);
    if (isnan(approx_size))
        % Do not resize the image at all
        mask_image = (original_mask > 0);
    else
        if (num_rows*approx_size(2)/approx_size(1) >= num_columns)
            % Resize according to the desired number of columns
            resize_factor = [NaN approx_size(2)];
        else
            % Resize according to the desired number of rows
            resize_factor = [approx_size(1) NaN];
        end
        mask_image = imresize(original_mask, resize_factor);
    end
    dbl_mask = double(mask_image);
    num_pixels = sum(mask_image(:));
    
    % Preallocate the outputs
    pixel_matrix = zeros(num_files, num_pixels);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Form the model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for testIdx = num_files:-1:1
        % Skip files that have already been eliminated
        if (eliminate(testIdx))
            continue;
        end
        
        % Load the aligned image
        aligned_file = file_list(testIdx).aligned_image;
        if (~exist(aligned_file,'file'))
            % Skip if the aligned file does not exist
            error('****Aligned file does not exist! %s\n', aligned_file);
        end
        load(aligned_file);
        
        % Print a user-friendly message
        if (mod(testIdx,100) == 0)
            if (verbose)
                fprintf('\t****Reading Aligned File %03d\n', testIdx);
            else
                fprintf('.');
            end
        end
        
        % Convert aligned image to double, if needed
        if (~isfloat(imgAligned))
            %imgAligned = mean(double(imgAligned), 3) / 255;
            imgAligned = double(imgAligned(:,:,2)) / 255;
        end
        
        % Remove pixels outside image mask, if desired
        if (isnan(approx_size))
            % Aligned image does not need to be resized before masking
            imgMasked = imgAligned .* dbl_mask;
        else
            % Aligned image should be resized before masking
            imgMasked = (imresize(imgAligned, resize_factor) .* dbl_mask);
        end
        
        % Display the image, if appropriate
        if (debug_mode)
            figure(1);
            set(1,'Position',default_position);
            subplot(1,2,1);
            imshow(imgAligned);
            title(sprintf('Image %d', testIdx));
            subplot(1,2,2);
            imshow(imgMasked);
            title('Masked Image');
            drawnow();
        end
        
        % Rearrange active pixels into a vector
        pixel_matrix(testIdx,:) = imgMasked(mask_image);
    end % testIdx
    
    % Normalize the pixel matrix
    pixel_matrix = normalize_gray_levels(pixel_matrix);

end % assemble_pixel_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the input options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [debug_mode, verbose, approx_size, eliminate, default_position] = process_options(options, num_files)

    if (isfield(options,'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end
    if (isfield(options,'approx_size'))
        approx_size = options.approx_size;
    else
        approx_size = [30 30];
    end
    if (isfield(options,'eliminate'))
        eliminate = options.eliminate;
    else
        eliminate = false(num_files,1);
    end
    if (isfield(options,'default_position'))
        default_position = options.default_position;
    else
        default_position = [46 46 1188 854];
    end

end % process_options