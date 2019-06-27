function figure_ID = resize_figure(figure_ID, dimension)

    % Get the desired position for the subplot
    figure(figure_ID);
    desired_pos = get(gca,'Position');
    
    % Decrement desired dimension in steps to reduce number of calculations 
    steps = [125 25 5 1];
    num_steps = length(steps);
    for stepIdx = 1:num_steps
        [figure_ID, current_dim, norm_pos] = decrement_loop(figure_ID, dimension, desired_pos, steps(stepIdx));
        fprintf('Decreased by %03d''s, to %04d, residual = %7.4f\n', steps(stepIdx), current_dim, norm_pos);
    end % stepIdx

end % resize_figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop at the specified decrement size
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [figure_ID, current_dim, norm_pos] = decrement_loop(figure_ID, dimension, desired_pos, decrement_size)

    % Get the position of the desired figure
    fig_pos = get(figure_ID,'Position');
    current_dim = fig_pos(dimension);
    
    % Loop to decrement the desired dimension
    done = false;
    while ((~done) && (current_dim > decrement_size))
        % Update the figure size
        current_dim = current_dim - decrement_size;
        fig_pos(dimension) = current_dim;
        set(figure_ID,'Position',fig_pos);
        drawnow();
        
        % Get the axis size
        current_pos = get(gca,'Position');
        
        % If the axis size is not still equal to the desired size, stop
        norm_pos = norm(current_pos - desired_pos);
        if (norm_pos ~= 0)
            current_dim = current_dim + decrement_size;
            fig_pos(dimension) = current_dim;
            set(figure_ID,'Position',fig_pos);
            drawnow();
            norm_pos = norm(get(gca,'Position') - desired_pos);
            done = true;
        end
    end

end % decrement_loop
