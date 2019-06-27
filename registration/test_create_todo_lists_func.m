
function test_create_todo_lists_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
% Create "Model" .SMD file and "To-Do List" .SMD file for a data set.  The
% Training Images are chosen at random by dividing the data into groups
% using the find_groups function.  One image is selected from each group.
% 

% Define parameters
% subjectIdx = 2;
% typeIdx = 3;
% fingerIdx = 2;
% colorIdx = 1;
% testIdx = 1;
% grasp_exp = true

fprintf('######################################################\n')
fprintf('# CREATING TO_DO LIST HAS BEEN STARTED FOR SUBJECT_%d #\n', subjectIdx)
fprintf('######################################################\n')
% pause(5);

% Define data folders
options = set_default_options();
traj_size = {'small','med','large','repeat'};
marker_colors = options.marker_colors;
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);
models_folder = sprintf('%s/models', base_folder);

% Load the list of files
files_filename = sprintf('%s/files_%02d.mat', data_folder, subjectIdx);
load(files_filename);
num_images = length(files);
if typeIdx ~= 4
    num_forces = length(files(1).force);
    force_matrix = reshape([files.force],num_forces,num_images)';
    force_matrix = force_matrix(:,1:3);
end
% Load options structure and update options
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
load(options_file);
options.separate_trajectories = true;
options.debug_mode = false;
options.verbose = false;

% Define the calibration list name
calib.model_name = sprintf('fingers_%02d', subjectIdx);
calib_file = sprintf('%s/%s.smd', models_folder, calib.model_name);
if (exist(calib_file,'file'))
    answer = questdlg('The calibration SMD (model) file already exists!\nAre you certain you want to continue?','Continue?','No');
    if (~strcmp(answer,'Yes'))
        keyboard;
    end
end
calibration_files = struct('image_name',{},'points_name',{});

if (options.separate_trajectories)
    if (typeIdx == 4)
        num_groups = 1;
        groups = cell(num_groups,1);
        groups{1,1} = 1:num_images;
        
        eliminate = false(num_images,1);
        elim = false(num_groups,1); 
        centroids(1,:) = nan;
        options.eliminate = eliminate;
    else
        % Extract the relevant trajectory points
        sizeIdx = 4;
        load(sprintf('traj_%s.mat', traj_size{sizeIdx}));
        if (fingerIdx > 2)
            finger_index = 2;
        else
            finger_index = fingerIdx;
        end
        
        % Find appropriate break points and correspondences with trajectory forces
        [correspondences, eliminate, break_points] = find_force_correspondences(force_matrix, force_to_traj, finger_index, options);
        
        % Eliminate the decreed values
        correspondences(eliminate,:) = [];
        force_approx = force_to_traj(correspondences(:,2),:);
        traj_type = force_approx(1,5);
        num_traj = length(traj_to_force(finger_index, traj_type).num_forces);
        
        % Plot the trajectory indices
        fig_traj = figure;
        set(fig_traj,'Position',options.default_position);
        plot(correspondences(:,1),force_to_traj(correspondences(:,2),6),'k.-');
        set(gca,'YLim',[1 num_traj]);
        set(gca,'YTick',1:num_traj);
        
        % Plot the forces and the correspondences
        fig_forces = figure;
        set(fig_forces,'Position',options.default_position);
        plot3(force_matrix(correspondences(:,1),1),force_matrix(correspondences(:,1),2),force_matrix(correspondences(:,1),3),'k.');
        hold on;
        plot3(force_approx(:,1),force_approx(:,2),force_approx(:,3),'r.');
        hold off;
        axis equal;
        xlabel('F_x');
        ylabel('F_y');
        zlabel('F_z');
        
        % Save the list of eliminated files
        options.eliminate = eliminate;
        
        % Form the groups
        groups = cell(num_traj,1);
        for trajIdx = 1:(num_traj-1)
            groups{trajIdx} = break_points(trajIdx):(break_points(trajIdx+1)-1);
        end % trajIdx
        groups{num_traj} = break_points(num_traj):num_images;
        num_groups = num_traj;
        
        % Calculate the centroids and select Training Images
        centroids = zeros(num_groups,3);
        if (isfield(options,'selected_files'))
            selected_files = options.selected_files;
        else
            selected_files = zeros(num_groups,1);
        end
        elim = false(num_groups,1);
        for groupIdx = 1:num_groups
            % Store the array of group indices
            current_group = groups{groupIdx};

            if (isempty(current_group))
                % Store Not-a-Number for the centroids
                centroids(groupIdx,:) = nan;

                % Mark this group for elimination
                if (~isfield(options,'selected_files'))
                    elim(groupIdx) = true;
                end
            else
                % Calculate the centroid
                if typeIdx ~= 4
                    centroids(groupIdx,:) = mean(force_matrix(current_group,:));
                end
                % Select a random image to represent this group
                if (~isfield(options,'selected_files'))
                    pointIdx = ceil(rand()*length(current_group));
                    while (eliminate(current_group(pointIdx)))
                        pointIdx = ceil(rand()*length(current_group));
                    end
                    selected_files(groupIdx) = current_group(pointIdx);
                end

                % Create the structure to hold Training Image information
                calibration_files(groupIdx).image_name = sprintf('img_%02d_%04d.jpg', subjectIdx, selected_files(groupIdx));
                calibration_files(groupIdx).points_name = sprintf('img_%02d_%04d.pts', subjectIdx, selected_files(groupIdx));
            end
        end % trajIdx
    end %cal vs exp  
else
    % Generate correspondence data
    correspondences = (1:num_images)';
    
    % Determine which images belong to which groups
    gr = find_groups(force_matrix, options);
    num_groups = length(gr);
    
    % Rearrange groups into cell array for storing in options structure
    groups = cell(num_groups, 1);
    centroids = zeros(num_groups, 3);
    if (~isfield(options,'selected_files'))
        selected_files = zeros(num_groups, 1);
        elim = false(num_groups,1);
    else
        selected_files = options.selected_files;
    end
    for groupIdx = num_groups:-1:1
        % Store in options structure
        groups{groupIdx} = gr(groupIdx).array;
        
        % Calculate the centroid
        if (isempty(gr(groupIdx).centroid))
            centroids(groupIdx,:) = nan;
            if (~isfield(options,'selected_files'))
                elim(groupIdx) = true;
            end
            continue;
        else
            centroids(groupIdx,:) = gr(groupIdx).centroid;
        end
        
        if (~isfield(options,'selected_files'))
            % Select an image at random to represent the group for calibration
            current_group = groups{groupIdx};
            num_points = length(current_group);
            pointIdx = ceil(rand()*num_points);
            fileIdx = current_group(pointIdx);
            selected_files(groupIdx) = fileIdx;
        end
        calibration_files(groupIdx).image_name = sprintf('img_%02d_%04d.jpg', subjectIdx, selected_files(groupIdx));
        calibration_files(groupIdx).points_name = sprintf('img_%02d_%04d.pts', subjectIdx, selected_files(groupIdx));
    end % groupIdx
end

%####### Groups formed ..!!
% Save these options
options.groups = groups;
options.centroids = centroids;
calibration_files(elim) = [];
if (~isfield(options,'selected_files'))
    if typeIdx ~= 4
        options.selected_files = selected_files;
        options.selected_files(elim) = [];
    end
end
save(options_file, 'options');
%####### All groups and selected files are saved in options

if typeIdx ~= 4
    if (options.verbose)
        % Display forces
        figure(1);
        set(1,'Position',options.default_position);
        plot3(force_matrix(correspondences(:,1),1),force_matrix(correspondences(:,1),2),force_matrix(correspondences(:,1),3),'k.');
        hold on;
        for groupIdx = 1:num_groups
            current_group = options.groups{groupIdx};
            plot3(force_matrix(current_group,1),force_matrix(current_group,2),force_matrix(current_group,3),'o','Color',marker_colors(groupIdx,:));
        end % groupIdx
        plot3(force_matrix(options.selected_files,1),force_matrix(options.selected_files,2),force_matrix(options.selected_files,3),'kx','MarkerSize',15);
        hold off;
        axis equal;
        xlabel('F_x');
        ylabel('F_y');
        zlabel('F_z');
    end
    % Write the calibration model file
     success = write_model_file(models_folder, calib, calibration_files, typeIdx, testIdx, fingerIdx);
    if (~success)
        error('Could not write calibration file!');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write a different "to-do" list for each group and exp images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for groupIdx = 1:num_groups
    
    % Extract current group
    current_group = groups{groupIdx};
    in_group = length(current_group);
    
    % Populate the "to-do" list structure
    manualIdx = 1;
    
    if typeIdx ~= 4
        fprintf('Creating To-Do List for Group %d\n', groupIdx);
        % Define the "to-do" list name (i.e., manual calibration)
        manual.model_name = sprintf('todo_%02d_%s', subjectIdx, char(96+groupIdx));
        manual.tri_file = sprintf('fingers_%02d', subjectIdx);
        manual_file = sprintf('%s/%s.smd', models_folder, manual.model_name);
        manual_files = struct('image_name',{},'points_name',{});
        
        for fileIdx = 1:in_group
            imageIdx = current_group(fileIdx);

            % Check whether the image is already part of the calibration set
            if (any(imageIdx == selected_files(groupIdx)))
                fprintf('\tSkipping Training Image (%d)\n', imageIdx);
                continue;
            end

            if (options.eliminate(current_group(fileIdx)))
                fprintf('\t\tSkipping Eliminated Image (%d)\n', imageIdx);
                continue;
            end

            % Add the image to the "to-do" list
            manual_files(manualIdx).image_name = sprintf('img_%02d_%04d.jpg', subjectIdx, imageIdx);
            manual_files(manualIdx).points_name = 'dummy.pts';
            manualIdx = manualIdx + 1;
        end % fileIdx
    
    else
        fprintf('Creating To-Do List for grasping images\n');
        fprintf('\tOnly %d List will be made\n', num_groups);
        % Define the "to-do" list name (i.e., manual calibration)
        manual.model_name = sprintf('todo_%02d_%s', subjectIdx, 'exp');
        manual.tri_file = sprintf('fingers_%02d', subjectIdx);
        manual_file = sprintf('%s/%s.smd', models_folder, manual.model_name);
        manual_files = struct('image_name',{},'points_name',{});
        
        for fileIdx = 1:in_group
            imageIdx = current_group(fileIdx);
            % Add the image to the "to-do" list
            manual_files(manualIdx).image_name = sprintf('img_%02d_%04d.jpg', subjectIdx, imageIdx);
            manual_files(manualIdx).points_name = 'dummy.pts';
            manualIdx = manualIdx + 1;
        end % fileIdx     
    end
     
    % Write the "to-do" list model file
    success = write_model_file(models_folder, manual, manual_files, typeIdx, testIdx, fingerIdx, true);
    if (~success)
        error('Could not write "to-do" list model file! (%s)', manual.model_name);
    end
end % groupIdx

% Display the calibration images
if (options.verbose)
    if typeIdx ~= 4
        num_selected = length(selected_files);
        figure(2);
        set(2,'Position',options.default_position);
        set(2,'Name','Calibration Images');
        sub_rows = ceil(sqrt(num_selected));
        sub_cols = ceil(num_selected / sub_rows);
        for subIdx = 1:num_selected
            % Extract the image
            imageIdx = options.selected_files(subIdx);
            imgIn = imread(files(imageIdx).original_image);

            % Display the image
            figure(2);
            subplot(sub_rows, sub_cols, subIdx);
            imshow(imgIn);
            ylabel(sprintf('Image %d', imageIdx));
        end % subIdx
    end
end
fprintf('data set has been devided into %d groups\n', length(groups))

fprintf('##############################################\n')
fprintf('# CREATING TO_DO LIST HAS BEEN SEUCCESSFULLY #\n') 
fprintf('#           COMPLETED FOR SUBJECT_%d          #\n', subjectIdx)
fprintf('##############################################\n')

end

