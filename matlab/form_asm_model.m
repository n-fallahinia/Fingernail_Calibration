% FORM_ASM_MODEL Creates an Active Shape Model structure, as detailed in
% Section 3.2 of Cootes, et. al., "Active Shape Models--Their Training and
% Application," Computer Vision and Image Understanding, 1992.
% Specifically, this implements Sections 3.2-3.3 of that paper.  The
% current_images input contains a 2*num_points-by-num_images array, with
% the point coordinates for image 1 (x1,y1), (x2,y2), etc., listed in the
% first column as follows:
% 
%   [x1 x2 x3 ... xn y1 y2 y3 ... yn]'
% 
% The second input is a structure of options, that may contain fields such
% as 'err_tol', 'max_iter', 'debug_mode' and 'break_point'.  The first
% three are parameters for the alignment of the data points, while the
% fourth is the "knee point" at which to eliminate further eigenvalues from
% consideration.
% 
% Created by Thomas R. Grieve
% 3 April 2012
% University of Utah
% 

function [ShapeData, TrainingData] = form_asm_model(TrainingData, options)

    % Verify inputs
    if (nargin() == 1)
        % Extract options
        [err_tol, max_iter, debug_mode, break_point, image_scale] = process_options([]);
    elseif (nargin() == 2)
        % Extract options
        [err_tol, max_iter, debug_mode, break_point, image_scale] = process_options(options);
    else
        error('Must have 1 or 2 inputs!');
    end
    
    % Rearrange the points in the TrainingData into a point array
    num_images = length(TrainingData);
    num_points = size(TrainingData(1).Vertices,1);
    current_images = zeros(2*num_points, num_images);
    for imageIdx = 1:num_images
        current_images(:,imageIdx) = [TrainingData(imageIdx).Vertices(:,1); TrainingData(imageIdx).Vertices(:,2)];
    end % imageIdx
    current_images = current_images / image_scale;
    
    % Align images
    [aligned_images, weights, alignment_transform] = align_training_set(current_images, err_tol, max_iter, debug_mode);
    for imageIdx = 1:num_images
        TrainingData(imageIdx).transform = alignment_transform(imageIdx);
        TrainingData(imageIdx).aligned_vertices = [aligned_images(1:num_points,imageIdx) aligned_images((num_points+1):end,imageIdx)];
    end % imageIdx
    
    % Perform PCA on aligned images
    [eigenvectors, eigenvalues, mean_shape] = perform_PCA(aligned_images, break_point);
    num_eigs = length(eigenvalues);
    
    % Plot and display various types of data
    if (debug_mode)
        % Plot the original data
        num_images = size(current_images, 2);
        figure(1);
        set(1,'Name','Original Data');
        fig_rows = ceil(sqrt(num_images));
        fig_cols = ceil(num_images / fig_rows);
        for imageIdx = 1:num_images
            subplot(fig_rows, fig_cols, imageIdx);
            plot(mean_shape(1:num_points),mean_shape(num_points+1:end),'k.-');
            hold on;
            plot(current_images(1:num_points,imageIdx),current_images(num_points+1:end,imageIdx),'ro-');
            hold off;
            axis equal;
        end % imageIdx
        
        % Plot the aligned data
        figure(2);
        set(2,'Name','Aligned Data');
        for imageIdx = 1:num_images
            subplot(fig_rows, fig_cols, imageIdx);
            plot(mean_shape(1:num_points),mean_shape(num_points+1:end),'k.-');
            hold on;
            plot(aligned_images(1:num_points,imageIdx),aligned_images(num_points+1:end,imageIdx),'ro-');
            hold off;
            axis equal;
        end % imageIdx
        
        % Calculate the parameters corresponding to each example
        parameters = zeros(num_eigs, num_images);
        for imageIdx = 1:num_images
            parameters(:,imageIdx) = eigenvectors' * (aligned_images(:,imageIdx) - mean_shape);
        end % imageIdx
        
        % Plot each set of pairs of parameters
        pairs = nchoosek(1:num_eigs,2);
        num_pairs = size(pairs,1);
        fig_row = ceil(sqrt(num_pairs));
        fig_col = ceil(num_pairs / fig_row);
        figure(3);
        set(3,'Name','Parameter Pair Variation in Training Set');
        for pairIdx = 1:num_pairs
            subplot(fig_row, fig_col, pairIdx);
            plot(parameters(pairs(pairIdx,1),:),parameters(pairs(pairIdx,2),:),'k.');
            xlabel(sprintf('P%d', pairs(pairIdx,1)));
            ylabel(sprintf('P%d', pairs(pairIdx,2)));
            axis equal;
        end % pairIdx
        
        % Plot the modes of variation
        figure(4);
        set(4,'Name','Eigenvector Variation');
        fig_row = ceil(sqrt(num_eigs));
        fig_col = ceil(num_eigs / fig_row);
        for eigIdx = 1:num_eigs
            subplot(fig_row, fig_col, eigIdx);
            plot(mean_shape(1:num_points),mean_shape(num_points+1:end),'k.-');
            hold on;
            for numIdx = -3:1.5:3
                current_shape = mean_shape + eigenvectors(:,eigIdx)*numIdx*sqrt(eigenvalues(eigIdx));
                plot(current_shape(1:num_points),current_shape(num_points+1:end),'ro-');
            end % numIdx
            hold off;
            axis equal;
        end % eigIdx
    end
    
    % Form the model in the same format used in the active_models_v7 method
    ShapeData.Evectors = eigenvectors;
    ShapeData.Evalues = eigenvalues;
    ShapeData.x_mean = mean_shape;
    ShapeData.x = aligned_images;
    ShapeData.Lines = TrainingData(1).Lines;
    
    % Make the texture a square that is as large as maximum displacement
    mean_shape = [mean_shape(1:num_points) mean_shape(num_points+1:end)] * image_scale;
    TextureSize = max(ceil(max(mean_shape) - min(mean_shape) + 1));
    ShapeData.TextureSize = [TextureSize TextureSize];
    
    % Generate the triangles arrayTextureSize
    ShapeData.Tri = delaunay(mean_shape(1:num_points), mean_shape(num_points+1:end));
    
    % Store the weight matrix used for shape alignment
    ShapeData.Weights = weights;

end % form_asm_model

function [err_tol, max_iter, debug_mode, break_point, image_scale] = process_options(options)

    % Extract options
    if (isfield(options,'err_tol'))
        err_tol = options.err_tol;
    else
        err_tol = 0.01;
    end
    if (isfield(options,'max_iter'))
        max_iter = options.max_iter;
    else
        max_iter = 10;
    end
    if (isfield(options,'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end
    if (isfield(options,'break_point'))
        break_point = options.break_point;
    else
        break_point = 0.999;
    end
    if (isfield(options,'image_scale'))
        image_scale = options.image_scale;
    else
        image_scale = 1024;
    end

end % process_options
