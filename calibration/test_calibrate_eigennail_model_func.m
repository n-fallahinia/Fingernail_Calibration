function test_calibrate_eigennail_model_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx )
% Calibrate the EigenNail Magnitude Model (i.e., forms the EigenNail
%   Magnitude Model using all of the data as calibration data)
% 

% clear;
% clc;
% close all;
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
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx;
data_folder = sprintf('%s/data', base_folder);
param_file = sprintf('%s/params%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);

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

for resolutionIdx = 1:num_resolutions
    matrix_file = sprintf('%s/matrices%s_%02d_%03d.mat', data_folder, size_names{sizeIdx}, subjectIdx, resolutions(resolutionIdx));
    model_file = sprintf('%s/eigennail%s_%02d_%03d.mat', data_folder, size_names{sizeIdx}, subjectIdx, resolutions(resolutionIdx));
    
    % Load the matrices
    fprintf('Loading model data (Resolution %d)', resolutions(resolutionIdx));
    try
        load(matrix_file);
    catch exception
        fprintf('\n\tModel data does not exist!\n');
        continue;
    end
    fprintf('.');
    if (sum(options.eliminate) ~= 0)
        pixel_matrix(options.eliminate,:) = [];
    end
    fprintf('Done!\n\tData loaded (%d Images, %d Pixels)\n', size(pixel_matrix,1), size(pixel_matrix,2));
    
    % Determine the calibration model parameters
    fprintf('Forming EigenNail Model\n');
    try
        prediction_model = form_eigennail_model(force_matrix, pixel_matrix, options);
    catch exception
        fprintf('***************\n***************\n\tCould not create!\n***************\n***************\n');
        continue;
    end
    fprintf('Done\n');
    
    % Save the data
    save(model_file,'prediction_model');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display the Training Error
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Calculate the Training Error
    fprintf('Checking the training error\n');
    [predicted_force, use_image] = predict_forces_on_dataset(pixel_matrix, prediction_model, options);
    
    if (options.debug_mode)
        % Display the training error
        options.figure_title = 'EigenNail Training Results';
        fig_force(resolutionIdx) = plot_force_results(force_matrix, predicted_force, options);
        
        % Load the image mask and display the EigenNail Model
        fig_model(resolutionIdx) = display_eigennail_model(prediction_model, mask_image, options);
    end
    fprintf('Done!\n');
end % resolutionIdx

