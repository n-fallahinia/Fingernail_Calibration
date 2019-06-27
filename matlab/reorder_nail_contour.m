%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Re-create nail contour using distal end of nail as a starting point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [new_nail, nail_length, nail_centroid] = reorder_nail_contour(nail_points, finger_angle, num_nail, debug_mode)

    % Preallocate output
    nail_size = size(nail_points, 1);
    temp_nail = zeros(nail_size+2, 2);
    if (debug_mode)
        % Length for plotting the "finger direction" vector
        vector_length = 0.25*(max(nail_points(:)) - min(nail_points(:)));
    end
    
    % Find the centroid of the nail
    nail_centroid = mean(nail_points);
    
    % Find the crossing points
    crossing_line.point = nail_centroid;
    crossing_line.angle = finger_angle;
    [crossing_points, crossing_index] = find_crossing_points(nail_points, crossing_line);
    
    % Put the interpolated points as the first and last points in the new
    % contour
    temp_nail(1,:) = crossing_points(1,:);
    temp_nail(end,:) = crossing_points(1,:);
    
    % Add the old points to the contour differently, depending on which of
    % the old points surround the interpolated point
    if (crossing_index(1,1) == 1)
        % Add the old contour in the same order as before, since the
        % interpolated point is between the last and the first points
        temp_nail(2:end-1,:) = nail_points;
    else
        % Add the old contour, starting with the point after the
        % interpolated point, moving to the end, then from the first point
        % and to the point just before the interpolated point.
        temp_nail(2:end-1,:) = nail_points([crossing_index(1,1):nail_size 1:crossing_index(1,2)],:);
    end
    
    % Smooth the contour and remove the duplicate final point
    [x_nail, y_nail] = smooth_contour(temp_nail(:,1), temp_nail(:,2), num_nail+1);
    new_nail = [x_nail(1:end-1) y_nail(1:end-1)];
    
    % Calculate the length of the nail, along the finger direction vector
    nail_vector = crossing_points(1,:) - crossing_points(2,:);
    nail_length = norm(nail_vector);
    
    % Plot, if desired
    if (debug_mode)
        plot(nail_points(crossing_index(1,:),1),nail_points(crossing_index(1,:),2),'go-','MarkerSize',20,'LineWidth',3);
        plot(nail_centroid(1),nail_centroid(2),'bo','MarkerSize',10,'LineWidth',2);
        plot(nail_centroid(1) + vector_length*cos(finger_angle)*[-1 1], nail_centroid(2) + vector_length*sin(finger_angle)*[-1 1], 'b-','LineWidth',3);
        plot(new_nail(:,1),new_nail(:,2),'ro','MarkerSize',10,'LineWidth',2);
    end

end % reorder_nail_contour
