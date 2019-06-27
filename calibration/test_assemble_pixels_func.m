function test_assemble_pixels_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
% Assembles the matrices (pixel, force, shape, texture and appearance) for
%   use in calibrating all of the different models.
% 

% clear;
% clc;
% close all;

% Define parameters
% subjectIdx = 2;
% typeIdx = 3;
% fingerIdx = 2;
% colorIdx = 1;
sizeIdx = 1;
always_regenerate = true;

% Define parameter specifications
size_names = {'', '_med', '_small', '_tiny', '_mini', '_regsides', '_sides','_gray', '_red', '_green', '_blue','_nail'};
size_strings = {'Standard','Medium','Small','Tiny','Mini','Register Sides','Convert Sides','Gray','Red','Green','Blue','Nail Only'};
num_sizes = length(size_names);
color_names = {'white','green'};
finger_names = {'thumb','index','middle','ring'};
if ((colorIdx == 1) && (sizeIdx == 1))
    resolutions = [10:10:50 100:100:1000];
else
    resolutions = [10 50];
end
num_resolutions = length(resolutions);

% Define data folders
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);

% If necessary, change the base folder for data file
if typeIdx == 4 
    base_folder_amm = strrep(base_folder,'exp/test_02','cal'); 
    data_folder_aam = sprintf('%s/data', base_folder_amm);
end

 % Load the AAM model
 if typeIdx == 4
    data_file = sprintf('%s/data%s_%02d.mat', data_folder_aam, size_names{sizeIdx}, subjectIdx);
 else
    data_file = sprintf('%s/data%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);   
 end

% Load options structure and update options
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
load(options_file);
options.debug_mode = false;
options.verbose = true;

% Load the AAM Model data
size_name = size_names{sizeIdx};
fprintf('Processing %02d/%s/%s/%s\n', subjectIdx, finger_names{fingerIdx}, color_names{colorIdx}, size_strings{sizeIdx});
load(data_file);

% Check native resolution of the mask image
max_reso = max(size(TextureData.ObjectPixels));
if (max(resolutions) > max_reso)
    % Reduce the resolutions array accordingly
    resolutions(resolutions > max_reso) = [];
    if typeIdx == 4
       resolutions = resolutions(end);
    end
    % Re-calculate the number of resolutions
    num_resolutions = length(resolutions);
end

% Load list of image files
aligned_files = sprintf('%s/files%s_%02d.mat', data_folder, size_name, subjectIdx);
load(aligned_files);
num_files = length(files);

aligned_dates = inf(num_files,1);
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

for resolutionIdx = 1:num_resolutions
    % Get the active pixels for the model
    resolution = resolutions(resolutionIdx);
    options.approx_size = resolution*[1 1];
    fprintf('\tResolution %02d - Assembling pixel matrix data.', resolution);
    pixel_file = sprintf('%s/matrices%s_%02d_%03d.mat', data_folder, size_name, subjectIdx, resolution);
    fprintf('.');
    
    % Check date on pixel file
    pixel_dir = dir(pixel_file);
    if ((~isempty(pixel_dir)) && (max(aligned_dates) < pixel_dir.datenum))
        % Resize mask image
        temp_mask = imresize(TextureData.ObjectPixels, options.approx_size);
        num_pixels = sum(temp_mask(:));
        
        % Load the file
        fprintf('Loading pixel data\n');
        load(pixel_file);
        
        % Verify file contents are correct size
        if (size(pixel_matrix, 1) == num_files)
            is_good = true;
        else
            fprintf('\tPixel matrix has too few images!\n');
            is_good = false;
        end
        if (size(pixel_matrix, 2) ~= num_pixels)
            fprintf('\tPixel matrix has too few pixels!\n');
            is_good = false;
        end
        if (numel(mask_image) ~= numel(temp_mask))
            fprintf('\tMask image has too few pixels!\n');
            is_good = false;
        end
        
        if (is_good)
            % Clear pixel_matrix and mask_image for the next resolution
            clear pixel_matrix mask_image;
        else
            % Assemble the pixel data
            fprintf('\tReading pixel data');
            [pixel_matrix, mask_image] = assemble_pixel_data(files, TextureData.ObjectPixels, options);
            fprintf('.');
            
            % Save the data
            save(pixel_file,'pixel_matrix','mask_image');
            fprintf('Done!\n\t\tData loaded (%d Images, %d Pixels)\n', size(pixel_matrix,1), size(pixel_matrix,2));
        end
    else
        % Assemble the model data
        [pixel_matrix, mask_image] = assemble_pixel_data(files, TextureData.ObjectPixels, options);
        fprintf('.');
        
        % Save the data
        save(pixel_file,'pixel_matrix','mask_image');
        fprintf('Done!\n\tData loaded (%d Images, %d Pixels)\n', size(pixel_matrix,1), size(pixel_matrix,2));
    end
end % resolutionIdx

end

