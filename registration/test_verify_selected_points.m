% Generate the points files (.PTS) to use with the Training Images to form
% an Active Appearance Model.
% 

% Clear memory, wipe the screen and close all figures
clear;
clc;
close all;

% Define parameters
typeIdx = 6;

% Define constants
user_names = {'Tom','Lisa','David'};
num_users = length(user_names);
num_subjects = 19;
all_subjects = 1:num_subjects;
elim_subj = [7 16];
num_elim = length(elim_subj);
finger_names = {'thumb','index'};
num_fingers = length(finger_names);
color_names = {'white','green'};
num_colors = length(color_names);
num_calibration = 12;

% Set up arrays of all combinations
[fingers, colors, subjects] = meshgrid(1:num_fingers, 1:num_colors, all_subjects);
for elimIdx = 1:num_elim
    fingers(subjects == elim_subj(elimIdx)) = [];
    colors(subjects == elim_subj(elimIdx)) = [];
    subjects(subjects == elim_subj(elimIdx)) = [];
end % elimIdx
num_subjects = numel(subjects);
subjects = reshape(subjects, num_subjects, 1);
fingers = reshape(fingers, num_subjects, 1);
colors = reshape(colors, num_subjects, 1);

% Process all combinations
calib_files = false(num_subjects, num_users, num_calibration);
for subjIdx = 1:num_subjects
    % Extract subject information
    subjectIdx = subjects(subjIdx);
    fingerIdx = fingers(subjIdx);
    colorIdx = colors(subjIdx);
    
    % Define base folder
    fprintf('Processing Subject %02d/%s/%s', subjectIdx, finger_names{fingerIdx}, color_names{colorIdx});
    base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx);
    if (~exist(base_folder,'dir'))
        fprintf(' (base_folder)\n');
        continue;
    end
    
    % Define data folders
    data_folder = sprintf('%s\\data', base_folder);
    points_folder = sprintf('%s\\points', base_folder);
    
    % Load options structure and extract the calibration (training) images
    options_file = sprintf('%s\\options_%02d.mat', data_folder, subjectIdx);
    if (~exist(options_file,'file'))
        fprintf(' (options)');
        continue;
    end
    load(options_file);
    if (~isfield(options,'selected_files'))
        fprintf(' (selected_files)\n');
        continue;
    end
    calibration_images = options.selected_files;
    num_calib = length(calibration_images);
    
    % Process all users
    for userIdx = 1:num_users
        % Check whether any points have been generated
        mat_files = dir(sprintf('%s\\calib_*_%02d.mat', data_folder, userIdx));
        if (isempty(mat_files))
            fprintf('\n\tUser %d has generated no calibration files', userIdx);
            continue;
        elseif (length(mat_files) == num_calib)
            fprintf('\n\t\tUser %d has generated all calibration files', userIdx);
            calib_files(subjIdx, userIdx, 1:num_calib) = true;
            continue;
        end
        
        % Process all calibration images
        for calibIdx = 1:num_calib
            % Check whether the points have been generated
            mat_files = dir(sprintf('%s\\calib_%04d_%02d.mat', data_folder, calibIdx, userIdx));
            if (isempty(mat_files))
                % No .MAT file
                continue;
            end
            
            % Load data
            load(sprintf('%s\\%s', data_folder, mat_files.name));
            if ((isempty(finger_points)) || (~exist('nail_points','var')) || (isempty(nail_points)))
                continue;
            end
            
            % Mark the image as calibrated
            calib_files(subjIdx, userIdx, calibIdx) = true;
        end % calibIdx
    end % userIdx
    fprintf('\n');
end % subjIdx

% Eliminate calibration indices that were not used
eliminate = find(sum(sum(calib_files, 2), 1) == 0);
calib_files(:,:,eliminate) = [];
num_calibration = num_calibration - numel(eliminate);

% Print each subject/finger/color combination
for subjIdx = 1:num_subjects
    % Extract subject information
    subjectIdx = subjects(subjIdx);
    fingerIdx = fingers(subjIdx);
    finger_abbr = finger_names{fingerIdx};
    colorIdx = colors(subjIdx);
    color_abbr = color_names{colorIdx};
    if ((subjIdx > 1) && (subjectIdx ~= subjects(subjIdx-1)))
        fprintf('=====================\n');
    end
    
    % Print the details
    fprintf('%02d|%s|%s||', subjectIdx, finger_abbr(1:2), color_abbr(1:2));
    current_calib = reshape(sum(calib_files(subjIdx, :, :), 2), 1, num_calibration);
    for calibIdx = 1:num_calibration
        if (current_calib(calibIdx) == 0)
            fprintf(' ');
        else
            fprintf('*');
        end
    end % calibIdx
    fprintf('\n');
end % subjIdx

