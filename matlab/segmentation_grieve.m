%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform image segmentation using Grieve's modification of Carson's method
% of Expectation Maximization.  This modification adds padding around the
% image and removes the texture information.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mask_image = segmentation_grieve(imgIn, options)

    % Process options
    [pad_image, max_pixels, verbose] = process_options(options);
    
    if (verbose)
        % Display the original image
        subplot(2,2,1);
        imshow(imgIn);
    end
    
    [orig_rows, orig_columns, orig_colors] = size(imgIn);
    if (pad_image)
        % Pad the image on all sides
        padding_size = 5;
        imgChanged = uint8(zeros(orig_rows + 2*padding_size, orig_columns + 2*padding_size, orig_colors));
        for colorIdx = 1:orig_colors
            top_padding = [imgIn(1,1,colorIdx)*uint8(ones(padding_size)) repmat(imgIn(1,:,colorIdx),padding_size,1) imgIn(1,orig_columns,colorIdx)*uint8(ones(padding_size))];
            left_padding = repmat(imgIn(:,1,colorIdx),1,padding_size);
            right_padding = repmat(imgIn(:,orig_columns,colorIdx),1,padding_size);
            bottom_padding = [imgIn(orig_rows,1,colorIdx)*uint8(ones(padding_size)) repmat(imgIn(orig_rows,:,colorIdx),padding_size,1) imgIn(orig_rows,orig_columns,colorIdx)*uint8(ones(padding_size))];
            imgChanged(:,:,colorIdx) = [top_padding;
                left_padding imgIn(:,:,colorIdx) right_padding;
                bottom_padding];
        end % colorIdx
        
        % Calculate the desired number of rows
        [changed_rows, changed_columns, changed_colors] = size(imgChanged);
        resize_factor = floor(sqrt(changed_rows * max_pixels / changed_columns));
    else
        % Calculate the desired number of rows
        imgChanged = imgIn;
        resize_factor = floor(sqrt(orig_rows * max_pixels / orig_columns));
    end
    
    % Resize the image
    resized_image = uint8(round(255*imresize(double(imgChanged)/255,[resize_factor NaN])));
    [num_rows, num_columns, num_colors] = size(resized_image);
    options.image_size = [num_rows num_columns];
    
    if (verbose)
        % Display the segmentation process in this subplot
        subplot(2,2,2);
    end
    
    % Process the resized image
    [resized_mask, resized_weight, valid_result] = single_step(resized_image, options);
    if (~valid_result)
        error('Result is not valid--stopping!');
    end
    
    if (verbose)
        % Display the segmentation estimate of the image
        subplot(2,2,2);
        imshow(resized_mask,[]);
    end
    
    % Reduce the mask image to a binary image
    mask_image = resized_mask - 1;

end % segmentation_grieve

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for and perform a single step of Carson's Expectation
% Maximization algorithm for Image Segmentation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mask_estimate, voting_weight, valid_result] = single_step(imgIn, options)

    % Normalize the image values
    imgNormalized = double(imgIn)/255;
    
    % Obtain the mask defining two regions
    %mask_estimate = define_image_mask(imgNormalized, 2);
    mask_estimate = (imgNormalized(:,:,1) > 0.1) + 1;
    
    % Define the number of independent variables to analyze
    %   Number of colors plus 2 for coordinates within the image
    [num_rows, num_columns, num_colors] = size(imgIn);
    num_variables = num_colors + 2;
    
    % Form the matrix containing all pixel data (color and position)
    num_pixels = num_rows*num_columns;
    pixel_matrix = zeros(num_pixels, num_variables);
    mask_vector = zeros(num_pixels, 1);
    
    % Process each pixel
    for pixelIdx = 1:num_pixels
        % Input the color information
        [rowIdx, colIdx] = ind2sub([num_rows, num_columns],pixelIdx);
        pixel_matrix(pixelIdx, 1:num_colors) = imgNormalized(rowIdx, colIdx, :);
        
        % Input the normalized position information
        pixel_matrix(pixelIdx, (num_colors+1):end) = [rowIdx/num_rows colIdx/num_columns];
        
        % Store the mask vector value
        mask_vector(pixelIdx) = mask_estimate(rowIdx, colIdx);
    end % pixelIdx
    
    % Perform Expectation Maximization
    [mask_vector, mask_weights, valid_result] = expectation_maximization(pixel_matrix, mask_vector, options);
    
    % Reshape the vectors to form images
    voting_weight = zeros(num_rows, num_columns);
    for pixelIdx = 1:num_pixels
        % Calculate the (row,column) indices of this pixel
        [rowIdx, colIdx] = ind2sub([num_rows, num_columns],pixelIdx);
        
        % Assign the region and weight information
        mask_estimate(rowIdx, colIdx) = mask_vector(pixelIdx);
        voting_weight(rowIdx, colIdx) = mask_weights(pixelIdx);
    end

end % single_step

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the option values used in these functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pad_image, max_pixels, verbose] = process_options(options)

    if (isfield(options,'pad_image'))
        pad_image = options.pad_image;
    else
        pad_image = true;
    end 
    if (isfield(options,'max_pixels'))
        max_pixels = options.max_pixels;
    else
        max_pixels = 3000;
    end
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end 

end % process_options
