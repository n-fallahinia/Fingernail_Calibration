function groups = find_groups(force_matrix, options)

    % Process options
    if (nargin() == 1)
        [zero_force, zero_shear, angle_edges, debug_mode] = process_options([]);
    elseif (nargin() == 2)
        [zero_force, zero_shear, angle_edges, debug_mode] = process_options(options);
    else
        error('Must have 1 or 2 inputs!');
    end
    
    % Determine size of force matrix
    [num_images, num_forces] = size(force_matrix);
    if (num_forces ~= 3)
        error('Cannot process this input!');
    end
    
    % Preallocate the output
    num_groups = 2 + (length(angle_edges)-1);
    groups = struct('centroid',[],'array',[]);
    groups(num_groups).array = [];
    
    % Process each image
    for imageIdx = 1:num_images
        % Extract the current force
        current_force = force_matrix(imageIdx,:);
        
        % Assign image to a group based on parameters
        if (norm(current_force) < zero_force)
            % "Zero" force
            groupIdx = 1;
        else
            % Calculate the shear force magnitude
            shear_force = sqrt(current_force(1)^2 + current_force(2)^2);
            
            if (abs(shear_force) < zero_shear)
                % "Pure" normal force
                groupIdx = 2;
            else
                % Calculate the shear force angle
                shear_angle = atan2(current_force(2), current_force(1)) * 180 / pi;
                
                % Determine the "bin" into which this angle falls
                angleIdx = find(shear_angle < angle_edges, 1, 'first');
                if (angleIdx == 1)
                    % Wrap around to the top bin
                    groupIdx = length(angle_edges) + 1;
                else
                    % Assign to the bin corresponding to this index
                    groupIdx = angleIdx + 1;
                end
            end
        end
        
        % Assign the image to the appropriate group
        if ((length(groups) < groupIdx) || (isempty(groups(groupIdx).array)))
            groups(groupIdx).array(1) = imageIdx;
        else
            groups(groupIdx).array(end+1) = imageIdx;
        end
    end % imageIdx
    
    % Plot the forces
    if (debug_mode)
        load('c:\\fingerdata\\finger_asm\\data\\marker_colors.mat');
        figure(1);
        plot3(force_matrix(:,1),force_matrix(:,2),force_matrix(:,3),'k.');
        hold on;
    end
    
    % Calculate the actual centroid of each group
    for groupIdx = 1:num_groups
        current_array = groups(groupIdx).array;
        if (isempty(current_array))
            continue;
        end
        group_forces = force_matrix(current_array,:);
        groups(groupIdx).centroid = mean(group_forces,1);
        if (debug_mode)
            if (~isnan(groups(groupIdx).centroid))
                plot3(groups(groupIdx).centroid(1),groups(groupIdx).centroid(2),groups(groupIdx).centroid(3),'bx','MarkerSize',15);
            end
            plot3(group_forces(:,1),group_forces(:,2),group_forces(:,3),'o','Color',marker_colors(groupIdx,:));
        end
    end % listIdx
    
    if (debug_mode)
        hold off;
        
        % Finish the image
        axis equal;
        xlabel('F_x');
        ylabel('F_y');
        zlabel('F_z');
        drawnow();
    end

end % find_groups

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the input options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [zero_force, zero_shear, angle_edges, debug_mode] = process_options(options)

    % Extract each option or replace missing ones with the defaults
    if (isfield(options,'zero_force'))
        zero_force = options.zero_force;
    else
        zero_force = 2.0;
    end
    if (isfield(options,'zero_shear'))
        zero_shear = options.zero_shear;
    else
        zero_shear = 0.5;
    end
    if (isfield(options,'angle_edges'))
        angle_edges = options.angle_edges;
    else
        num_edges = 9;
        range = [-180 180];
        angle_edges = linspace(range(1),range(2),num_edges) + ((range(2) - range(1))/(num_edges-1)) / 2;
    end
    if (isfield(options,'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end

end % process_options
