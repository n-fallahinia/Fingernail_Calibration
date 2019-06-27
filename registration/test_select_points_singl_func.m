function test_select_points_singl_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)

% Generate the points files (.PTS) to use with the Training Images to form
% an Active Appearance Model.
% 
fprintf('############################################################\n')
fprintf('# FINGER AND NAIL DETECTION HAS BEEN STARTED FOR SUBJECT_%d #\n', subjectIdx)
fprintf('############################################################\n')
pause(5);
% Define parameters
% subjectIdx = 2;
% typeIdx = 5;
% fingerIdx = 2;
% colorIdx = 1;
 edit_existing = false;

% Define constants
user_names = {'Navid','Tom','David'};
num_users = length(user_names);
finger_names = {'thumb','index','middle','ring','little'};
num_fingers = length(finger_names);
color_names = {'white','green'};
num_colors = length(color_names);
ipt_good = false;%(get_image_processing_toolbox_version() > 6);

% Select user
done = false;
while (~done)
    % Ask the user to select his/her name
    answer = questdlg('Select user name:', 'Select User',user_names{1:end},user_names{1});
    
    % Find the user name in the cell array
    userIdx = 0;
    while ((userIdx < num_users) && (~done))
        userIdx = userIdx + 1;
        if (strcmp(answer,user_names{userIdx}))
            done = true;
        end
    end
    
    % Verify that the name was found
    if (~done)
        msg_handle = msgbox('You must select a valid user','ERROR!','error');
        uiwait(msg_handle);
    end
end

% Define folders
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);
models_folder = sprintf('%s/models', base_folder);
points_folder = sprintf('%s/points', base_folder);

% Load the list of files
files_filename = sprintf('%s/files_%02d.mat', data_folder, subjectIdx);
if (~exist(files_filename,'file'))
    fprintf(' (files)\n');
    error('No files list!');
end
load(files_filename);
num_images = length(files);

% Load options structure and extract the selected images
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
if (~exist(options_file,'file'))
    fprintf(' (options)\n');
    error('No options list!');
end
load(options_file);
options = set_default_options(options);
save(options_file,'options');
calibration_images = options.selected_files;
num_calib = length(calibration_images);

% Process each calibration image
for calibIdx = 1:num_calib
    % Verify that the points have not already been generated
    imageIdx = calibration_images(calibIdx);
    img_file = files(imageIdx).original_image;
    mat_points = sprintf('%s/calib_%04d_%02d.mat', data_folder, calibIdx, userIdx);
    if (exist(mat_points,'file'))
        % Check whether finger_points is in the output file
        if (isempty(whos('finger_points','-file',mat_points)))
            % Preallocate empty arrays for the points
            finger_points = [];
            nail_points = [];
        else
            % Check whether nail_points is in the output file
            load(mat_points,'finger_points');
            if (isempty(whos('nail_points','-file',mat_points)))
                nail_points = [];
            else
                if (edit_existing)
                    % Load for editing
                    load(mat_points,'nail_points');
                else
                    % Skip since all points have been generated
                    continue;
                end
            end
        end
    else
        % Set up empty arrays for the points
        finger_points = [];
        nail_points = [];
    end
    old_finger = finger_points;
    old_nail = nail_points;
    
    % Load the calibration image
    imgIn = imread(img_file);
    
    % Set up the figure to display the image
    if (exist('fig_image','var'))
        figure(fig_image);
    else
        fig_image = figure();
    end
    set(fig_image,'Position',options.default_position);
    set(fig_image,'Name',sprintf('Image %d/%d, Training Image %d/%d', imageIdx, num_images, calibIdx, num_calib));
    subplot(1,1,1);
    imshow(imgIn);
    
    % Ask the user to select the finger contour
    if (isempty(finger_points))
        title(sprintf('Select the Outside Finger Contour\nRight-Click to Finish'),'FontSize',options.font_size);
        hold on;
        if (ipt_good)
            h_finger = impoly();
            finger_points = h_finger.getPosition();
            h_finger.delete();
        else
            [x,y,btn] = ginput(1);
            finger_points = [];
            while (btn ~= 3)
                finger_points = [finger_points; x y];
                plot(finger_points(:,1),finger_points(:,2),'r.-');
                [x,y,btn] = ginput(1);
            end
        end
        title('');
        plot(finger_points(:,1),finger_points(:,2),'ro-','LineWidth',options.line_width);
        hold off;
        
        % Save the selected points
        save(mat_points, 'finger_points');
    else
        % Plot the existing points
        hold on;
        plot(finger_points(:,1),finger_points(:,2),'r.-','LineWidth',options.line_width);
        hold off;
    end
    
    % Ask the user to select the nail contour
    if (isempty(nail_points))
        title(sprintf('Select the Nail Contour\nRight-Click to Finish'),'FontSize',options.font_size);
        hold on;
        if (ipt_good)
            h_nail = impoly();
            nail_points = h_nail.getPosition();
            h_nail.delete();
        else
            [x,y,btn] = ginput(1);
            nail_points = [];
            while (btn ~= 3)
                nail_points = [nail_points; x y];
                plot(nail_points(:,1),nail_points(:,2),'c.-');
                [x,y,btn] = ginput(1);
            end
        end
        title('');
        plot(nail_points(:,1),nail_points(:,2),'c.-','LineWidth',options.line_width);
        hold off;
        
        % Save the selected points
        save(mat_points, 'finger_points','nail_points');
    else
        % Plot the existing points
        hold on;
        plot(nail_points(:,1),nail_points(:,2),'c.-','LineWidth',options.line_width);
        hold off;
    end
    
    % Ask the user to verify the selections
    answer = questdlg('Do you want to change any of these points?', 'Change Points?','Finger','Nail','None','None');
    while ((~strcmp(answer,'None')) && (~strcmp(answer,'')))
        % Split based on 'Finger' or 'Nail'
        if (strcmp(answer,'Finger'))
            close(fig_image);
            temp = generate_finger_contours('Current',imgIn,'Points',finger_points,'Options',options);
            if (~isempty(temp))
                finger_points = temp;
            end
        elseif (strcmp(answer,'Nail'))
            close(fig_image);
            temp = generate_finger_contours('Current',imgIn,'Points',nail_points,'Options',options);
            if (~isempty(temp))
                nail_points = temp;
            end
        else
            error('Unknown response!');
        end
        
        % Show the image and re-draw the contours
        figure(fig_image);
        imshow(imgIn);
        hold on;
        plot(finger_points(:,1),finger_points(:,2),'r.-','LineWidth',options.line_width);
        plot(nail_points(:,1),nail_points(:,2),'c.-','LineWidth',options.line_width);
        hold off;
        
        % Loop until the user selects 'None' or closes the window
        answer = questdlg('Do you want to change any of these points?', 'Change Points?','Finger','Nail','None','None');
    end
    
    if (~((numel(finger_points) == numel(old_finger)) && (numel(nail_points) == numel(old_nail)) && (sum(sum(abs(finger_points - old_finger))) == 0) && (sum(sum(abs(nail_points - old_nail))) == 0)))
        % Save the selected points
        save(mat_points, 'finger_points','nail_points');
    end
end % calibIdx
fprintf('###################################################\n')
fprintf('# FINGER AND NAIL DETECTION HAS BEEN SEUCCESSFULLY#\n') 
fprintf('#              COMPLETED FOR SUBJECT_%d            #\n', subjectIdx)
fprintf('###################################################\n')
end

