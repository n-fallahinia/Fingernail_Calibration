function test_assemble_parameters_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx )
%   Assembles the matrices (pixel, force, shape, texture and appearance) for
%   use in calibrating all of the different models.
%   Only for calibration files!!!

% clear;
% clc;
% close all;
% 
% % Define parameters
% subjectIdx = 2;
% typeIdx = 3;
% fingerIdx = 2;
% colorIdx = 1;
sizeIdx = 1;
always_regenerate = true;

% Define constants
size_names = {'', '_med', '_small', '_tiny', '_mini', '_regsides', '_sides','_gray', '_red', '_green', '_blue','_nail'};
size_strings = {'Standard','Medium','Small','Tiny','Mini','Register Sides','Convert Sides','Gray','Red','Green','Blue','Nail Only'};
num_sizes = length(size_names);
color_names = {'white','green'};
finger_names = {'thumb','index','middle','ring'};
if (colorIdx == 2)
    color_channel = 'green';
    if (sizeIdx ~= 1)
        error('Cannot have sizeIdx ~= 1 if processing Green LED data!');
    end
elseif (sizeIdx == 9)
    color_channel = 'red';
elseif (sizeIdx == 11)
    color_channel = 'blue';
else
    color_channel = 'green';
end
%addpath('c:\fingerdata\finger_asm\matlab\asm');
fprintf('Processing %02d/%s/%s/%s\n', subjectIdx, finger_names{fingerIdx}, color_names{colorIdx}, size_strings{sizeIdx});

% Define data folders
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);
param_file = sprintf('%s/params%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);

% Load options structure and update options
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
load(options_file);
options.debug_mode = false;
options.verbose = true;
options.color_channel = color_channel;

% Load list of image files (Look for raw matlab files first)
files_filename = sprintf('%s/files%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
load(files_filename);
num_files = length(files);

aligned_dates = inf(num_files, 1);
if (~always_regenerate)
    % Get dates on all Aligned Image files
    fprintf('Checking dates on all aligned image files.');
    for fileIdx = 1:num_files
        if (mod(fileIdx, 25) == 0)
            fprintf('.');
        end
        file_dir = dir(files(fileIdx).aligned_image);
        if (~isempty(file_dir))
            aligned_dates(fileIdx) = file_dir.datenum;
        end
    end % fileIdx
    if (any(isinf(aligned_dates)))
        fprintf('\n\tSome Aligned Image files have not been generated!\n');
        not_generated = find(isinf(aligned_dates));
        num_not = length(not_generated);
        fprintf('\t');
        for notIdx = 1:num_not
            fprintf('%04d ', not_generated(notIdx));
            if (mod(notIdx,5) == 0)
                fprintf('\n\t');
            end
        end % notIdx
        fprintf('\nEnding program\n');
        error('Not all aligned images have been generated!');
    else
        fprintf('Done!\n');
    end
end

% Load array of points
points_file = sprintf('%s/points%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
points_dir = dir(points_file);
if (isempty(points_dir))
    error('Points Array file does not exist!');
end
load(points_file);
if (size(pts_array, 2) ~= num_files)
    error('Size of Points Array does not match Files list!');
end
temp = sum(abs(pts_array), 1);
options.eliminate = (temp == 0);

% Load AAM data file
data_file = sprintf('%s/data%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
if (~exist(data_file,'file'))
    error('AAM data file does not exist!');
end
load(data_file);
if (length(ShapeData.x_mean) ~= size(pts_array, 1))
    error('Size of Points Array does not match ShapeData structure!');
end
load(files(1).aligned_image);
if (size(TextureData.ObjectPixels,1) ~= size(imgAligned, 1))
    error('Size of aligned image does not match TextureData structure!');
end

% Check date on parameter file
param_dir = dir(param_file);
if ((~isempty(param_dir)) && (max(aligned_dates) < param_dir.datenum) && (points_dir.datenum < param_dir.datenum))
    fprintf('\tLoading parameter matrix data');
    load(param_file);
    
    % Verify file contents are correct size
    if (size(force_matrix, 1) == num_files)
        is_good = true;
    else
        fprintf('\n\t\tForce matrix has too few images!');
        is_good = false;
    end
    if (size(shape_matrix, 1) ~= num_files)
        fprintf('\n\t\tShape matrix has too few images!');
        is_good = false;
    end
    if (size(shape_matrix, 2) ~= length(ShapeData.Evalues))
        fprintf('\n\t\tShape matrix has too few parameters!');
        is_good = false;
    end
    if (size(texture_matrix, 1) ~= num_files)
        fprintf('\n\t\tTexture matrix has too few images!');
        is_good = false;
    end
    if (size(texture_matrix, 2) ~= length(TextureData.Evalues))
        fprintf('\n\t\tTexture matrix has too few parameters!');
        is_good = false;
    end
    if (size(appearance_matrix, 1) ~= num_files)
        fprintf('\n\t\tAppearance matrix has too few images!');
        is_good = false;
    end
    if (size(appearance_matrix, 2) ~= length(AppearanceData.Evalues))
        fprintf('\n\t\tAppearance matrix has too few parameters!');
        is_good = false;
    end
    
    if (is_good)
        fprintf('...Done!\n');
    else
        % Assemble the parameter data
        fprintf('\n\tAssembling parameter matrix data');
        [force_matrix, shape_matrix, texture_matrix, appearance_matrix] = assemble_param_data(files, pts_array, ShapeData, TextureData, AppearanceData, options);
        fprintf('.');
        
        % Correct for thumb rotation, if needed
        if (fingerIdx == 1)
            temp = force_matrix(:,1);
            force_matrix(:,1) = force_matrix(:,3);
            force_matrix(:,3) = -temp;
        end
        
        % Save the data
        save(param_file,'force_matrix','shape_matrix','texture_matrix','appearance_matrix');
        fprintf('Done!\n\tData loaded (%d Images, %d Forces, %d Shapes, %d Textures, %d Appearances)\n', size(force_matrix,1), size(force_matrix,2), size(shape_matrix,2), size(texture_matrix,2), size(appearance_matrix,2));
    end
else
    % Assemble the parameter data
    fprintf('Assembling parameter matrix data');
    [force_matrix, shape_matrix, texture_matrix, appearance_matrix] = assemble_param_data(files, pts_array, ShapeData, TextureData, AppearanceData, options);
    fprintf('.');
    
    % Correct for thumb rotation, if needed
    if (fingerIdx == 1)
        temp = force_matrix(:,1);
        force_matrix(:,1) = force_matrix(:,3);
        force_matrix(:,3) = -temp;
    end
    
    % Save the data
    save(param_file,'force_matrix','shape_matrix','texture_matrix','appearance_matrix');
    fprintf('Done!\n\tData loaded (%d Images, %d Forces, %d Shapes, %d Textures, %d Appearances)\n', size(force_matrix,1), size(force_matrix,2), size(shape_matrix,2), size(texture_matrix,2), size(appearance_matrix,2));
end

% Display the forces and Shape/Texture/Appearance parameters, if desired
if (options.verbose)
    fig_params = plot_aam_params(force_matrix, shape_matrix, texture_matrix, appearance_matrix, options);
end



end

