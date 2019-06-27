% ASSEMBLE_MODEL_DATA Assemble a list of aligned files into a pixel_matrix
% for use in creating a calibration model.  The list should be a structure
% that includes the following fields:
% 
%   original_image - The filename of the original image file
%   force          - The force associated with the file
%   aligned_image  - The aligned image file
% 
% The second input, original_mask, is the mask image (logical) that shows
% which pixels in the aligned image are valid.  The third input, options,
% is an optional structure containing the following fields:
% 
%   
% 
% Written by Thomas R. Grieve
% 19 April 2012
% University of Utah
% 

function [pixel_matrix, force_matrix, shape_matrix, gray_matrix, model_matrix, mask_image] = assemble_model_data(file_list, original_mask, options)

    % Verify inputs
    if (nargin() == 2)
        [debug_mode, verbose, approx_size, default_position, eliminate] = process_options([]);
    elseif (nargin() == 3)
        [debug_mode, verbose, approx_size, default_position, eliminate] = process_options(options);
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
    
    % Determine number of each type of parameter
    model_matrix = textread(file_list(1).model_file);
    num_model = length(model_matrix);
    shape_matrix = textread(file_list(1).shape_file);
    num_shapes = length(shape_matrix);
    gray_matrix = textread(file_list(1).gray_file);
    num_gray = length(gray_matrix);
    
    % Preallocate the outputs
    pixel_matrix = zeros(num_files, num_pixels);
    force_matrix = zeros(num_files, 3);
    shape_matrix = zeros(num_files, num_shapes);
    gray_matrix = zeros(num_files, num_gray);
    model_matrix = zeros(num_files, num_model);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Form the model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for testIdx = num_files:-1:1
        % Load the aligned image
        aligned_file = file_list(testIdx).aligned_image;
        if (eliminate(testIdx))
            % Print a message if the aligned file does not exist and it is
            % already marked as "to be eliminated"
            if (debug_mode)
                fprintf('\tAAM-registered file does not exist! %s\n', aligned_file);
            end
            continue;
        elseif (~exist(aligned_file,'file'))
            % Throw an error if the aligned file does not exist and it is
            % not already marked as "to be eliminated"
            error('AAM-registered file does not exist! %s\n', aligned_file);
        end
        load(aligned_file);
        
        % Print a user-friendly message
        if ((verbose) && (mod(testIdx,100) == 0))
            fprintf('\tProcessing Image %04d\n', testIdx);
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
        
        % Read the parameters from the files
        if (exist(file_list(testIdx).model_file,'file'))
            model_matrix(testIdx,:) = textread(file_list(testIdx).model_file);
        end
        if (exist(file_list(testIdx).shape_file,'file'))
            shape_matrix(testIdx,:) = textread(file_list(testIdx).shape_file);
        end
        if (exist(file_list(testIdx).gray_file,'file'))
            gray_matrix(testIdx,:) = textread(file_list(testIdx).gray_file);
        end
        
        % Extract the force
        force_matrix(testIdx,:) = file_list(testIdx).force(1:3);
        
        % Rearrange active pixels into a vector
        pixel_matrix(testIdx,:) = imgMasked(mask_image);
    end % testIdx

end % assemble_model_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the input options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [debug_mode, verbose, approx_size, default_position, eliminate] = process_options(options)

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
        approx_size = [10 10];
    end
    if (isfield(options,'default_position'))
        default_position = options.default_position;
    else
        default_position = [46 46 1000 750];
    end
    if (isfield(options,'eliminate'))
        eliminate = options.eliminate;
    else
        eliminate = false;
    end

end % process_options