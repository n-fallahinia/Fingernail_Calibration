function custom_colormap = get_custom_colormap(map_size, map_spacing, custom_colors, delta)

    % Handle default size
    if (nargin() == 0)
        map_size = 31;
        map_spacing = 'linear';
        custom_colors = [0 1 0; 1 1 0];
        delta = 1e-3;
    elseif (nargin() == 1)
        map_spacing = 'linear';
        custom_colors = [0 1 0; 1 1 0];
        delta = 1e-3;
    elseif (nargin() == 2)
        custom_colors = [0 1 0; 1 1 0];
        delta = 1e-3;
    elseif (nargin() == 3)
        delta = 1e-3;
    elseif (nargin() ~= 4)
        error('Must have 0, 1, 2, 3 or 4 inputs!');
    end
    
    % Determine the custom colors
    [num_rows, num_columns] = size(custom_colors);
    if (num_rows == 1)
        % Double the first row
        custom_colors(2,:) = custom_colors(1,:);
    end
    if (num_columns < 3)
        % Expand the last column
        custom_colors(:,(num_columns+1):3) = custom_colors(:,num_columns);
    end
    
    % Determine number of entries in half the colormap
    if (mod(map_size,2) == 0)
        half_entry = map_size / 2;
        mid_entry = [];
    else
        half_entry = floor(map_size/2);
        mid_entry = [0 0 0];
    end
    
    % Determine method for map spacing
    if (strcmp(map_spacing,'linear'))
        one_side = linspace(0,1,half_entry+1)';
    elseif (strcmp(map_spacing,'log_high'))
        one_side = (10.^(linspace(delta,1+delta,half_entry+1)') - 10.^delta) / (10^(1+delta) - 10^delta);
    elseif (strcmp(map_spacing,'log_low'))
        one_side = (log10(linspace(delta,1+delta,half_entry+1)') - log10(delta)) / (log10(1+delta) - log10(delta));
    else
        error('Unknown parameter for map spacing!');
    end
    
    % Generate the equally-spaced entries for one side
    one_side(1) = [];
    
    % Arrange the entries to be according to the custom colors
    custom_colormap = [one_side(half_entry:-1:1)*custom_colors(1,1) one_side(half_entry:-1:1)*custom_colors(1,2) one_side(half_entry:-1:1)*custom_colors(1,3);
        mid_entry;
        one_side*custom_colors(2,1) one_side*custom_colors(2,2) one_side*custom_colors(2,3)];

end % get_custom_colormap
