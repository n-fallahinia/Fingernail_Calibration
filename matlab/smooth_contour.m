% Create a smoothed version of the contour defined by (x_coords, y_coords)
% containing the desired number of points num_points.  Perform num_smooth
% iterations of smoothing.  The default value for num_points is the length
% of the coordinate vectors and a single iteration of smoothing is the
% default.
% 

function [x_coords, y_coords] = smooth_contour(x_coords, y_coords, num_points, num_smooth)

    % Verify inputs
    if (nargin() == 2)
        num_points = length(x_input);
        num_smooth = 1;
    elseif (nargin() == 3)
        num_smooth = 1;
    elseif (nargin() ~= 4)
        error('Must have 2, 3 or 4 inputs!');
    end
    
    for smoothIdx = 1:num_smooth
        % Calculate the cumulative distance of each point along the contour
        distances = [0; sqrt((x_coords(1:(end-1)) - x_coords(2:end)).^2 + (y_coords(1:(end-1)) - y_coords(2:end)).^2)];
        parameter = cumsum(distances);
        
        % Verify that the points are distinct
        delta_p = diff(parameter);
        if (any(delta_p == 0))
            eliminate = (delta_p == 0);
            parameter(eliminate) = [];
            x_coords(eliminate) = [];
            y_coords(eliminate) = [];
        end
        
        % Generate an evenly-spaced set of points along those distances
        even_parameter = linspace(min(distances), max(parameter), num_points)';
        
        % Interpolate the x and y coordinates
        x_coords = interp1(parameter, x_coords, even_parameter);
        y_coords = interp1(parameter, y_coords, even_parameter);
    end % smoothIdx

end % function