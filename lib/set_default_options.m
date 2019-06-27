function options = set_default_options(old_options)

    if (nargin() == 1)
        if (isstruct(old_options))
            options = old_options;
        elseif (isnumeric(old_options))
            options.marker_colors = jet(old_options);
        end
    end
    
    % Set the figure size, font size, marker size, etc.
    options.default_position = [45 45 1000 750];
    options.font_size = 20;
    options.marker_size = 15;
    options.line_width = 3;
    options.dash_line_width = 2;
    options.font_name = 'Century Gothic';
    options.debug_mode = false;
    
    % Set up an array of colors for use in plotting
    if (~isfield(options,'marker_colors'))
        options.marker_colors = generate_colors();
    end

end % set_default_options

function output_colors = generate_colors()

    % Generate a mesh grid of the colors
    color_range = 0:0.5:1;
    [r,g,b] = meshgrid(color_range, color_range, color_range);
    output_colors = eliminate_duplicates([r(:) g(:) b(:)]);

end % generate_colors

function output_colors = eliminate_duplicates(input_colors)

    % Eliminate any rows that contain white
    delete_rows = find((input_colors(:,1) == 1) & (input_colors(:,2) == 1) & (input_colors(:,3) == 1));
    input_colors(delete_rows,:) = [];
    
    % Determine size of input
    [num_rows, num_colors] = size(input_colors);
    
    % Process each row
    eliminate = false(num_rows,1);
    for rowIdx = 1:(num_rows-1)
        % Skip rows that have been eliminated
        if (eliminate(rowIdx))
            continue;
        end
        current_color = input_colors(rowIdx,:);
        
        % Find other rows that match & mark for elimination
        for otherIdx = (rowIdx+1):num_rows
            % Skip rows that have been eliminated
            if (eliminate(otherIdx))
                continue;
            end
            
            % Determine whether this color matches the current color
            other_color = input_colors(otherIdx,:);
            if (norm(current_color-other_color) == 0)
                eliminate(otherIdx) = true;
            end
        end % otherIdx
    end % rowIdx
    
    % Assign the output
    output_colors = input_colors(~eliminate,:);

end % eliminate_duplicates
