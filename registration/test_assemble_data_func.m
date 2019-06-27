
function test_assemble_data_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)

% Create "SMD Model" file and "To-Do List" file given an already-existing
% set of calibration data.

% Define parameters
% subjectIdx = 2;
% typeIdx = 3;
% fingerIdx = 2;
% colorIdx = 1;
% testIdx = 1;
% grasp_exp = true

fprintf('################################################\n')
fprintf('# DATA ASSEMBLY HAS BEEN STARTED FOR SUBJECT_%d #\n', subjectIdx)
fprintf('################################################\n')

pause(5);

% Define data types
type_names = {'manual','indiv','grasp_cal','grasp_exp','aam_compare','aam_compare'};
num_types = length(type_names);
finger_names = {'thumb','index','middle','ring','little'};
num_fingers = length(finger_names);
led_colors = {'w','g'};
num_colors = length(led_colors);

% Load subject data
[zero_folder, work_computer] = find_base_folder();
old_folder = sprintf('%s/finger_asm', zero_folder);
matlab_path = sprintf('%s/matlab', zero_folder);
% if (~exist(matlab_path, 'dir'))
%     matlab_path = sprintf('%s/matlab', zero_folder);
% end
% addpath(matlab_path);

% Define data folders
switch(typeIdx)
    case 1 % Yu Sun's Manual 1-D Calibration
        % Generate new base folder name
        base_folder = sprintf('%s\\yuSun_%03d', old_folder, subjectIdx);
        
        % Assemble the file data for this subject
        load(sprintf('%s\\data\\subject_data.mat', old_folder));
        old_base = sprintf('%s\\yuSun\\fingerinput\\%s', zero_folder, subjects(subjectIdx).name);
        options.rotation_matrix = subjects(subjectIdx).rotation;
        options.data_type = 'EigenNail';
        old_files = assemble_file_data(old_base, options);
        fprintf('##### %d IMAGES HAVE BEEN SEUCCESSFULLY PROCESSED #####\n', length(old_files))
    case 2 % Automated 3-D Calibration
        base_folder = sprintf('%s\\indiv_%02d', old_folder, subjectIdx);
        
        % Assemble the file data for this subject
        old_base = sprintf('%s\\finger_data\\individual\\subj_%03d', zero_folder, subjectIdx);
        options.data_type = 'individual';
        old_files = assemble_file_data(old_base, options);
        fprintf('##### %d IMAGES HAVE BEEN SEUCCESSFULLY PROCESSED #####\n', length(old_files))
    case 3 % Grasping Calibration
        base_folder = sprintf('%s/grasp_%02d/%s_cal', old_folder, subjectIdx, finger_names{fingerIdx});
        
        % Assemble the file data for this subject
        old_base = sprintf('%s/finger_data/grasping/subj_%03d/grasping_calibration', zero_folder, subjectIdx);
        options.data_type = 'grasping_cal';
        options.finger_name = finger_names{fingerIdx};
        options.is_calibration = true;
        options.debug_mode = true; %##### DEBUG MODE OPTION ####%
        old_files = assemble_file_data(old_base, options);
        fprintf('##### %d CALIBRATION IMAGES HAVE BEEN SEUCCESSFULLY PROCESSED #####\n', length(old_files))
    case 4 % Grasping Experiment
        base_folder = sprintf('%s/grasp_%02d/%s_exp/test_%02d', old_folder, subjectIdx, finger_names{fingerIdx}, testIdx);
        
        % Assemble the file data for this subject
        old_base = sprintf('%s/finger_data/grasping/subj_%03d/grasping_experiment', zero_folder, subjectIdx);
        if (~exist(old_base,'dir'))
            error('Test folder does not exist! (%s)', old_base);
        end
        options.data_type = 'grasping_exp';
        options.finger_name = finger_names{fingerIdx};
        options.is_calibration = false;
        old_files = assemble_file_data(old_base, options, testIdx);
        fprintf('##### %d IMAGES HAVE BEEN SEUCCESSFULLY PROCESSED #####\n', length(old_files))
    case 5 % AAM Comparison Data
        base_folder = sprintf('%s\\aam_%02d\\%s_cal', old_folder, subjectIdx, finger_names{fingerIdx});
        
        % Assemble the file data for this subject
        old_base = sprintf('%s\\finger_data\\aam_compare\\subj_%03d', zero_folder, subjectIdx);
        options.data_type = 'aam_compare';
        options.finger_name = finger_names{fingerIdx};
        old_files = assemble_file_data(old_base, options);
        fprintf('##### %d IMAGES HAVE BEEN SEUCCESSFULLY PROCESSED #####\n', length(old_files))
    case 6 % AAM Comparison Data, Version 2 (White & Green Light)
        base_folder = sprintf('%s\\dis_%02d\\%s_cal_%s', old_folder, subjectIdx, finger_names{fingerIdx}, led_colors{colorIdx});
        
        % Assemble the file data for this subject
        old_base = sprintf('%s\\aam_compare\\aam_%02d', zero_folder, subjectIdx);
        options.data_type = 'dis_aam';
        options.finger_name = finger_names{fingerIdx};
        options.led_color = led_colors{colorIdx};
        old_files = assemble_file_data(old_base, options);
        fprintf('##### %d IMAGES HAVE BEEN SEUCCESSFULLY PROCESSED #####\n', length(old_files))
    otherwise
        error('Unknown data type!');
end

if typeIdx == 4
    base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
else
    base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx);
end

if typeIdx == 4
    data_folder = sprintf('%s/data', base_folder);
    models_folder = sprintf('%s/models', base_folder);
    images_folder = sprintf('%s/images', base_folder);
    points_folder = sprintf('%s/points', base_folder);
    aligned_folder = sprintf('%s/aligned', base_folder);
    options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
    files = struct('original_image',[],'aligned_image',[],'points_file',[]);
else
    data_folder = sprintf('%s/data', base_folder);
    models_folder = sprintf('%s/models', base_folder);
    images_folder = sprintf('%s/images', base_folder);
    points_folder = sprintf('%s/points', base_folder);
    aligned_folder = sprintf('%s/aligned', base_folder);
    params_folder = sprintf('%s/params', base_folder);
    options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
    files = struct('original_image',[],'aligned_image',[],'shape_file',[],'gray_file',[],'model_file',[],'points_file',[],'force',[]);
end

% Create the necessary folders
success = create_folders(base_folder, typeIdx);
if (~success)
    error('Could not create all folders!');
end

% Load options structure and update options
if (exist(options_file,'file'))
    temp = options;
    fields = fieldnames(temp);
    num_fields = length(fields);
    load(options_file);
    for fieldIdx = 1:num_fields
        options.(fields{fieldIdx}) = temp.(fields{fieldIdx});
    end % fieldIdx
end
options.default_position = [46 46 1000 750];
if options.is_calibration == false
    options.is_grasp_exp = true;
else
    options.is_grasp_exp = false;
end 
save(options_file, 'options');

% Read file list
num_files = length(old_files);
is_thumb = (fingerIdx == 1);

fprintf('Start saving raw images to the image folder \n');
pause(1);

% Copy each file to the images folder
for fileIdx = num_files:-1:1
    % Set a counter every 5 images
    if (mod(fileIdx,5) == 0)
        tic;
    end
    
    % Define the image and points file names
    image_name = sprintf('img_%02d_%04d.jpg', subjectIdx, fileIdx);
    points_name = sprintf('img_%02d_%04d.pts', subjectIdx, fileIdx);
    image_destination = sprintf('%s/%s', images_folder, image_name);
    points_destination = sprintf('%s/%s', points_folder, points_name);
    
    if typeIdx == 4
        % Generate the file structure for retrieving image information
        files(fileIdx).original_image = image_destination;
        files(fileIdx).aligned_image = sprintf('%s/aligned_%04d.mat', aligned_folder, fileIdx);
        files(fileIdx).points_file = points_destination;
    else
        % Generate the file structure for retrieving image information
        files(fileIdx).original_image = image_destination;
        files(fileIdx).aligned_image = sprintf('%s/aligned_%04d.mat', aligned_folder, fileIdx);
        files(fileIdx).shape_file = sprintf('%s/%s.b_shape', params_folder, image_name(1:(end-4)));
        files(fileIdx).gray_file = sprintf('%s/%s.b_tex', params_folder, image_name(1:(end-4)));
        files(fileIdx).model_file = sprintf('%s/%s.b_app', params_folder, image_name(1:(end-4)));
        files(fileIdx).points_file = points_destination;
    end
    
    % Read the image
%     try
%         load(old_files(fileIdx).name);
%     catch exception
%         if ((strcmp(exception.identifier,'MATLAB:imread:fileFormat')) || (strcmp(exception.identifier,'MATLAB:load:numColumnsNotSame')))
    imgIn = imread(old_files(fileIdx).name);
%         end
%     end
    
    % Extract the force from the image
    if ~(options.is_grasp_exp) 
        files(fileIdx).force = read_force(imgIn(1,1:2,:), is_thumb);
    end
    
    % Condition the image, if needed
    if ((typeIdx == 6) && (colorIdx == 2))
        % If using dissertation files and green-light images, re-create the
        % images as "green channel"-only images
        imgIn(:,:,1) = imgIn(:,:,2);
        imgIn(:,:,3) = imgIn(:,:,2);
    end
    
    % Write the image to the images folder
    imwrite(imgIn, image_destination);
    
    % Print a message every 5 images
    if (mod(fileIdx,5) == 0)
        t = toc;
        fprintf('\t%04d | %5.2f seconds\n', fileIdx, t);
    end
end % fileIdx

% Save the files structure
files_filename = sprintf('%s/files_%02d.mat', data_folder, subjectIdx);
save(files_filename, 'files');
fprintf('################################################################\n')
fprintf('# DATA ASSEMBLY HAS BEEN SEUCCESSFULLY COMPLETED FOR SUBJECT_%d #\n', subjectIdx)
fprintf('################################################################\n')

end

