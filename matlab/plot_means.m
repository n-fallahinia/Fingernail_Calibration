function [handles, mean_vals, mean_ci] = plot_means(data_matrix, mask_matrices, options)

    % Extract the input parameters
    if (nargin() == 2)
        [default_position, figure_ID, figure_title, var1_names, var2_names, y_label, font_size, alpha, verbose] = process_options([]);
    elseif (nargin() == 3)
        [default_position, figure_ID, figure_title, var1_names, var2_names, y_label, font_size, alpha, verbose] = process_options(options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Determine the number mask variables
    if ((iscell(mask_matrices)) && (length(mask_matrices) > 1))
        % Determine the number of mask variable types
        var1 = mask_matrices{1};
        var2 = mask_matrices{2};
        var1_values = unique(var1);
        var2_values = unique(var2);
        num_var1 = length(var1_values);
        num_var2 = length(var2_values);
        if (~isempty(var1_names))
            var1_names = {var1_names{var1_values}};
        end
        if (~isempty(var2_names))
            var2_names = {var2_names{var2_values}};
        end
        
        % Calculate the mean and Standard Deviation
        mean_vals = zeros(num_var1, num_var2);
        mean_ci = zeros(num_var1, num_var2);
        for var1Idx = 1:num_var1
            for var2Idx = 1:num_var2
                % Extract the data that pertains to this pair of variables
                this_match = data_matrix((var1 == var1_values(var1Idx)) & (var2 == var2_values(var2Idx)));
                num_vals = length(this_match);
                if (num_vals == 0)
                    continue;
                elseif (num_vals == 1)
                    % Assign this value as the mean
                    mean_vals(var1Idx, var2Idx) = this_match;
                else
                    % Calculate the t-statistic
                    t_stat = tinv(1-alpha/2, num_vals-1);
                    nv = num_vals;
                    iter = 0;
                    while ((iter < 10) && (isnan(t_stat)))
                        % Approximate the t-statistic using a smaller
                        % number of values
                        iter = iter + 1;
                        nv = round(0.5*nv);
                        t_stat = tinv(1-alpha/2, nv-1);
                    end
                    
                    % Find the simple mean of the data
                    mean_vals(var1Idx, var2Idx) = mean(this_match);
                    
                    % Find the width of the confidence interval of the mean
                    std_dev = std(this_match);
                    ci = t_stat * std_dev / sqrt(num_vals);
                    mean_ci(var1Idx, var2Idx) = ci;
                end
            end % var2Idx
        end % var1Idx
    else
        % Determine the number of mask variable types
        if (iscell(mask_matrices))
            var2 = mask_matrices{1};
        else
            var2 = mask_matrices;
        end
        var2_values = unique(var2);
        num_var2 = length(var2_values);
        if (~isempty(var2_names))
            var2_names = {var2_names{var2_values}};
        end
        
        if (num_var2 == 1)
            % Find the mean of all data points
            mean_vals = mean(data_matrix(:));
            num_vals = numel(data_matrix);
            
            % Calculate the t-statistic
            t_stat = tinv(1-alpha/2, num_vals-1);
            nv = num_vals;
            iter = 0;
            while ((iter < 10) && (isnan(t_stat)))
                % Approximate the t-statistic using a smaller
                % number of values
                iter = iter + 1;
                nv = round(0.5*nv);
                t_stat = tinv(1-alpha/2, nv-1);
            end
            
            % Find the width of the confidence interval of the mean
            std_dev = std(data_matrix(:),[],1);
            ci = t_stat * std_dev / sqrt(num_vals);
            mean_ci = ci;
        else
            % Calculate the mean and Standard Deviation
            mean_vals = zeros(1, num_var2);
            mean_ci = zeros(1, num_var2);
            for var2Idx = 1:num_var2
                % Extract the data that pertains to this variables
                this_match = data_matrix(var2 == var2_values(var2Idx));
                num_vals = length(this_match);
                if (num_vals <= 1)
                    keyboard;
                else
                    % Calculate the t-statistic
                    t_stat = tinv(1-alpha/2, num_vals-1);
                    nv = num_vals;
                    iter = 0;
                    while ((iter < 10) && (isnan(t_stat)))
                        % Approximate the t-statistic using a smaller
                        % number of values
                        iter = iter + 1;
                        nv = round(0.5*nv);
                        t_stat = tinv(1-alpha/2, nv-1);
                    end
                end
                
                % Find the simple mean of the data
                mean_vals(var2Idx) = mean(this_match);
                
                % Find the width of the confidence interval of the mean
                std_dev = std(this_match);
                ci = t_stat * std_dev / sqrt(num_vals);
                mean_ci(var2Idx) = ci;
            end % var1Idx
        end
    end
    
    % Create a custom colormap to display the data
    custom_gray = gray(num_var2+1);
    custom_gray(1,:) = [];
    
    if (any(isnan(mean_ci)))
        keyboard;
    end
    
    % Plot the RMS error of each model in each position
    handles = barweb(mean_vals, mean_ci, 1, var1_names, figure_title, [], y_label, custom_gray, [], var2_names);
    set(handles.ax,'FontSize',font_size);
    set(handles.legend,'FontSize',font_size);
    set(get(handles.ax,'YLabel'),'FontSize',font_size);
    handles.figure = figure_ID;

end % plot_means

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the input options and assign default values as needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [default_position, figure_ID, figure_title, var1_names, var2_names, y_label, font_size, alpha, verbose] = process_options(options)

    if (isfield(options,'default_position'))
        default_position = options.default_position;
    else
        default_position = [46 46 1000 750];
    end
    if ((~isfield(options,'figure_ID')) || (options.figure_ID == 0))
        % Field does not exist, or is set to 'root'
        figure_ID = figure;
        set(figure_ID,'Position',default_position);
        subplot(1,1,1);
    else
        % Field exists and is a number
        figure_ID = options.figure_ID;
        if (ishandle(figure_ID))
            if (strcmp(get(figure_ID,'Type'),'figure'))
                figure(figure_ID);
            elseif ((strcmp(get(figure_ID,'Type'),'axes')) && (~strcmp(get(figure_ID,'Tag'),'')))
                fig_ID = get(figure_ID,'Parent');
                set(0,'CurrentFigure',fig_ID);
                set(fig_ID,'CurrentAxes',figure_ID);
                figure_ID = fig_ID;
            end
        else
            figure(figure_ID);
            set(figure_ID,'Position',default_position);
            subplot(1,1,1);
        end
    end
    if (isfield(options,'figure_title'))
        figure_title = options.figure_title;
    else
        figure_title = [];
    end
    if (isfield(options,'var1_names'))
        var1_names = options.var1_names;
    else
        var1_names = [];
    end
    if (isfield(options,'var2_names'))
        var2_names = options.var2_names;
    else
        var2_names = [];
    end
    if (isfield(options,'y_label'))
        y_label = options.y_label;
    else
        y_label = 'RMS Error (N)';
    end
    if (isfield(options,'font_size'))
        font_size = options.font_size;
    else
        font_size = 20;
    end
    if (isfield(options,'alpha'))
        alpha = options.alpha;
    else
        alpha = 0.05;
    end
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end

end % process_options
