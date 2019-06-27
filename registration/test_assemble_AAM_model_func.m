function test_assemble_AAM_model_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
% Assembles an Active Appearance Model (AAM) structure and saves this model
% to a file.  The model consists of a Shape Model (ShapeData) and a Texture
% Model (AppearanceData), used by the Matlab package
% 'ActiveModels_version7'.  This code is based on the code found in that
% package called 'AAM_2D_example.m' created by D.Kroon of the University of
% Twente.  Since this model is not intended to be used for anything except
% transforming training images, the Appearance Data (ShapeAppearanceData)
% and Search Model (R) are not created.
% 

fprintf('###################################################\n')
fprintf('# ASSEMBLING AMM MODEL BEEN STARTED FOR SUBJECT_%d #\n', subjectIdx)
fprintf('###################################################\n')
% pause(5);

% Define certain properties
% subjectIdx = 2;
% typeIdx = 5;
% fingerIdx = 2;
% colorIdx = 1;
sizeIdx = 1;
always_regenerate = true;

% Create parameters
eigen_names = {'First','Second','Third'};
size_names = {'', '_med', '_small', '_tiny', '_mini', '_regsides', '_sides','_gray', '_red', '_green', '_blue', '_nail'};
size_strings = {'Standard','Medium','Small','Tiny','Mini','Register_Sides','Convert_Sides','Gray','Red','Green','Blue','Nail Only'};
num_sizes = size_names;
finger_names={'thumb','index','middle','ring'};
color_names = {'white','green'};

% Display current processing value
fprintf('Processing Subject %d/%s/%s/%s\n', subjectIdx, finger_names{fingerIdx}, color_names{colorIdx}, size_strings{sizeIdx});

% Color channel to use for these images
if (colorIdx == 2)
    color_channel = 'green';
    if (sizeIdx ~= 1)
        fprintf('Changing size back to %s--Cannot process anything else for %s LED data!', size_strings{1}, color_names{colorIdx});
        sizeIdx = 1;
    end
elseif (sizeIdx == 9)
    color_channel = 'red';
elseif (sizeIdx == 11)
    color_channel = 'blue';
else
    color_channel = 'green';
end
triangle_sides = ((sizeIdx == 6) || (sizeIdx == 7));

%%%%%%%%%%%%%%%%%%%%%%% Commented Part %%%%%%%%%%%%%%%
% Add AAM functions to the path
%find_asm_folder();
%addpath('E:\PhD\fingerdata\finger_asm\matlab\asm');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define data folders
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);
models_folder = sprintf('%s/models', base_folder);
model_file = sprintf('%s/fingers%s_%02d.smd', models_folder, size_names{sizeIdx}, subjectIdx);
files_filename = sprintf('%s/files%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
training_file = sprintf('%s/training%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
data_file = sprintf('%s/data%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);

% Load the list of image files
load(files_filename);

% Load the options file and modify any desired options
load(options_file);
options.m = 3; % Set normal appearance/contour limit to +- m*sqrt( eigenvalue )
options.texturesize = 1; % Size of appearance texture as amount of original image
options.scale_factor = 1.0; % Scale training images by this factor
options.use_selected = true; % Only use the selected files
options.load_images = true; % Load the images into the TrainingData structure
save(options_file, 'options');
options.color_channel = color_channel;
options.triangle_sides = triangle_sides;

% Read the contour data
[~, file_names] = read_model_file(model_file);
%clear training_images;
options.contour_array = load_contour_array(sprintf('%s/%s', models_folder, file_names.contours));

% Options for displaying debugging information
options.verbose = true;
options.debug_mode = false;

% Makes write_tri_file ask whether to overwrite existing file
options.check_file_existence = true;

% Options for displaying the modes of variation
options.num_modes = 3;
options.num_imgs = 5;

% Extract the selected images' dates
num_calib = length(options.selected_files);
selected_dates = zeros(num_calib, 1);
for calibIdx = 1:num_calib
    temp = dir(files(options.selected_files(calibIdx)).points_file);
    selected_dates(calibIdx) = temp.datenum;
end % calibIdx

% Verify that training data file needs to be re-created
if ((~exist(training_file,'file')) || (always_regenerate))
    training_dir = [];
else
    training_dir = dir(training_file);
    training_data = whos('TrainingData','-file',training_file);
    if (prod(training_data.size) ~= num_calib)
        training_dir = [];
    end
end
if ((isempty(training_dir)) || (training_dir.datenum < max(selected_dates)))
    % Load the just the hand-selected training data and save it for later use
    fprintf('Creating model Training Data');
    TrainingData = load_training_data(files, options);
    fprintf('Done!\n');
    
    % Save the data
    save(training_file,'TrainingData');
    training_dir = dir(training_file);
else
    fprintf('Loading Training Data file');
    load(training_file);
    fprintf('\n');
end

% Verify that AAM Model data file needs to be re-created
if (always_regenerate)
    data_dir = [];
else
    data_dir = dir(data_file);
end
if (~isempty(data_dir))
    % Load the Shape Data and check for "Triangles" field
    load(data_file,'ShapeData');
    if (~isfield(ShapeData,'Tri'))
        data_dir = [];
    else
        % Verify that the TextureData field exists
        if (isempty(who('TextureData','-file',data_file)))
            data_dir = [];
        else
            load(data_file,'AppearanceData');
            if (~isfield(AppearanceData,'Ws'))
                data_dir = [];
            end
        end
    end
end
if ((isempty(data_dir)) || (data_dir.datenum < training_dir.datenum))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make the Shape model, which finds the variations between contours
    % in the training data sets. And makes a PCA model describing normal
    % contours
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Making the Shape Model\n');
    [ShapeData, TrainingData] = form_shape_model(TrainingData,options);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make the Gray-Level Texture model
    % Piecewise linear image transformation is used to align all texture
    % information inside the object (hand), to the mean handshape.
    % After transformation of all trainingdata textures to the same shape
    % PCA is used to describe the mean and variances of the object texture.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Making the Texture Model\n');
    TextureData = form_gray_model(TrainingData, ShapeData, options);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make the Combined Appearance model
    % The Shape and Texture parameters of the TrainingData are combined in
    % a weighted vector to form a new model showing the combined variation
    % of both position and gray-level intensity.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Making the Appearance Model\n');
    AppearanceData = form_combined_model(TrainingData, ShapeData, TextureData, options);
    
    % Save the model
    save(data_file, 'TrainingData', 'ShapeData', 'TextureData', 'AppearanceData');
    data_dir = dir(data_file);
else
    fprintf('Loading AAM data file');
    try
        load(data_file,'ShapeData','AppearanceData');
    catch exception
        if (~exist('AppearanceData','var'))
            fprintf('\nAAM data file is old.  Regenerating\n');
            fprintf('Making the Shape Model\n');
            [ShapeData, TrainingData] = form_shape_model(TrainingData,options);
            fprintf('Making the Texture Model\n');
            TextureData = form_gray_model(TrainingData, ShapeData, options);
            fprintf('Making the Appearance Model\n');
            AppearanceData = form_combined_model(TrainingData, ShapeData, TextureData, options);
            save(data_file, 'ShapeData', 'TextureData', 'AppearanceData');
            data_dir = dir(data_file);
        else
            rethrow(exception);
        end
    end
    fprintf('\n');
end

% Generate name of the triangles file
if (~exist('file_names','var'))
    [training_images, file_names] = read_model_file(model_file);
end
triangles_file = sprintf('%s/%s', models_folder, file_names.triangles);

% Define sizes for which the .TRI never needs to be regenerated--the
% color-channel registration and the 'register sides' methods
regen_tri = ((sizeIdx ~= 6) && (sizeIdx < 8));

% Generate a .TRI file if the date of the .TRI file is after the data file
% Determine the date of the triangle file
if (always_regenerate)
    triangles_dir = [];
else
    triangles_dir = dir(triangles_file);
end
if ((isempty(triangles_dir)) || ((regen_tri) && (triangles_dir.datenum < data_dir.datenum)))
    % Generate the triangle file
    success = write_tri_file(triangles_file, ShapeData.Tri, options);
    if (~success)
        fprintf('Triangles file not written successfully!\n');
    end
else
    fprintf('Triangles file was generated after AAM data file!\n');
end

% Display the AAM model several ways
if ((options.verbose) && (options.debug_mode))
    figure_ID = display_AAM_model(ShapeData, TextureData, options);
    fig_shape = display_shape_modes(ShapeData, TextureData, options);
    fig_tex = display_gray_modes(TextureData, options);
    fig_app = display_appearance_modes(ShapeData, TextureData, AppearanceData, options);
end

fprintf('###############################################\n')
fprintf('# ASSEMBLING AMM MODEL HAS BEEN SEUCCESSFULLY #\n') 
fprintf('#           COMPLETED FOR SUBJECT_%d           #\n', subjectIdx)
fprintf('###############################################\n')

end

