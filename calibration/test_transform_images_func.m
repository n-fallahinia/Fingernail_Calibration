function test_transform_images_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
% Transforms (aligns) all images to the template image, using a piecewise
% linear warp.  The template image is specified in the structure
% TextureData, by the fields ObjectPixels (a binary mask image) and
% base_points (the coordinates of the shape points).
% 
% Define certain properties
% subjectIdx = 2;
% typeIdx = 5;
% fingerIdx = 2;
% colorIdx = 1;
sizeIdx = 1;
always_regenerate = true;

% Define constants
size_names = {'', '_med', '_small', '_tiny', '_mini', '_regsides', '_sides','_gray', '_red', '_green', '_blue', '_nail'};
size_strings = {'Standard','Medium','Small','Tiny','Mini','Register_Sides','Convert_Sides','Gray','Red','Green','Blue','Nail Only'};
num_sizes = size_names;
color_names = {'white','green'};
finger_names = {'thumb','index','middle','ring'};

% Add AAM functions to the path
%find_asm_folder();

% Define data folders
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);
points_file = sprintf('%s/points%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);

% If necessary, create the aligned image folder
aligned_folder = sprintf('%s/aligned%s', base_folder, size_names{sizeIdx});
if (~exist(aligned_folder, 'dir'))
    [success, msg, msgID] = mkdir(aligned_folder);
    if (~success)
        error('Could not create aligned folder [%s] (%s:%s)', aligned_folder, msgID, msg);
    end
end

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
 data_dir = dir(data_file);
 if (isempty(data_dir))
    error('No AAM data file detected!');
 end
 load(data_file);
 num_pixels = numel(TextureData.ObjectPixels);

% Load the AAM model
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
load(options_file);
options.aam_date = data_dir.datenum;
options.debug_mode = false;
options.verbose = true;

% Load the list of image files
files_filename = sprintf('%s/files%s_%02d.mat', data_folder, size_names{sizeIdx}, subjectIdx);
load(files_filename);
num_files = length(files);

% Check file dates
points_dir = dir(points_file);
if ((~isempty(points_dir)) && (options.aam_date < points_dir.datenum))
    % Load the array of points
    load(points_file);
    fprintf('Processing %02d/%s/%s/%s\n', subjectIdx, finger_names{fingerIdx}, color_names{colorIdx}, size_strings{sizeIdx});
    if (always_regenerate)
        options.aam_date = Inf;
    end
    
    % Transform all images
    fprintf('\tTransforming images...');
    success = transform_all_images(files, pts_array, TextureData.base_points, ShapeData.TextureSize, ShapeData.Tri, options);
    if (success)
        fprintf('Done!\n');
    else
        fprintf('\n\tSomething went wrong when transforming the images!\n');
    end
else
    error('Points array file is too old or does not exist!\n');
end
if (always_regenerate)
    msgbox('Finished');
end


end

