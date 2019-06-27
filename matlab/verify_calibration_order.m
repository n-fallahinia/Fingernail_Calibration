function [success, details] = verify_calibration_order(subject, options)

    % Verify inputs
    if (nargin() == 1)
        [size_names, resolutions, num_models] = process_options([]);
    elseif (nargin() == 2)
        [size_names, resolutions, num_models] = process_options(options);
    else
        error('Must have 1 or 2 inputs!');
    end
    
    % Determine subject details
    [subjects, types, fingers, sizes, resolutions] = unpack_subject(subject);
    

end % verify_calibration_order

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unpack the subject details
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [subjects, types, fingers, sizes, resolutions] = unpack_subject(subject, num_defaults)

    % Determine existence of each field, or assign defaults
    if (isfield(subject, 'subjectIdx'))
        subjects = subject.subjectIdx;
    else
        subjects = 1:num_defaults(1);
    end
    if (isfield(subject, 'typeIdx'))
        types = subject.typeIdx;
    else
        types = 1:num_defaults(2);
    end
    if (isfield(subject, 'fingerIdx'))
        fingers = subject.fingerIdx;
    else
        fingers = 1:num_defaults(3);
    end
    if (isfield(subject, 'sizeIdx'))
        sizes = subject.sizeIdx;
    else
        sizes = 1:num_defaults(4);
    end
    if (isfield(subject, 'resolutionsIdx'))
        resolutions = subject.resolutionIdx;
    else
        resolutions = 1:num_defaults(5);
    end

end % unpack_subject

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process input options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [size_names, resolutions, model_names] = process_options(options)

    % Determine existence of each field, or assign defaults
    if (isfield(options,'size_names'))
        size_names = options.size_names;
    else
        size_names = {'', '_med', '_small', '_tiny', '_mini', '_green', '_red', '_blue'};
    end
    if (isfield(options,'resolutions'))
        resolutions = options.resolutions;
    else
        resolutions = 10:10:50;
    end
    if (isfield(options,'model_names'))
        model_names = options.model_names;
    else
        model_names = {'LinSig', 'EigNail', 'Shape', 'Texture', 'Appearance'};
    end

end % process_options
