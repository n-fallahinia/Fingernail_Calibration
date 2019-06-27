function custom_transform = piecewise_linear_transform(original_transform, input_points, desired_points, triangles, debug_mode)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine size of inputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (nargin() == 4)
        debug_mode = false;
    elseif (nargin() ~= 5)
        error('Must have 4 or 5 inputs!');
    end
    [num_points, num_dims_in] = size(input_points);
    [num_des, num_dims_out] = size(desired_points);
    if (num_des ~= num_points)
        error('Input and desired points do not have the same number of points!');
    end
    if (num_dims_in ~= num_dims_out)
        error('Input and desired points do not have the same number of dimensions!');
    end
    num_triangles = size(triangles, 1);
    err_tol = 1e-5;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fill out the triangles graph
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Generate the indices representing the triangles
    triangle_indices = repmat(1:num_triangles, 1, 3)';
    
    % Generate the values required
    graph_values = ones(size(triangle_indices));
    
    % Form the sparse matrix
    triangle_graph = sparse(triangle_indices, triangles, graph_values, num_triangles, num_points);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate the convex hull of the desired points
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Array marking the vertices that lie on the Convex Hull
    [convex_hull_vertices, on_hull] = find_outer_hull(desired_points(:,1), desired_points(:,2), triangles, debug_mode);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Form the "Piecewise Linear" transform for each triangle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Preallocate the matrix
    piecewise_linear_tdata = zeros(num_dims_in+1,num_dims_out,num_triangles);
    
    % Process each triangle
    for triangleIdx = 1:num_triangles
        % Extract the current input and desired triangles
        tri_index = triangles(triangleIdx, :);
        tri_input = input_points(tri_index, :);
        tri_desired = desired_points(tri_index, :);
        
        % Calculate transformation matrix using Least-Squares Regression
        tform = [tri_desired ones(3,1)] \ tri_input;
        
        % Debugging (to check that the transformation is correct)
        transformed_input = tri_desired * tform(1:2,:) + repmat(tform(3,:), 3, 1);
        err = transformed_input - tri_input;
        if (max(abs(err(:))) > err_tol)
            fprintf('Error is too large!\n');
            keyboard;
        end
        
        % Store the transformation matrix
        piecewise_linear_tdata(:,:,triangleIdx) = tform;
    end % triangleIdx
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Form output structure
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Form transformation data structure
    transform_data.Triangles = triangles;
    transform_data.ControlPoints = desired_points;
    transform_data.OnHull = on_hull;
    transform_data.ConvexHullVertices = convex_hull_vertices;
    transform_data.TriangleGraph = triangle_graph;
    transform_data.PiecewiseLinearTData = piecewise_linear_tdata;
    
    % Output structure
    custom_transform = original_transform;
    custom_transform.tdata = transform_data;

end % piecewise_linear_transform

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the outer hull
% This is done by looking for lines that only exist in one triangle.  If a
% line is only in one triangle, its
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [convex_hull_indices, on_hull] = find_outer_hull(x_pts, y_pts, triangles, debug_mode)

    % Preallocate outputs
    num_triangles = size(triangles,1);
    num_points = length(x_pts);
    on_hull = false(num_points, 1);
    convex_hull_indices = [];
    
    % Allocate a connecting-line matrix
    lines = uint8(zeros(num_points));
    
    if (debug_mode)
        fig_lines = figure();
        set(fig_lines,'Position',[45 45 1000 750]);
        triplot(triangles, x_pts, y_pts, 'k-');
        hold on;
        axis equal;
        axis ij;
    end
    
    if (num_points < num_triangles)
        % Process each point
        processed = false(num_triangles, 3);
        for pointIdx = 1:num_points
            % Find triangles containing this point that have not been
            % processed
            [all_triangles, point_loc] = find((triangles == pointIdx) & (~processed));
            num_found = length(all_triangles);
            if (num_found == 0)
                continue;
            end
            
            if (debug_mode)
                plot(x_pts(pointIdx),y_pts(pointIdx),'ro');
            end
            
            % Process all triangles containing this point
            for foundIdx = 1:num_found
                % Mark this triangle as processed
                processed(all_triangles(foundIdx),:) = true;
                current_tri = sort(triangles(all_triangles(foundIdx),:));
                
                if (debug_mode)
                    plot(x_pts(current_tri([1:end 1])),y_pts(current_tri([1:end 1])),'b-');
                end
                
                % Increment the counter for each pair of lines
                lines(current_tri(1),current_tri(2)) = lines(current_tri(1),current_tri(2)) + 1;
                lines(current_tri(2),current_tri(3)) = lines(current_tri(2),current_tri(3)) + 1;
                lines(current_tri(1),current_tri(3)) = lines(current_tri(1),current_tri(3)) + 1;
                
                if (debug_mode)
                    if (lines(current_tri(1),current_tri(2)) > 1)
                        plot(x_pts(current_tri(1:2)),y_pts(current_tri(1:2)),'r-');
                    end
                    if (lines(current_tri(2),current_tri(3)) > 1)
                        plot(x_pts(current_tri(2:3)),y_pts(current_tri(2:3)),'r-');
                    end
                    if (lines(current_tri(1),current_tri(3)) > 1)
                        plot(x_pts(current_tri([1 3])),y_pts(current_tri([1 3])),'r-');
                    end
                end
            end % foundIdx
            
            if (debug_mode)
                plot(x_pts(pointIdx),y_pts(pointIdx),'ko');
            end
        end % pointIdx
    else
        % Process each triangle
        for triangleIdx = 1:num_triangles
            current_tri = sort(triangles(triangleIdx,:));
            
            % Increment the counter for each pair of lines
            lines(current_tri(1),current_tri(2)) = lines(current_tri(1),current_tri(2)) + 1;
            lines(current_tri(2),current_tri(3)) = lines(current_tri(2),current_tri(3)) + 1;
            lines(current_tri(1),current_tri(3)) = lines(current_tri(1),current_tri(3)) + 1;
        end % triangleIdx
    end
    
    % Find point indices pertaining to lines only used in one triangle
    [pts1, pts2] = find(lines == 1);
    
    if (debug_mode)
        fig_debug = figure();
        set(fig_debug,'Position',[45 45 1000 750]);
        triplot(triangles, x_pts, y_pts, 'k-');
        hold on;
        temp = unique([pts1 pts2]);
        plot(x_pts(temp),y_pts(temp),'ro');
        axis equal;
        axis ij;
    end
    
    % Sort the points into a contour
    startIdx = min(pts1);
    idx = find(startIdx == pts1,1);
    convex_hull_indices = [convex_hull_indices; pts1(idx); pts2(idx)];
    if (debug_mode)
        plot(x_pts([pts1(idx) pts2(idx)]), y_pts([pts1(idx) pts2(idx)]), 'bo-');
    end
    pts1(idx) = [];
    pts2(idx) = [];
    done = false;
    while ((~done) && (~isempty(pts1)))
        % Alternate termination condition
        if (convex_hull_indices(end) == convex_hull_indices(1))
            done = true;
            continue;
        end
        
        % Find the next point
        [id1, id2] = find(convex_hull_indices(end) == [pts1 pts2]);
        if (isempty(id1))
            error('No matching points found!');
        end
        
        % If more than one found, determine which to use
        if (length(id1) > 1)
            % Find minimum of corresponding index
            min_corr_index = Inf;
            min_id2 = 0;
            for ptIdx = 1:length(id1)
                if (id2(ptIdx) == 1)
                    % Check the value in pts2
                    if (pts2(id1(ptIdx)) < min_corr_index)
                        min_id1 = id1(ptIdx);
                        min_id2 = id2(ptIdx);
                        min_corr_index = pts2(min_id1);
                    end
                else
                    % Check the value in pts1
                    if (pts1(id1(ptIdx)) < min_corr_index)
                        min_id1 = id1(ptIdx);
                        min_id2 = id2(ptIdx);
                        min_corr_index = pts1(min_id1);
                    end
                end
            end % ptIdx
            id1 = min_id1;
            id2 = min_id2;
        end
        
        % Add the "found" points to the contour
        if (id2 == 1)
            convex_hull_indices = [convex_hull_indices; pts2(id1)];
        else
            convex_hull_indices = [convex_hull_indices; pts1(id1)];
        end
        if (debug_mode)
            plot(x_pts([pts1(id1) pts2(id1)]), y_pts([pts1(id1) pts2(id1)]), 'bo-');
        end
        
        % Remove the "found" points from the list
        pts1(id1) = [];
        pts2(id1) = [];
    end
    
    % Mark the appropriate points as being on the hull
    on_hull(convex_hull_indices) = true;

end % find_outer_hull
