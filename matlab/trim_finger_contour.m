%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the end points of the finger contour
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [finger_points, length_missing] = trim_finger_contour(old_finger, nail_centroid, finger_angle, finger_length, num_finger, debug_mode, plot_simple)

    % Handle optional inputs
    if (nargin() == 5)
        debug_mode = false;
        plot_simple = true;
    elseif (nargin() == 6)
        plot_simple = true;
    elseif (nargin() ~= 7)
        error('Must have 5, 6 or 7 inputs!');
    end
    
    % Form the line structure through the nail centroid and parallel to the
    % finger direction vector
    finger_centroid = mean(old_finger);
    along_line.point = finger_centroid;
    along_line.angle = finger_angle;
    
    % Find the point(s) where the finger contour crosses this line
    [along_points, along_index] = find_crossing_points(old_finger, along_line);
    
    % Determine whether one of the points crosses the proximal end of the
    % finger
    [rowIdx, colIdx] = find(along_index == 1);
    if (isempty(rowIdx))
        error('Finger direction vector crossed finger contour twice!\nSomething is seriously wrong!');
    else
        % Eliminate row containing the proximal end of the finger
        along_points(rowIdx,:) = [];
        along_index(rowIdx,:) = [];
    end
    
    % Form the line that will create the new bottom of the finger contour
    finger_direction = [cos(finger_angle) sin(finger_angle)];
    bottom_line.point = along_points - finger_length*finger_direction;
    if (finger_angle < 3*pi/2)
        bottom_line.angle = finger_angle + pi/2;
    else
        bottom_line.angle = finger_angle - 3*pi/2;
    end
    
    % Find the points where the finger contour crosses this line
    [bottom_points, bottom_index, missing_distance] = find_crossing_points(old_finger, bottom_line, true);
    if (~isempty(missing_distance))
        [rowIdx, colIdx] = find(bottom_index == 0);
        if (length(rowIdx) == 2)
            fprintf('\tPoints missing along both sides!\n');
        elseif (rowIdx == 1)
            fprintf('\tPoints missing along right side of finger!\n');
        else
            fprintf('\tPoints missing along left side of finger!\n');
        end
    end
    
    % Assemble the new finger points between the new bottom points
    new_finger = [bottom_points(1,:); old_finger(bottom_index(1,1):bottom_index(2,2),:); bottom_points(2,:)];
    
    % Smooth this contour
    [x_finger, y_finger] = smooth_contour(new_finger(:,1), new_finger(:,2), num_finger);
    
    % Assemble the smoothed contour
    finger_points = [x_finger y_finger];
    length_missing = 0;
    
    % Mark the interpolated points along the actual contour
    if (debug_mode)
        if (plot_simple)
            % Plot the vector perpendicular to the finger vector, through
            % the point at the bottom of the finger
            plot([bottom_points(1,1) bottom_points(2,1)], [bottom_points(1,2) bottom_points(2,2)], 'go-','MarkerSize',20,'LineWidth',2);
            
            % Plot the finger direction line through the nail centroid
            plot([along_points(1) bottom_line.point(1)], [along_points(2) bottom_line.point(2)], 'b-','LineWidth',2);
            
            % Plot the finger centroid
            plot(finger_centroid(1), finger_centroid(2), 'bo','MarkerSize',20,'LineWidth',2);
        else
            % Plot the finger vector extending from the nail centroid
            plot(along_line.point(1),along_line.point(2),'bo','MarkerSize',10,'LineWidth',2);
            
            % Plot the finger vector, extending backward from the
            % most-distal finger point, using the finger length
            plot(along_points(1,1),along_points(1,2),'bo','MarkerSize',10,'LineWidth',2);
            plot(along_points(1,1) - finger_length*[0 cos(finger_angle)], along_points(1,2) - finger_length*[0 sin(finger_angle)], 'b-','LineWidth',3);
            
            % Plot the pair of original points that brackets the
            % most-distal point 
            plot(old_finger(along_index(1,:),1),old_finger(along_index(1,:),2),'go-','MarkerSize',20,'LineWidth',2);
            
            % Plot the vector perpendicular to the finger vector, through
            % the point at the bottom of the finger
            plot([bottom_points(1,1) bottom_line.point(1) bottom_points(2,1)], [bottom_points(1,2) bottom_line.point(2) bottom_points(2,2)], 'bo','MarkerSize',10,'LineWidth',2);
            plot([bottom_points(1,1) bottom_line.point(1) bottom_points(2,1)], [bottom_points(1,2) bottom_line.point(2) bottom_points(2,2)], 'b-','LineWidth',3);
            
            % Plot the pairs of original points that bracket the new finger 
            % endpoints
            plot(old_finger(bottom_index(1,:),1),old_finger(bottom_index(1,:),2),'go-','MarkerSize',20,'LineWidth',2);
            plot(old_finger(bottom_index(2,:),1),old_finger(bottom_index(2,:),2),'go-','MarkerSize',20,'LineWidth',2);
        end
    end

end % trim_finger_contour
