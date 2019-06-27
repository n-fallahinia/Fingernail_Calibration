function test_verify_aam_registration_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
% Verifies that AAM Registration has successfully processed all images,
% resulting in the following:
% 
%   (1) All files have been read into the .SMD file
%   (2) The image file corresponds to the points file in the .SMD file
%   (3) All points files have been created
%   (4) All points are inside the image boundaries
% 
% In addition, this script creates the training_xx.mat file, which contains
% the TrainingData structure that will be required to create the AAM model,
% for the assemble_AAM_model script.
% 

% Define certain properties
% subjectIdx = 2;
% typeIdx = 3;
% fingerIdx = 2;
% colorIdx = 1;
sizeIdx = 1;
always_regenerate = true;

% Define constants
size_names = {'', '_med', '_small', '_tiny', '_mini', '_regsides', '_sides','_gray', '_red', '_green', '_blue', '_nail'};
size_strings = {'Standard','Medium','Small','Tiny','Mini','Register_Sides','Convert_Sides','Gray','Red','Green','Blue','Nail Only'};
num_sizes = size_names;
finger_names={'thumb','index','middle','ring'};
color_names = {'white','green'};

% Display current processing value
fprintf('Processing Subject %d/%s/%s/%s\n', subjectIdx, finger_names{fingerIdx}, color_names{colorIdx}, size_strings{sizeIdx});

% Define data folders
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);
points_folder = sprintf('%s/points%s', base_folder, size_names{sizeIdx});
model_folder = sprintf('%s/models', base_folder);
images_folder = sprintf('%s/images', base_folder);
files_filename = sprintf('%s/files%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
model_file = sprintf('%s/fingers%s_%02d.smd', model_folder, size_names{sizeIdx}, subjectIdx);
points_file = sprintf('%s/points%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);

% Load the options file and modify any desired options
if (~exist(options_file, 'file'))
    error('Options data file does not exist!');
end
load(options_file);
options.verbose = true; % If verbose is true all debug images will be shown.
options.scale_factor = 1.0; % Scale training images by this factor
options.use_selected = true; % Only use the selected files
options.load_images = true; % Load the images into the TrainingData structure

% Load the list of image files
files_dir = dir(files_filename);
if (isempty(files_dir))
    error('Files data file does not exist!');
end
load(files_filename);
num_files = length(files);

% Only for calibration 
if typeIdx ~= 4 
    % Check the date on AAM model
    data_file = sprintf('%s/data%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
    data_dir = dir(data_file);
    if (isempty(data_dir))
        error('No AAM data file detected!');
    end
    % Read the model file
    model_dir = dir(model_file);
    if (isempty(model_dir))
        error('Model file (.SMD) does not exist!');
    end
    [training_images, file_names] = read_model_file(model_file);
    contour_file = sprintf('%s/%s', model_folder, file_names.contours);
    if (~exist(contour_file,'file'))
        error('Contour file (.PARTS) does not exist!');
    end
    options.contour_array = load_contour_array(contour_file);
    num_training = length(training_images);
else
    training_images = read_exp_file(images_folder, points_folder);
    num_training = length(training_images);
    eliminate = false(num_training,1);
end

% Get dates on all .PTS files
fprintf('Checking dates on all .PTS files.');
points_dates = inf(num_files, 1);
for fileIdx = 1:num_files
    if (mod(fileIdx, 25) == 0)
        fprintf('.');
    end
    file_dir = dir(files(fileIdx).points_file);
    if (~isempty(file_dir))
        points_dates(fileIdx) = file_dir.datenum;
    end
end % fileIdx
fprintf('\n');
if (any(isinf(points_dates)))
    fprintf('Some .PTS files have not been generated!\n');
    not_found_files = find(points_dates==inf);
    fprintf('%d point files have not been found\n',length(not_found_files))
end

% Check date on points array files
if (always_regenerate)
    points_dir = [];
else
    points_dir = dir(points_file);
end
if ((~isempty(points_dir)) && (max(points_dates) < points_dir.datenum) && (model_dir.datenum < points_dir.datenum) && (data_dir.datenum < points_dir.datenum))
    fprintf('Points array verified and generated after all necessary files!\n');
else
    % Load all of the training data points and save it for later use
    options.use_selected = false;
    options.load_images = false;
    fprintf('Reading all points files');
    pts_array = load_all_points(files, typeIdx, options);
    fprintf('Done!\n');
    num_points = size(pts_array,1)/2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % First check - Correct number of files read (Only for calibration)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if typeIdx ~= 4 
        fprintf('\n\nMissing/Duplicated Filenames:\n');
        if (num_training ~= num_files)
            fprintf('\t%04d images exist, %04d training images in SMD file\n', num_files, num_training);

            % Convert structure to numerical array
            eliminate = true(num_files,1);
            duplicate = false(num_files,1);
            for trainingIdx = 1:num_training
                imageIdx = str2double(training_images(trainingIdx).point_file(8:11));
                if (~eliminate(imageIdx))
                    duplicate(imageIdx) = true;
                end
                eliminate(imageIdx) = false;
            end % trainingIdx

            % Display duplicate file numbers
            duplicate_images = find(duplicate);
            num_duplicate = length(duplicate_images);
            if (num_duplicate ~= 0)
                fprintf('\t\t%d Duplicate Images:\n', num_duplicate);
                fprintf('\t\t\t');
                for duplicateIdx = 1:num_duplicate
                    fprintf('%04d ', duplicate_images(duplicateIdx));
                    if (mod(duplicateIdx,8) == 0)
                        fprintf('\n\t\t\t');
                    end
                end % missingIdx
                fprintf('\n');
            end

            % Display missing file numbers
            missing_images = find(eliminate);
            num_missing = length(missing_images);
            if (num_missing ~= 0)
                fprintf('\t\t%d Missing Images:\n', num_missing);
                fprintf('\t\t\t');
                for missingIdx = 1:num_missing
                    fprintf('%04d ', missing_images(missingIdx));
                    if (mod(missingIdx,8) == 0)
                        fprintf('\n\t\t\t');
                    end
                end % missingIdx
                fprintf('\n');
            end
        else
            eliminate = false(num_files,1);
            fprintf('\t<none>\n');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Second check - Verify that image file name matches point file name
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n\nFilename Mismatches (Points~=Image):\n');
    mismatch_count = 0;
    points_counter = 0;
        for trainingIdx = 1:num_training
            pts_name = training_images(trainingIdx-points_counter).point_file(1:11);
            img_name = training_images(trainingIdx).image_file(1:11);        
            if (~strcmp(pts_name, img_name))
                if typeIdx ~= 4 % for calibration
                    fprintf('\t%04d | %s : %s\n', trainingIdx, pts_name, img_name);
                    mismatch_count = mismatch_count + 1;
                else
                    fprintf('\t%04d | %s : %s\n', trainingIdx, pts_name, img_name)
                    mismatch_count = mismatch_count + 1;
                    points_counter = points_counter + 1;
                    eliminate(trainingIdx) = true;
                end
            end
        end % trainingIdx
        if (mismatch_count == 0)
            fprintf('\t<none>\n');
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Third check - Verify that all .PTS files are present
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if typeIdx ~= 4 
        pts_files = dir(sprintf('%s/img*.pts', points_folder));
        num_pts = length(pts_files);
        if (num_pts ~= num_training)
            fprintf('\n\nMissing .PTS Files:\n\t\t\t');
            missing_counter = 0;
            for trainingIdx = 1:num_training
                pts_name = sprintf('%s//%s', points_folder, training_images(trainingIdx).point_file);
                if (~exist(pts_name,'file'))
                    missing_counter = missing_counter + 1;
                    imageIdx = str2double(training_images(trainingIdx).point_file(8:11));
                    eliminate(imageIdx) = true;
                    fprintf('%04d ', imageIdx);
                    if (mod(missing_counter, 8) == 0)
                        fprintf('\n\t\t\t');
                    end
                end
            end % trainingIdx
            if (missing_counter == 0)
                fprintf('\t<none>\n');
            end
        end
    else
        missing_points = find(eliminate);
        num_missing = length(missing_points);
        if (num_missing ~= 0)
        fprintf('\t%d Missing .PTS Files:\n', num_missing);
        fprintf('\t\t');
            for missingIdx = 1:num_missing
                fprintf('%04d ', missing_points(missingIdx));
                if (mod(missingIdx,8) == 0)
                    fprintf('\n\t\t');
                end              
                
            end % missingIdx
            fprintf('\n');
            error('Correct the missing point files first !!!');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fourth check - Verify that points are inside image boundary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Find the size of the images (assumes all images are the same size)
    fprintf('\n\nPoints Outside Image Limits:\n');
    imgIn = imread(files(1).original_image);
    [num_rows, num_columns, num_colors] = size(imgIn);
    limits_counter = sum(eliminate);
    
    % Split into coordinates
    y_points = pts_array(1:num_points,:)/options.scale_factor;
    x_points = pts_array(num_points+1:end,:)/options.scale_factor;
    
    % Find values that are below the minimum
    [y_pt, y_min] = find((y_points < 0.5) & (y_points ~= 0));
    [x_pt, x_min] = find((x_points < 0.5) & (x_points ~= 0));
    y_min = unique(y_min);
    x_min = unique(x_min);
    eliminate(y_min) = true;
    eliminate(x_min) = true;
    
    % Find values that are above the maximum
    [y_pt, y_max] = find(y_points > num_rows+0.5);
    [x_pt, x_max] = find(x_points > num_columns+0.5);
    y_max = unique(y_max);
    x_max = unique(x_max);
    eliminate(y_max) = true;
    eliminate(x_max) = true;
    limits_counter = sum(eliminate) - limits_counter;
    
    % Print the list
    if (limits_counter == 0)
        fprintf('\t<none>\n');
    else
        img_list = [x_min; y_min; x_max; y_max];
        img_strIdx = [ones(size(x_min));ones(size(y_min));2*ones(size(x_max));3*ones(size(y_max))];
        img_strings = {'PtIdx < 1','Col > Max','Row > Max'};
        num_imgs = length(img_list);
        for imageIdx = 1:num_imgs
            fprintf('\t%04d | %s\n', img_list(imageIdx), img_strings{img_strIdx(imageIdx)});
        end % imageIdx
    end
    
    % Save the points array
    save(points_file,'pts_array');
    
    % Save the list of files to eliminate
    options.eliminate = eliminate;
    save(options_file,'options');
end

end

