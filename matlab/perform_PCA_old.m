% PERFORM_PCA Calculates a principal component analysis of the data in
% data_array, which contains examples of data in each column, and each row
% represents different examples of a single data value.  The second input,
% break_point, represents a "knee point" at which to cut off further
% eigenvectors and eigenvalues.  If it is not included, all values are
% returned.  The third input, pca_method, can be either 'cootes' (follows
% the method given in Section 3.3 of Cootes, et. al., "Active Shape
% Models--Their Training and Application," Computer Vision and Image
% Understanding, 1992) or 'hollerbach' (follows the method given in the
% course notes for CS 7320).  Default is 'cootes'.
% 
% Created by Thomas R. Grieve
% 3 April 2012
% University of Utah
% 

function [eigenvectors, eigenvalues, mean_data] = perform_PCA(data_array, break_point, pca_method)

    if (nargin() == 1)
        break_point = 1;
        pca_method = 'cootes';
    elseif (nargin() == 2);
        pca_method = 'cootes';
    elseif (nargin() ~= 3)
        error('Must have 1, 2 or 3 inputs!');
    end
    
    % Determine the size of the inputs
    [num_values, num_examples] = size(data_array);
    
    % Find the centroid of the data
    mean_data = mean(data_array, 2);
    
    % Switch based on desired PCA method
    if (strcmp(pca_method,'cootes'))
        % Find the covariance matrix
        pca_matrix = zeros(num_values);
        for exampleIdx = 1:num_examples
            % Calculate the deviation between the current example and mean
            dx = data_array(:,exampleIdx) - mean_data;
            
            % Add the contribution of current example to covariance matrix
            pca_matrix = pca_matrix + dx * dx';
        end % exampleIdx
        pca_matrix = pca_matrix / num_examples;
    elseif (strcmp(pca_method,'hollerbach'))
        % Re-center the data about the mean
        centered_data = zeros(num_values, num_examples);
        if (num_values < num_examples)
            for valueIdx = 1:num_values
                centered_data(valueIdx,:) = data_array(valueIdx,:) - mean_data(valueIdx);
            end % valueIdx
        else
            for exampleIdx = 1:num_examples
                centered_data(:,exampleIdx) = data_array(:,exampleIdx) - mean_data;
            end % exampleIdx
        end
        
        % Form the H matrix
        H1 = 0;
        pca_matrix = zeros(num_values);
        for exampleIdx = 1:num_examples
            % Sum of the inner product of each example
            H1 = H1 + centered_data(:,exampleIdx)' * centered_data(:,exampleIdx);
            
            % Sum of the outer product of each pixel
            pca_matrix = pca_matrix + centered_data(:,exampleIdx) * centered_data(:,exampleIdx)';
        end % exampleIdx
        pca_matrix = H1*eye(num_values) + pca_matrix;
    else
        error('Not a valid value for input ''pca_method'': %s', pca_method);
    end
    
    % Find the eigenvectors
    [eigenvectors,eigenvalues] = svd(pca_matrix,0);
    eigenvalues = diag(eigenvalues);
    
    if (break_point < 1)
        % Determine the number of eigenvalues to keep
        eigensum = cumsum(eigenvalues);
        num_eigs = find(eigensum > break_point*eigensum(num_values), 1);
        
        % Adjust the eigenvectors/eigenvalues to keep only these
        eigenvectors = eigenvectors(:,1:num_eigs);
        eigenvalues = eigenvalues(1:num_eigs);
    end

end % function