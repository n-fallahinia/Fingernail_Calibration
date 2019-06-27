% Create the folders required to initialize a new test subject's data.
% 

function success = create_folders(base_folder, typeIdx)

    % Verify input folder exists
    if (~exist(base_folder, 'dir'))
        [success, message, messageID] = mkdir(base_folder);
        if (~success)
            error('Base folder does not exist, and could not be created!\n\t[%s] %s', messageID, message);
        end
    end
    
    % Define the folders to be created within the base folder
    if typeIdx == 4
        folder_names = {'data','models','images','points','aligned'};
    else
        folder_names = {'data','models','images','points','aligned','params'};
    end
    num_folders = length(folder_names);
    for folderIdx = 1:num_folders
        folder_name = sprintf('%s/%s', base_folder, folder_names{folderIdx});
        if (~exist(folder_name,'dir'))
            [success, message, messageID] = mkdir(folder_name);
            if (~success)
                error('Folder (%s) does not exist, and could not be created!\n\t[%s] %s', folder_names{folderIdx}, messageID, message);
            end
        end
    end % folderIdx
    
    % Create all needed generic files
    success = create_files(base_folder);

end % create_folders

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create needed files to begin processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function success = create_files(base_folder)

    % Create the dummy.pts file
    points_folder = sprintf('%s/points', base_folder);
    points_success = create_dummy_points(points_folder);
    
    % Create the fingers.parts file
    models_folder = sprintf('%s/models', base_folder);
    parts_success = create_parts_file(models_folder);
    
    % Join all results into the final result
    success = points_success && parts_success;

end % create_files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create dummy.pts file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function success = create_dummy_points(points_folder)

    % Define dummy points file
    points_file = sprintf('%s/dummy.pts', points_folder);
    if(~exist(points_file,'file'))
        % File does not exist, create it in write mode
        output_file = fopen(points_file, 'w');
        
        % Write each line, as needed
        fprintf(output_file, 'version: 1\n');
        fprintf(output_file, '// This file is used to indicate an image that has not yet been marked up\n');
        fprintf(output_file, 'n_points: 2\n');
        fprintf(output_file, '{\n');
        fprintf(output_file, '0 1\n');
        fprintf(output_file, '1 0\n');
        fprintf(output_file, '}\n');
        
        % Close the output file
        fclose(output_file);
    end
    
    % Create output
    success = true;

end % create_dummy_points
