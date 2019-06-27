function test_eigennail_predic_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx )
% force prediction using EigenNail Magnitude Model (i.e., forms the EigenNail
%   Magnitude Model using all of the data as calibration data) 
% 

    % Define parameters
    % subjectIdx = 2;
    % typeIdx = 3;
    % fingerIdx = 2;
    % colorIdx = 1;
    sizeIdx = 1;

    % Define constants
    size_names = {'', '_med', '_small', '_tiny', '_mini', '_regsides', '_sides','_gray', '_red', '_green', '_blue','_nail'};
    size_strings = {'Standard','Medium','Small','Tiny','Mini','Register_Sides','Convert_Sides','Gray','Red','Green','Blue','Nail Only'};
    num_sizes = length(size_names);
    color_names = {'white','green'};
    finger_names = {'thumb','index','middle','ring'};
    if ((colorIdx == 1) && (sizeIdx == 1))
        resolutions = [10:10:50 100:100:1000];
    else
        resolutions = [10 50];
    end
    num_resolutions = length(resolutions);
    fprintf('Processing %02d/%s/%s/%s\n', subjectIdx, finger_names{fingerIdx}, color_names{colorIdx}, size_strings{sizeIdx});

    % Define data folders
    base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
    data_folder = sprintf('%s/data', base_folder);

    % If necessary, change the base folder for data file
    if typeIdx == 4 
        base_folder_amm = strrep(base_folder,'exp/test_02','cal'); 
        data_folder_aam = sprintf('%s/data', base_folder_amm);
    end

    % Load the parameter model
    if typeIdx == 4
        param_file = sprintf('%s/params%s_%02d.mat', data_folder_aam, size_names{sizeIdx}, subjectIdx);
    else
        param_file = sprintf('%s/params%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);   
    end

     % Load the AAM model
     if typeIdx == 4
        data_file = sprintf('%s/data%s_%02d.mat', data_folder_aam, size_names{sizeIdx}, subjectIdx);
     else
        data_file = sprintf('%s/data%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);   
     end

     % Load the AAM Model data
    size_name = size_names{sizeIdx};
    load(data_file);

    % Load options structure and update options
    options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
    load(options_file);
    options.eigen_cutoff = 0.99;
    options.ignore_first = false;
    options.debug_mode = true;
    options.verbose = true;
    options.num_eigs_var = 3;
    options.num_eigs_disp = 6;

    % Load list of image files (Look for raw matlab files first)
    files_filename = sprintf('%s/files%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
    load(files_filename);
    num_files = length(files);

    % Load array of points
    points_file = sprintf('%s/points%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
    if (~exist(points_file,'file'))
        error('Points Array file does not exist!');
    end
    load(points_file);
    if (size(pts_array, 2) ~= num_files)
        error('Size of Points Array does not match Files list!');
    end
    temp = sum(abs(pts_array), 1);
    options.eliminate = (temp == 0);

    % Eliminate data, if needed
    load(param_file,'force_matrix');
    if (sum(options.eliminate) ~= 0)
        force_matrix(options.eliminate,:) = [];
    end

    max_reso = max(size(TextureData.ObjectPixels));
    if (max(resolutions) > max_reso)
        % Reduce the resolutions array accordingly
        resolutions(resolutions > max_reso) = [];
        resolutions = resolutions(end);
        % Re-calculate the number of resolutions
    end
    matrix_file = sprintf('%s/matrices%s_%02d_%03d.mat', data_folder, size_names{sizeIdx}, subjectIdx, resolutions);
    model_file = sprintf('%s/eigennail%s_%02d_%03d.mat', data_folder_aam, size_names{sizeIdx}, subjectIdx, resolutions);
    force_file = sprintf('%s/force%s_%02d_%03d.mat', data_folder, size_names{sizeIdx}, subjectIdx, resolutions);


    % Load the model file
    fprintf('Loading model data (Resolution %d)', resolutions);
    if (~exist(model_file,'file'))
        error('\nModel data does not exist!');
    end
    load(model_file);
    
    % Load the matrices
    fprintf('\nLoading matrix data (Resolution %d)', resolutions);
    if (~exist(matrix_file,'file'))
        error('matrix file does not exist!');
    end
    load(matrix_file);
    
    fprintf('.');
    if (sum(options.eliminate) ~= 0)
        pixel_matrix(options.eliminate,:) = [];
    end
    fprintf('Done!\n')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Predicting the Forces 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Calculate the forces
    fprintf('Predicting the forces\n');
    [predicted_force, use_image] = predict_forces_on_dataset(pixel_matrix, prediction_model, options);
    
    % Save the data
    save(force_file,'predicted_force');
    
    if (options.debug_mode)
        fprintf('EigenNail Training Results:');      
        % Load the image mask and display the EigenNail Model
        fig_model = display_eigennail_model(prediction_model, mask_image, options);
    end
    fprintf('Done!\n');
    
end 

