% NORMALIZE_GRAY_LEVELS Normalizes the values in an array
% (normalized_values) so that each example (i.e., column) has a mean of 0
% and a variance of 1.  The other two outputs are the standard deviation of
% each column (alpha) and the mean of each column (beta), which can be used
% to reconstruct the original data, if desired.
% 
%   gray_normalized = (gray_original - beta) / alpha
% 
% Created by Thomas R. Grieve
% 5 April 2012
% University of Utah
% 

function [normalized_values, alpha, beta] = normalize_gray_levels(gray_values)

    % Determine size of input
	num_examples = size(gray_values, 2);
    err_tol = 0.01;
    max_iter = 10;
    
    % Initialize outputs
    alpha = zeros(1,num_examples);
    beta = zeros(1,num_examples);
    
    % Calculate the mean gray vector and standardize it
    old_mean = mean(gray_values,2);
    old_mean = standardize_vector(old_mean);
    
    % Normalize the gray vectors
    normalized_values = normalize_vectors(gray_values, old_mean);
    
    % Create iteration parameters
    iter = 0;
    pct_err = sqrt(sum(old_mean.^2));
    
    % Repeat
    while ((pct_err > err_tol) && (iter < max_iter))
        % Increment iteration counter
        iter = iter + 1;
        
        % Calculate the mean gray vector from the normalized vectors and
        % standardize it
        new_mean = mean(normalized_values,2);
        new_mean = standardize_vector(new_mean);
        
        % Normalize the gray vectors
        [normalized_new, alpha, beta] = normalize_vectors(normalized_values, new_mean);
        
        % Calculate the iteration error
        pct_err = max(abs((new_mean - old_mean) ./ old_mean));
        normalized_values = normalized_new;
        old_mean = new_mean;
    end

end % normalize_gray_levels

function [gray_normalized, alpha, beta] = normalize_vectors(gray_vectors, gray_mean)

    % Preallocate outputs
    [num_pixels, num_images] = size(gray_vectors);
    if (length(gray_mean) ~= num_pixels)
        error('Mean vector is not the correct size!');
    end
    gray_normalized = zeros(num_pixels, num_images);
    alpha = zeros(1,num_images);
    beta = zeros(1,num_images);
    
    % Normalize all gray vectors to the mean
    for imageIdx = 1:num_images
        % Extract the current image
        gray_current = gray_vectors(:, imageIdx);
        
        % Calculate the normalization parameters
        alpha(imageIdx) = gray_current' * gray_mean;
        beta(imageIdx) = mean(gray_current);
        
        % Normalize the gray-level vector
        gray_normalized(:,imageIdx) = (gray_current - beta(imageIdx)) / alpha(imageIdx);
    end % imageIdx

end % normalize_vectors

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize a single vector, reducing its standard deviation to 1 and its
% mean to 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function standardized_vector = standardize_vector(input_vector)

    % Calculate the normalization parameters
    alpha = std(input_vector);
    beta = mean(input_vector);
    
    % Standardize the vector
    standardized_vector = (input_vector - beta) / alpha;

end % standardize_vector
