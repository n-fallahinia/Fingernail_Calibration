% FIND_NEW_FINGER_EDGE Finds a new finger edge using the orientation of the
% mean finger contour and the extremes of the mean nail contour.  Then
% finds the orientation of the current finger using those extreme points in
% the current nail contour, and locates the minimum and maximum points
% along the current finger contour that match with the desired
% nail-to-finger ratio.  Then re-samples the points so that the same number
% of finger contour points will be found in the new contour
% 
% Written by Thomas R. Grieve
% 2 April 2012
% University of Utah
% 

function [new_finger, new_nail] = adjust_finger_contour(finger_points, nail_points, options)

    % Extract options
    if (nargin() == 2)
        [nail_finger_ratio, use_full_contour, num_finger, num_nail, default_position, debug_mode] = process_options([]);
    elseif (nargin() == 3)
        [nail_finger_ratio, use_full_contour, num_finger, num_nail, default_position, debug_mode] = process_options(options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Determine type of inputs
    if (iscell(finger_points))
        % Determine size of inputs
        num_fingers = size(finger_points, 1);
        num_nails = size(nail_points, 1);
        
        % If some nails/fingers have not been registered same number of times,
        % process differently
        if (num_fingers == num_nails)
            % Preallocate arrays to hold aggregate data
            all_fingers = zeros(num_finger, num_fingers, 2);
            all_nails = zeros(num_nail, num_fingers, 2);
            
            % Process each finger contour
            for fingerIdx = 1:num_fingers
                % Extract current finger/nail points
                [finger_x, finger_y] = smooth_contour(finger_points{fingerIdx,1}, finger_points{fingerIdx,2}, 51);
                current_finger = [finger_x finger_y];
                [nail_x, nail_y] = smooth_contour([nail_points{fingerIdx,1}; nail_points{fingerIdx,1}(1)], [nail_points{fingerIdx,2}; nail_points{fingerIdx,2}(1)], 51);
                current_nail = [nail_x(1:(end-1)) nail_y(1:(end-1))];
                
                % Find unit vector along finger
                finger_angle = find_finger_angle(current_finger, debug_mode);
                
                % Re-create nail contour using distal end of nail as a starting point
                [new_nail, nail_length, nail_centroid] = reorder_nail_contour(current_nail, finger_angle, num_nail, debug_mode);
                
                if (use_full_contour)
                    % Find the desired length of the finger contour in the current image
                    finger_length = nail_finger_ratio*nail_length;
                    
                    % Determine the end points of the finger contour
                    [new_finger, length_missing] = trim_finger_contour(current_finger, nail_centroid, finger_angle, finger_length, num_finger, debug_mode);
                else
                    % Determine the end points of the finger contour
                    new_finger = trim_finger_contour_sides(current_finger, new_nail, finger_angle, num_finger, debug_mode);
                end
                
                % Store in aggregate arrays
                all_fingers(:, fingerIdx, 1) = new_finger(:,1);
                all_fingers(:, fingerIdx, 2) = new_finger(:,2);
                all_nails(:, fingerIdx, 1) = new_nail(:,1);
                all_nails(:, fingerIdx, 2) = new_nail(:,2);
            end % fingerIdx
            new_nail = reshape(mean(all_nails, 2), num_nail, 2);
        else
            % Preallocate arrays to hold aggregate data
            all_fingers = zeros(num_finger, num_fingers, 2);
            all_nails = zeros(num_nail, num_fingers, 2);
            
            % Find unit vector along finger
            finger_angles = zeros(num_fingers,1);
            for fingerIdx = 1:num_fingers
                current_finger = [finger_points{fingerIdx,1} finger_points{fingerIdx,2}];
                finger_angles(fingerIdx) = find_finger_angle(current_finger, debug_mode);
            end % fingerIdx
            finger_angle = mean(finger_angles);
            
            % Re-create nail contour using distal end of nail as a starting point
            nail_lengths = zeros(num_nails,1);
            nail_centroids = zeros(num_nails,2);
            for nailIdx = 1:num_nails
                current_nail = [nail_points{nailIdx,1} nail_points{nailIdx,2}];
                [new_nail, nail_lengths(nailIdx), nail_centroids(nailIdx,:)] = reorder_nail_contour(current_nail, finger_angle, num_nail, debug_mode);
                
                % Store in aggregate array
                all_nails(:, nailIdx, 1) = new_nail(:,1);
                all_nails(:, nailIdx, 2) = new_nail(:,2);
            end % nailIdx
            nail_length = mean(nail_lengths);
            nail_centroid = mean(nail_centroids);
            new_nail = reshape(mean(all_nails, 2), num_nail, 2);
            
            % Process each finger contour
            for fingerIdx = 1:num_fingers
                current_finger = [finger_points{fingerIdx,1} finger_points{fingerIdx,2}];
                if (use_full_contour)
                    % Find the desired length of the finger contour in the current image
                    finger_length = nail_finger_ratio*nail_length;
                    
                    % Determine the end points of the finger contour
                    [new_finger, length_missing] = trim_finger_contour(current_finger, nail_centroid, finger_angle, finger_length, num_finger, debug_mode);
                else
                    % Determine the end points of the finger contour
                    new_finger = trim_finger_contour_sides(current_finger, new_nail, finger_angle, num_finger, debug_mode);
                end
                
                % Store in aggregate arrays
                all_fingers(:, fingerIdx, 1) = new_finger(:,1);
                all_fingers(:, fingerIdx, 2) = new_finger(:,2);
            end % fingerIdx
        end
        new_finger = reshape(mean(all_fingers, 2), num_finger, 2);
        x_finger = new_finger(:,1);
        y_finger = new_finger(:,2);
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This form of input assumes the finger has already been trimmed,
        % so the bottom end of the finger is perpendicular to the finger
        % direction vector.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         % Switch the points back
%         finger_points = finger_points(:,[2 1]);
%         nail_points = nail_points(:,[2 1]);
        
        % Find finger angle as the perpendicular to the end of the finger
        finger_end = diff(finger_points([1 end],:));
        finger_angle = atan2(finger_end(1),-finger_end(2));
        
        % Determine the new finger contour
        new_finger = trim_finger_contour_sides(finger_points, nail_points, finger_angle, num_finger, debug_mode);
        x_finger = new_finger(:,1);
        y_finger = new_finger(:,2);
%         x_finger = new_finger(:,1);
%         y_finger = new_finger(:,2);
%         new_finger = [y_finger x_finger];
        
        % Determine the new nail contour
        if (size(nail_points,1) == num_nail)
            new_nail = nail_points;
        else
            [x_nail, y_nail] = smooth_contour(nail_points([1:end 1],1), nail_points([1:end 1],2), num_nail+1);
            new_nail = [x_nail(1:(end-1)) y_nail(1:(end-1))];
%             new_nail = [y_nail(1:(end-1)) x_nail(1:(end-1))];
        end
    end
    
    if (debug_mode)
        plot(x_finger,y_finger,'mx-');
    end

end % adjust_finger_contour

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nail_finger_ratio, use_full_contour, num_finger, num_nail, default_position, debug_mode] = process_options(options)

    if (isfield(options, 'nail_finger_ratio'))
        nail_finger_ratio = options.nail_finger_ratio;
    else
        nail_finger_ratio = 1.5;
    end
    if (isfield(options, 'use_full_contour_method'))
        use_full_contour = options.use_full_contour_method;
    else
        use_full_contour = false;
    end
    if (isfield(options, 'num_finger'))
        num_finger = options.num_finger;
    else
        num_finger = 30;
    end
    if (isfield(options, 'num_nail'))
        num_nail = options.num_nail;
    else
        num_nail = 45;
    end
    if (isfield(options, 'default_position'))
        default_position = options.default_position;
    else
        default_position = [46 46 1000 750];
    end
    if (isfield(options, 'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end

end % process_options
