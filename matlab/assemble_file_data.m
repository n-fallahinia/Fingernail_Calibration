% ASSEMBLE_FILE_DATA Creates lists of files and the associated force
% information in a particular folder.  Processes subfolders according to
% the options given.
% 
% Written by Navid Fallahinia
% Modified 20 June 2018 to allow assembling lists of grasping data
% University of Utah
%
% Steps for calibration:
% 
% 1. assemble_file_data
% 2. create_todo_lists
% 3. generate_points_file
% 4. smooth_data_spread
% 5. assemble_AAM_model
% 6. apply_AAM_all
% 7. calibrate_linearized_sigmoid_model
% 8. validate_linearized_sigmoid_model
% 

function file_list = assemble_file_data(base_folder, options, testIdx)

    % Determine data type
    if (nargin() == 1)
        [data_type, rotation_matrix, finger_name, is_calibration, led_color, debug_mode, options] = process_options([]);
    elseif (nargin() == 2) || (nargin() == 3)
        [data_type, rotation_matrix, finger_name, is_calibration, led_color, debug_mode, options] = process_options(options);
    else
        error('Must have 1, 2 or 3 inputs!');
    end
    
    % Assemble the file list using the appropriate function
    if (strcmp(data_type,'EigenNail'))
        file_list = assemble_EigenNail_files(base_folder, rotation_matrix, debug_mode);
    elseif (strcmp(data_type,'individual'))
        file_list = assemble_individual_files(base_folder, debug_mode);
    elseif (strcmp(data_type,'grasping_cal'))
        file_list = assemble_grasping_cal_files(base_folder, options.fingerIdx, is_calibration, debug_mode);
    elseif (strcmp(data_type,'grasping_exp'))
        file_list = assemble_grasping_exp_files(base_folder, options.fingerIdx, is_calibration, debug_mode, testIdx);        
    elseif (strcmp(data_type,'aam_compare'))
        file_list = assemble_aam_files(base_folder, options.fingerIdx, debug_mode);
    elseif (strcmp(data_type,'dis_aam'))
        file_list = assemble_dis_files(base_folder, options.fingerIdx, led_color, debug_mode);
    else
        error('Unknown data type!');
    end

end % assemble_file_data

% ASSEMBLE_EIGENNAIL_FILES Assembles a list of files based on the structure
% of the data in the original EigenNail experiments.  The images are
% organized into folders with names such as 'x-' and 'zero' to indicate the
% major direction of force exerted.  The forces are recorded in ASCII text
% files with names such as 'force1.dat' where each file contains 5 images'
% worth of force readings.
% 

function file_list = assemble_EigenNail_files(base_folder, rotation_matrix, debug_mode)

    % Define expected (default) folder names
    directions = {'x-','y-','zero','xy','x','y','z'};
    num_directions = length(directions);
    
    % Preallocate the output structure
    file_list = struct('name',{},'force',{});
    
    % Process each direction
    for directionIdx = 1:num_directions
        % Generate the current directional folder
        current_folder = sprintf('%s\\%s', base_folder, directions{directionIdx});
        if (~exist(current_folder,'dir'))
            continue;
        end
        
        % Generate list of all image files in the directional folder
        image_files = dir(sprintf('%s\\raw_*.mat', current_folder));
        num_images = length(image_files);
        
        % Generate list of all force files in the directional folder
        force_files = dir(sprintf('%s\\force*.dat', current_folder));
        num_forces = length(force_files);
        
        % Process each force file
        all_forces = zeros(num_images,3);
        startIdx = 0;
        for forceIdx = 1:num_forces
            % Read the current force file
            force_file = sprintf('%s\\%s', current_folder, force_files(forceIdx).name);
            if (~exist(force_file,'file'))
                keyboard;
            end
            current_force = load(force_file);

            % Verify that file is not empty
            num_entries = size(current_force,1);
            if (num_entries == 0)
                startIdx = startIdx + 5;
                continue;
            end
            if ((num_entries ~= 5) && ~((num_entries == num_images) && (forceIdx == 1)))
                keyboard;
            end

            % Add the current force data to the overall force data
            all_forces(startIdx+(1:num_entries),:) = current_force(:,1:3);
            startIdx = startIdx + num_entries;
        end % forceIdx
        if (startIdx < num_images)
            keyboard;
        end
        num_forces = size(all_forces,1);
        
        % Rotate the forces as needed
        all_forces = (rotation_matrix * (all_forces)')';
        
        % Create a structure to hold filenames and forces
        files = struct('name',{},'force',{});
        eliminate = false(num_forces,1);
        for imageIdx = num_forces:-1:1
            % Generate the name of the current image file
            image_file = sprintf('%s\\%s', current_folder, image_files(imageIdx).name);
            if (~exist(image_file,'file'))
                eliminate(imageIdx) = true;
                continue;
            end
            
            % Store the filename and force data
            files(imageIdx).name = image_file;
            files(imageIdx).force = all_forces(imageIdx,:);
        end % imageIdx
        
        % Remove nonexistent entries
        files(eliminate) = [];
        
        % Add files to the file_list structure
        file_list = [file_list files];
    end % directionIdx

end % assemble_EigenNail_files

% ASSEMBLE_INDIVIDUAL_FILES Assembles a list of files based on the
% structure of the data in the individual experiments.  The images are in
% folders named 'data_*'.  The forces are recorded in files named
% 'force.dat' or else in the images themselves (in which case they must be
% decoded using the read_force function).
% 

function file_list = assemble_individual_files(base_folder, debug_mode)

    % Define output structure
    file_list = struct('name',{},'force',{});
    fileIdx = 0;
    
    % Get a list of folders containing the finger name
    folders = dir(sprintf('%s\\data_*', base_folder));
    num_folders = length(folders);
    
    % Process each folder
    for folderIdx = 1:num_folders
        % Form the current folder name
        current_folder = sprintf('%s\\%s', base_folder, folders(folderIdx).name);
        if (~exist(current_folder,'dir'))
            error('Images does not exist! (%s)', current_folder);
        end
        
        % Get a list of image files within the folder
        images = dir(sprintf('%s\\raw_*.mat', current_folder));
        % ##########################
        if (~exist(images,'file'))
            error('images do not exist! (%s)', current_folder);
        end
        % ##########################
        num_images = length(images);
        
        % Look for a force file
        force_file = sprintf('%s\\force.dat', current_folder);
        if (exist(force_file,'file'))
            forces = textread(force_file);
            fprintf('\t\tForce data file found!');
            if (size(forces,1) ~= num_images)
                fprintf(' Wrong number of force entries, using image information!\n');
                read_forces = true;
            else
                fprintf(' Using force data!\n');
                read_forces = false;
            end
        else
            fprintf('\t\tNo force data file found!\n');
            read_forces = true;
        end
        
        % Process each image
        for imageIdx = 1:num_images
            % Form the current image name
            current_image = sprintf('%s\\%s', current_folder, images(imageIdx).name);
            if (~exist(current_image,'file'))
                error('Image does not exist! (%s)', current_image);
            end
            fileIdx = fileIdx + 1;
            if (mod(fileIdx,50) == 0)
                fprintf('Processed %d files\n', fileIdx);
            end
            
            % Save the image name to the structure
            file_list(fileIdx).name = current_image;
            
            % Extract the forces
            if (read_forces)
                % Load the image
                load(current_image);
                
                file_list(fileIdx).force = read_force(imgIn(1,1:2,:),false);
            else
                file_list(fileIdx).force = forces(imageIdx,:);
            end
        end % imageIdx
    end % folderIdx

end % assemble_individual_files

% ASSEMBLE_GRASPING_FILES Assembles a list of files based on the structure
% of the data in the grasping experiments.  The images are in folders named
% 'data_{finger_name}_*' for calibration and 'test_##' for experiments.
% The forces are recorded in ASCII text files named 'force.dat' where each file contains 5 images'
% worth of force readings.
% 

function file_list = assemble_grasping_cal_files(base_folder, finger_name, is_calibration, debug_mode)

    % Define output structure
    file_list = struct('name',{},'force',{});
    fileIdx = 0;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Process calibration data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Get a list of folders containing the finger name
        folders = dir(sprintf('%s/data_*_%d_*', base_folder, finger_name));
        num_folders = length(folders);
        
        % Process each folder
        for folderIdx = 1:num_folders
            % Form the current folder name
            current_folder = sprintf('%s/%s', base_folder, folders(folderIdx).name);
            if (~exist(current_folder,'dir'))
                error('Folder does not exist! (%s)', current_folder);
            end
            
            % Get a list of image files within the folder
            images = dir(sprintf('%s/img_*.ppm', current_folder)); 
            num_images = length(images);
            
            % Look for a force file
            force_file = sprintf('%s/force.dat', current_folder);
            if (exist(force_file,'file'))
                forces = textread(force_file);
                fprintf('\t\tForce data file found!');
                if (size(forces,1) ~= num_images)
                    fprintf(' Wrong number of force entries, using image information!\n');
                    read_forces = true;
                else
                    fprintf(' Using force data!\n');
                    read_forces = false;
                end
            else
                fprintf('\t\tNo force data file found! Using embedded forces\n');
                read_forces = true;
            end
            
            % Process each image
            for imageIdx = 1:num_images
                % Form the current image name
                current_image = sprintf('%s/%s', current_folder, images(imageIdx).name);
                if (~exist(current_image,'file'))
                    error('Image does not exist! (%s)', current_image);
                end
                fileIdx = fileIdx + 1;
                if (mod(fileIdx,50) == 0)
                    fprintf('Processed %d files\n', fileIdx);
                end
                
                % Save the image name to the structure
                file_list(fileIdx).name = current_image;
                
                % Extract the forces
                if (read_forces)
                    % Load the image
                    try
                        load(current_image);
                    catch exception
                        if ((strcmp(exception.identifier,'MATLAB:imread:fileFormat')) || (strcmp(exception.identifier,'MATLAB:load:numColumnsNotSame')))
                            imgIn = imread(current_image);
                        end
                    end                 
                    file_list(fileIdx).force = read_force(imgIn(1,1:2,:),strcmp(finger_name,'thumb'));
                else
                    file_list(fileIdx).force = forces(imageIdx,:);
                end
            end % imageIdx
        end % folderIdx
end % assemble_grasping_files

% ASSEMBLE_AAM_FILES Assembles a list of files based on the structure of
% the data in the AAM comparison experiments.  The images are in folders
% named 'data_{subject}_{finger}_*'.  The forces are embedded in the images.
% 

function file_list = assemble_grasping_exp_files(base_folder, finger_name, is_calibration, debug_mode, testIdx)

    % Define output structure
    file_list = struct('name',{},'force',{});
    fileIdx = 0;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Process experimental data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get a list of image files within the folder
        current_test = sprintf('%s/test_%d_%02d.mat', base_folder, finger_name, testIdx);
        if (~exist(current_test, 'file'))
            error('Test file does not exist! (%s)', current_test);
        else
            current_folder = sprintf('%s/test_%d_%02d',base_folder, finger_name, testIdx);
            if (exist(current_folder, 'dir'))
               fprintf('Test_%d_%02d folder exists\n',finger_name, testIdx);
               current_image = dir(sprintf('%s/img_*',current_folder));
               num_image = length(current_image);
               for fileIdx=1:num_image
                    file_list(fileIdx).name = sprintf('%s/%s', current_image(fileIdx).folder, current_image(fileIdx).name);   
               end                        
            else
                status = mkdir(current_folder);
                if status ~= 1
                    error('Cannot make test_%02d folder', testIdx);
                end
                load(current_test);
                num_images = size(images.signals.values,4);           
                % Write each image
                for imageIdx = 1:num_images
               
                    % Form the current image
                    imwrite(images.signals.values(:,:,:,imageIdx),sprintf('%s/img_%03d.jpg',current_folder,imageIdx));
                    current_image = sprintf('%s/img_%03d.jpg', current_folder, imageIdx);
                    if (~exist(current_image,'file'))
                        error('Image does not exist, Failed to write the image! (%s)', current_image);
                    end
                    fileIdx = fileIdx + 1;
                    if (mod(fileIdx,50) == 0)
                        fprintf('Processed %d files\n', fileIdx);
                    end
                    % Save the image name to the structure
                    file_list(fileIdx).name = current_image;
                
                end %imageIdx 
            end 
        end

end % assemble_grasping_files

% ASSEMBLE_AAM_FILES Assembles a list of files based on the structure of
% the data in the AAM comparison experiments.  The images are in folders
% named 'data_{subject}_{finger}_*'.  The forces are embedded in the images.
% 


function file_list = assemble_aam_files(base_folder, fingerIdx, debug_mode)

    % Define output structure
    file_list = struct('name',{},'force',{});
    fileIdx = 0;
    
    % Get a list of folders containing the finger name
    folders = dir(sprintf('%s\\data_??_%d_*', base_folder, fingerIdx));
    num_folders = length(folders);
    
    % Process each folder
    for folderIdx = 1:num_folders
        % Form the current folder name
        current_folder = sprintf('%s\\%s', base_folder, folders(folderIdx).name);
        if (~exist(current_folder,'dir'))
            error('Folder does not exist! (%s)', current_folder);
        end
        
        % Get a list of image files within the folder
        images = dir(sprintf('%s\\img_*.ppm', current_folder));
        num_images = length(images);
        
        % Process each image
        for imageIdx = 1:num_images
            % Form the current image name
            current_image = sprintf('%s\\%s', current_folder, images(imageIdx).name);
            if (~exist(current_image,'file'))
                error('Image does not exist! (%s)', current_image);
            end
            fileIdx = fileIdx + 1;
            if (mod(fileIdx,50) == 0)
                fprintf('Processed %d files\n', fileIdx);
            end
            
            % Save the image name to the structure
            file_list(fileIdx).name = current_image;
            
            % Load the image
            imgIn = imread(current_image);
            
            % Extract the forces
            file_list(fileIdx).force = read_force(imgIn(1,1:2,:), (fingerIdx == 1));
        end % imageIdx
    end % folderIdx

end % assemble_aam_files

% ASSEMBLE_DIS_FILES Assembles a list of files based on the structure of
% the data in the Dissertation (AAM) experiments.  The images are in
% folders named 'data_{subject}_{finger}_*'.  The forces are embedded in
% the images.
% 

function file_list = assemble_dis_files(base_folder, fingerIdx, led_color, debug_mode)

    % Define output structure
    file_list = struct('name',{},'force',{});
    fileIdx = 0;
    
    % Get a list of folders containing the finger name
    folders = dir(sprintf('%s\\data_??_%d_*%s*', base_folder, fingerIdx, led_color));
    num_folders = length(folders);
    
    % Process each folder
    for folderIdx = 1:num_folders
        % Form the current folder name
        current_folder = sprintf('%s\\%s', base_folder, folders(folderIdx).name);
        if (~exist(current_folder,'dir'))
            error('Folder does not exist! (%s)', current_folder);
        end
        
        % Get a list of image files within the folder
        images = dir(sprintf('%s\\img_*.ppm', current_folder));
        num_images = length(images);
        
        % Process each image
        for imageIdx = 1:num_images
            % Form the current image name
            current_image = sprintf('%s\\%s', current_folder, images(imageIdx).name);
            if (~exist(current_image,'file'))
                error('Image does not exist! (%s)', current_image);
            end
            fileIdx = fileIdx + 1;
            if (mod(fileIdx,50) == 0)
                fprintf('Processed %d files\n', fileIdx);
            end
            
            % Save the image name to the structure
            file_list(fileIdx).name = current_image;
            
            % Load the image
            %imgIn = imread(current_image);
            
            % Extract the forces
            %file_list(fileIdx).force = read_force(imgIn(1,1:2,:), (fingerIdx == 1));
        end % imageIdx
    end % folderIdx

end % assemble_dis_files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data_type, rotation_matrix, finger_name, is_calibration, led_color, debug_mode, options] = process_options(options)

    % Process each option
    if (isfield(options, 'data_type'))
        data_type = options.data_type;
    else
        data_type = 'individual';
    end
    if (isfield(options, 'rotation_matrix'))
        rotation_matrix = options.rotation_matrix;
    else
        rotation_matrix = [];
    end
    finger_names = {'thumb','index','middle','ring','little'};
    if (isfield(options, 'fingerIdx'))
        finger_name = finger_names{options.fingerIdx};
    elseif (isfield(options, 'finger_name'))
        finger_name = options.finger_name;
        fingerIdx = 0;
        done = false;
        while ((~done) && (fingerIdx < 5))
            fingerIdx = fingerIdx + 1;
            if (strcmp(finger_names{fingerIdx},options.finger_name))
                done = true;
                options.fingerIdx = fingerIdx;
            end
        end
    else
        finger_name = 'index';
        options.fingerIdx = 2;
    end
    if (isfield(options, 'is_calibration'))
        is_calibration = options.is_calibration;
    else
        is_calibration = true;
    end
    if (isfield(options, 'led_color'))
        led_color = options.led_color;
    else
        led_color = 'w';
    end
    if (isfield(options, 'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end

end % process_options
