function fig_model = display_prediction_model(prediction_model, mask_image, options)

    % Determine the appropriate model and display it
    if (isfield(prediction_model,'slope_matrix'))
        figure_ID = display_sigmoid_model(prediction_model, mask_image, options);
    elseif (isfield(prediction_model,'linear_weights'))
        [fig_model, fig_nails, fig_eigs] = display_eigennail_model(prediction_model, mask_image, options);
    elseif (isfield(prediction_model,'param_weights'))
        Evectors = mask_image.Evectors;
        Evalues = mask_image.Evalues;
        figure_ID = display_AAMFinger_model(prediction_model, Evectors, Evalues, options);
    else
        error('Unknown prediction model type!');
    end

end % display_prediction_model
