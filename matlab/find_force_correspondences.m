function [correspondences, eliminate, break_points, forces_approx] = find_force_correspondences(force_matrix, force_to_traj, fingerIdx, options)

    % Determine size of inputs
    num_images = size(force_matrix, 1);
    num_traj = max(force_to_traj(:,6));
    
    % Extract the relevant trajectory points
    if (fingerIdx > 2)
        finger_index = 2;
    else
        finger_index = fingerIdx;
    end
    convIdx = find(force_to_traj(:,4) == finger_index);
    conversion_points = force_to_traj(convIdx,:);
    num_conv = size(conversion_points, 1);
    
    % Find the minimum distance to trajectory points for each image
    correspondences = zeros(num_images, 2);
    correspondences(:,1) = 1:num_images;
    for imageIdx = 1:num_images
        % Calculate the distances
        current_distances = sqrt(sum((repmat(force_matrix(imageIdx,:),num_conv,1) - conversion_points(:,1:3)).^2, 2));
        min_dist = min(current_distances);
        minIdx = find(current_distances == min_dist);
        if (length(minIdx) > 1)
            temp = diff(conversion_points(minIdx,:));
            if (temp(:,4) == 0)
                minIdx = minIdx(1);
            else
                keyboard;
            end
        end
        
        % Store the index, as determined
        correspondences(imageIdx, 2) = convIdx(minIdx);
    end
    
    % Determine where the majority of the points are from
    cartesian = (force_to_traj(correspondences(:,2), 5) == 1);
    if (sum(cartesian) > 0.5*num_images)
        % Cartesian is the dominant trajectory type - eliminate cylindrical
        changeIdx = correspondences(~cartesian,1);
        traj_type = 1;
    else
        % Cylindrical is the dominant trajectory type - eliminate Cartesian
        changeIdx = correspondences(cartesian,1);
        traj_type = 2;
    end
    conv2Idx = find((force_to_traj(:,4) == finger_index) & (force_to_traj(:,5) == traj_type));
    conv2_points = force_to_traj(conv2Idx,:);
    num_conv2 = size(conv2_points, 1);
    num_change = length(changeIdx);
    
    % Find the minimum distance to newly-identified trajectory points for each
    % image to be changed
    for imageIdx = 1:num_change
        % Calculate the distances
        current_force = force_matrix(changeIdx(imageIdx),:);
        current_distances = sqrt(sum((repmat(current_force,num_conv2,1) - conv2_points(:,1:3)).^2, 2));
        min_dist = min(current_distances);
        minIdx = find(current_distances == min_dist);
        if (length(minIdx) > 1)
            temp = diff(conv2_points(minIdx,:));
            if (temp(:,4) == 0)
                minIdx = minIdx(1);
            else
                keyboard;
            end
        end
        
        % Store the index, as determined
        correspondences(changeIdx(imageIdx), 2) = conv2Idx(minIdx);
    end
    
    % Determine potential places to break calibration sets
    %   (or images to eliminate)
    forces_approx = force_to_traj(correspondences(:,2),:);
    break_points = zeros(num_traj,1);
    break_points(1) = 1;
    eliminate = false(num_images,1);
    for trajIdx = 2:num_traj
        % Extract indices of forces from the current trajectory
        current_traj = find(forces_approx(:,6) == trajIdx);
        previous_traj = find(forces_approx(:,6) == (trajIdx-1));
        options.trajIdx = trajIdx;
        if ((isempty(current_traj)) && (isempty(previous_traj)))
            continue;
        end
        
        % Ask the user
        [break_points(trajIdx), eliminate_these, btn_press] = find_break_points('Current',current_traj,'Previous',previous_traj,'Options',options);
        if (strcmp(btn_press,'No'))
            msg_handle = msgbox('Then you are responsible for determining the correct forces in <previous_traj> to <eliminate> and where the proper <break_point> is!','I''m Out!','warn','modal');
            uiwait(msg_handle);
            figure(1);
            set(1,'Position',options.default_position);
            plot(current_traj,trajIdx*ones(size(current_traj)),'k.',previous_traj,(trajIdx-1)*ones(size(previous_traj)),'r.');
            set(gca,'YLim',[-2 1]+trajIdx);
            set(gca,'YTick',(-2:1)+trajIdx);
            fprintf('You need to set the following:\n\tbreak_points(trajIdx)\n\teliminate_these\nSee the figure to inspect the data.\n');
            keyboard;
        elseif (~((strcmp(btn_press,'Yes')) || (strcmp(btn_press,'None'))))
            msgbox('User manually cancelled trajectory checking.','Error!','error','modal');
            error('User manually cancelled trajectory checking.');
        end
        
        % Remove eliminated values
        forces_approx(eliminate_these,6) = -1;
        eliminate(eliminate_these) = true;
    end % trajIdx
    
    % Eliminate values from the final trajectory
    eliminate_these = current_traj(current_traj < break_points(num_traj));
    eliminate(eliminate_these) = true;

end % find_force_correspondences
