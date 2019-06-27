function prediction_model = form_pls_model(forces, pixels, options)

    % Verify inputs
    if (nargin() == 2)
        [eigen_cutoff, verbose, debug_mode] = unpack_options([]);
    elseif (nargin() == 3)
        [eigen_cutoff, verbose, debug_mode] = unpack_options(options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Determine size of inputs
    num_images = size(forces, 1);
    num_pixels = size(pixels, 2);
    if (size(pixels,1) ~= num_images)
        error('Bad pixel matrix!');
    end
    num_comp = round(0.1*min([num_images num_pixels]));
    delta_comp = num_comp;
    
    % Condition data - Center and scale
    [X, mean_X, std_X] = zscore(pixels, 1);
    [Y, mean_Y, std_Y] = zscore(forces, 1);
    
    % Alternative PLS Calculation
    [X_load, Y_load, X_score, Y_score, beta_values, pct_variance, mn_sq_err, pls_stats] = plsregress(X, Y, num_comp);
    if (verbose)
        fprintf('.');
    end
    
    % Verify that enough variance was accounted for
    total_variance = sum(pct_variance, 2);
    done = false;
    while ((~done) && (min(total_variance) < eigen_cutoff))
        num_comp = num_comp + delta_comp;
        if (num_comp > num_pixels)
            done = true;
            num_comp = num_pixels;
        end
        [X_load, Y_load, X_score, Y_score, beta_values, pct_variance, mn_sq_err, pls_stats] = plsregress(X, Y, num_comp);
        total_variance = sum(pct_variance, 2);
        if (verbose)
            fprintf('.');
        end
    end
    if (verbose)
        fprintf('Done!\n');
    end
    
    % Find minimum number of modes of variation
    cumul_variance = cumsum(pct_variance, 2);
    x_cutoff = find(cumul_variance(1,:) > eigen_cutoff, 1);
    y_cutoff = find(cumul_variance(2,:) > eigen_cutoff, 1);
    if (isempty(x_cutoff))
        x_cutoff = num_comp;
    end
    if (isempty(y_cutoff))
        y_cutoff = num_comp;
    end
    cutoff_index = max([x_cutoff y_cutoff]);
    
    % Assemble prediction model structure and remove unused modes
    prediction_model.cutoff_index = cutoff_index;
    prediction_model.mean_X = mean_X;
    prediction_model.mean_Y = mean_Y;
    prediction_model.std_X = std_X;
    prediction_model.std_Y = std_Y;
    prediction_model.beta_values = beta_values(1: (cutoff_index+1),:);
    prediction_model.pct_variance = pct_variance(:, 1:cutoff_index);
    prediction_model.X_load = X_load(1:(cutoff_index-1), 1:cutoff_index);
    prediction_model.Y_load = Y_load(:, 1:cutoff_index);
    prediction_model.X_score = X_score(:, 1:cutoff_index);
    prediction_model.Y_score = Y_score(:, 1:cutoff_index);
    prediction_model.mn_sq_err = mn_sq_err(:, 1:(cutoff_index-1));
    prediction_model.pls_stats = pls_stats;
    prediction_model.pls_stats.W = pls_stats.W(1:(cutoff_index-1), 1:(cutoff_index-1));
    prediction_model.pls_stats.Xresiduals = pls_stats.Xresiduals(:, 1:(cutoff_index-1));

end % form_pls_model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the input parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [eigen_cutoff, verbose, debug_mode] = unpack_options(options)

    % Assign default options, if they do not exist
    if (isfield(options,'num_eigs'))
        num_eigs = options.num_eigs;
        eigen_cutoff = 1;
    else
        num_eigs = Inf;
        if (isfield(options,'eigen_cutoff'))
            eigen_cutoff = options.eigen_cutoff;
        else
            eigen_cutoff = 0.99;
        end
    end
    if (isfield(options,'ignore_first'))
        ignore_first = options.ignore_first;
    else
        ignore_first = false;
    end
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end
    if (isfield(options,'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end

end % unpack_options
