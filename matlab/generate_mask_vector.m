% Generates a mask vector for use in initializing Expectation Maximization.
%  Can probably be deleted once it's been replaced in all other parts,
%  since it's obsolete, replaced by find_groups.
% 

function mask_vector = generate_mask_vector(force_matrix, options)

    % Extract options
    if (nargin() == 1)
        [zero_force, zero_shear, angle_edges] = process_options([]);
    elseif (nargin() == 2)
        [zero_force, zero_shear, angle_edges] = process_options(options);
    else
        error('Must have 1 or 2 inputs!');
    end
    
    % Determine input size
    [num_images, num_forces] = size(force_matrix);
    if (num_forces ~= 3)
        error('Cannot process this input!');
    end
    
    % Preallocate output
    mask_vector = zeros(num_images,1);
    
    % Process each image
    for imageIdx = 1:num_images
        % Extract the current force
        current_force = force_matrix(imageIdx,:);
        
        % Assign different mask values based on parameters
        if (norm(current_force) < zero_force)
            % "Zero" force
            mask_vector(imageIdx) = 1;
        else
            % Calculate the shear force magnitude
            shear_force = sqrt(current_force(1)^2 + current_force(2)^2);
            
            if (abs(shear_force) < zero_shear)
                % "Pure" normal force
                mask_vector(imageIdx) = 2;
            else
                % Calculate the shear force angle
                shear_angle = atan2(current_force(2), current_force(1)) * 180 / pi;
                
                % Determine the "bin" into which this angle falls
                angleIdx = find(shear_angle < angle_edges, 1, 'first');
                if (angleIdx == 1)
                    % Wrap around to the top bin
                    mask_vector(imageIdx) = length(angle_edges) + 1;
                else
                    % Assign to the bin corresponding to this index
                    mask_vector(imageIdx) = angleIdx + 1;
                end
            end
        end
    end % imageIdx

end % generate_mask_vector

function [zero_force, zero_shear, angle_edges] = process_options(options)

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

end % process options
