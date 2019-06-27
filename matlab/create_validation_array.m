% Create an array containing the lists of images to use as "validation
% images" for each validation test

function [validation_tests, validation_measured] = create_validation_array(force_matrix, options)

    % Extract the input parameters
    if (nargin() == 1)
        [num_tests, frac_validation, verbose] = process_options([]);
    elseif (nargin() == 2)
        [num_tests, frac_validation, verbose] = process_options(options);
    else
        error('Must have 1 or 2 inputs!');
    end
    
    % Determine size of inputs
    [num_files, num_forces] = size(force_matrix);
    
    % Preallocate outputs
    num_validation = floor(frac_validation*num_files);
    validation_tests = zeros(num_validation, num_tests);
    validation_measured = zeros(num_validation, num_tests, num_forces);
    
    % Print a message for the user, as desired
    if (verbose)
        fprintf('Generating %d lists of %d validation images (with %d training images)\n', num_tests, num_validation, num_files - num_validation);
    end
    
    % Populate outputs
    for testIdx = 1:num_tests
        % Generate a random list of images
        validation_tests(:,testIdx) = create_random_index_array(num_validation, num_files);
        
        % Extract the measured forces to the output
        for validationIdx = 1:num_validation
            forceIdx = validation_tests(validationIdx, testIdx);
            validation_measured(validationIdx, testIdx, :) = force_matrix(forceIdx,:);
        end % validationIdx
    end % testIdx

end % create_validation_array

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the input options and assign default values as needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [num_tests, frac_validation, verbose] = process_options(options)

    if (isfield(options,'num_tests'))
        num_tests = options.num_tests;
    else
        num_tests = 100;
    end
    if (isfield(options,'frac_validation'))
        frac_validation = options.frac_validation;
    else
        frac_validation = 0.25;
    end
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end

end % process_options
