% FIND_FINGER_ANGLE Find the finger angle, in radians, given the point
% locations [x y] of the finger edge points.
% 
% finger_angle = find_finger_angle(finger_points, debug_mode) finds the
%   angle of the finger with respect to the positive x-axis, rotated
%   clockwise around the positive z-axis (into the monitor).  (In the image
%   plane, this is a right-hand coordinate system, since the positive
%   y-axis points down.)  The optional input debug_mode determines whether
%   or not to display the 

function finger_angle = find_finger_angle(finger_points, debug_mode)

    % Process optional inputs
    if (nargin() == 1)
        debug_mode = false;
    elseif (nargin() ~= 2)
        error('Must have 1 or 2 inputs!');
    end
    if (debug_mode)
        % Length for plotting the "finger direction" vector
        vector_length = 0.25*(max(finger_points(:)) - min(finger_points(:)));
    end
    
    % Determine size of inputs
    num_finger = size(finger_points,1);
    
    % Find angle of straight line that fits "Left" points
    left_pts = finger_points(1:round(num_finger/3),:);
    left_angle = find_line_angle(left_pts(:,1), left_pts(:,2), debug_mode);
    
    % Find angle of straight line that fits "Right" points
    right_pts = finger_points(end:-1:(end-size(left_pts,1)+1),:);
    right_angle = find_line_angle(right_pts(:,1), right_pts(:,2), debug_mode);
    
    % Make sure angles are not on opposite ends of the atan function output
    if (abs(left_angle - right_angle) > 3*pi/2)
        left_angle = left_angle - 2*pi*sign(left_angle);
    end
    
    % Average of angles is the finger angle
    finger_angle = (left_angle + right_angle) / 2;
    
    % Plot the two finger sides and the central axis
    if (debug_mode)
        % Plot the finger direction vector
        finger_centroid = mean(finger_points, 1);
        plot(finger_centroid(1) + vector_length*[0 cos(finger_angle)], finger_centroid(2) + vector_length*[0 sin(finger_angle)],'b-','LineWidth',3);
        
        % Plot a marker at the centroid (to distinguish the direction of
        % the finger vector)
        plot(finger_centroid(1), finger_centroid(2),'bo','MarkerSize',10,'LineWidth',2);
    end

end % find_finger_angle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the angle between the best-fit line of the data (x,y) and the x-axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function line_angle = find_line_angle(x_points, y_points, debug_mode)

    % Determine size of inputs
    num_points = numel(x_points);
    if (numel(y_points) ~= num_points)
        error('Coordinates do not match!');
    end
    
    % Determine whether the x-coordinate or y-coordinate is more dominant
    x_diff = max(x_points) - min(x_points);
    y_diff = max(y_points) - min(y_points);
    use_x = (x_diff > y_diff);
    
    % Use Total Least Squares to fit the data
    if (use_x)
        % Use x as the 'independent' variable
        params = polyfit_tls(x_points, y_points, 1);
        
        % Calculate the 'best-fit' of the 'dependent' variable
        x_fit = x_points;
        y_fit = polyval(params, x_fit);
    else
        % Use y as the 'independent' variable
        params = polyfit_tls(y_points, x_points, 1);
        
        % Calculate the 'best-fit' of the 'dependent' variable
        y_fit = y_points;
        x_fit = polyval(params, y_fit);
    end
    
    % Find approximate distance traveled in each direction
    delta_x = x_fit(end) - x_fit(1);
    delta_y = y_fit(end) - y_fit(1);
    
    % Calculate the angle of the line with respect to the x-axis
    line_angle = atan2(delta_y, delta_x);
    
    % Plot, if desired
    if (debug_mode)
        plot(x_fit, y_fit, 'g-', 'LineWidth',3);
    end

end % find_line_angle
