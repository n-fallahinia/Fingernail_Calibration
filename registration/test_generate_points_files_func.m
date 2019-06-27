function test_generate_points_files_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
% % Generate the points files (.PTS) to use with the Training Images to form
% an Active Appearance Model.
% 

% Define parameters
% subjectIdx = 2;
% typeIdx = 5;
% fingerIdx = 2;
% colorIdx = 1;
always_regenerate = false;

fprintf('#########################################################\n')
fprintf('# PINTS FILES GENERATION HAS BEEN STARTED FOR SUBJECT_%d #\n', subjectIdx)
fprintf('#########################################################\n')

pause(5);

% Define data folders
base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
data_folder = sprintf('%s/data', base_folder);
models_folder = sprintf('%s/models', base_folder);
points_folder = sprintf('%s/points', base_folder);

% Load the .parts file
model_file = sprintf('%s/fingers_%02d.smd', models_folder, subjectIdx);
[~, file_names] = read_model_file(model_file);
parts_file = sprintf('%s/%s', models_folder, file_names.contours);
contour_array = load_contour_array(parts_file);
num_contours = length(contour_array);
num_finger = length(contour_array(1).array);
num_nail = length(contour_array(2).array);

% Load the list of files
files_filename = sprintf('%s/files_%02d.mat', data_folder, subjectIdx);
load(files_filename);
num_images = length(files);

% Load options structure and extract the selected images
options_file = sprintf('%s/options_%02d.mat', data_folder, subjectIdx);
load(options_file);
options.debug_mode = true;
options.nail_finger_ratio = 1.5;
options.use_full_contour_method = true;
save(options_file,'options');
options.use_xy = true;
options.line_width = 3;
options.marker_size = 15;
calibration_images = options.selected_files;
num_calib = length(calibration_images);

% Process each calibration image
all_points = zeros(2*(num_finger+num_nail), num_calib);
all_dates = Inf*ones(num_calib,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating .PTS files for building the AAM  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for calibIdx = 1:num_calib
    % Generate the file names
    imageIdx = calibration_images(calibIdx);
    img_file = files(imageIdx).original_image;
    pts_file = files(imageIdx).points_file;
    mat_points = dir(sprintf('%s/calib_%04d*.mat', data_folder, calibIdx));
    num_mats = length(mat_points);
    if (num_mats == 0)
        fprintf('(%02d) No .MAT points files for this Training Image!\n', calibIdx);
        continue;
    end
    
    if (~always_regenerate)
        % Determine if .PTS file needs to be regenerated
        pts_data = dir(pts_file);
        if (~isempty(pts_data))
            if (pts_data.datenum > max([mat_points.datenum]))
                % Load the .PTS file into the aggregate array
                current_pts = read_points_file(pts_file);
                all_points(:,calibIdx) = [current_pts(:,1); current_pts(:,2)];
                all_dates(calibIdx) = pts_data.datenum;
                
                % Display points and ask the user if they "look right"
                figure(1);
                plot(current_pts(:,1),current_pts(:,2),'k.');
                axis equal;
                axis ij;
                answer = questdlg('Would you like to re-generate these points?','Re-generate poitns?','Yes','No','No');
                while (strcmp(answer,''))
                    answer = questdlg('Would you like to re-generate these points?','Re-generate poitns?','Yes','No','No');
                end
                if (strcmp(answer,'No'))
                    % Skip if .PTS file was generated after all .MAT points files
                    fprintf('(%02d) .PTS file was generated after all .MAT points files!\n', calibIdx);
                    continue;
                end
            end
        end
    end
    
    % Load the calibration image
    imgIn = imread(img_file);
    
    % Display the image
    if (exist('fig_main','var'))
        figure(fig_main);
    else
        fig_main = figure();
    end
    set(fig_main,'Position',options.default_position);
    set(fig_main,'Name',sprintf('Image %d/%d, Training Image %d/%d', imageIdx, num_images, calibIdx, num_calib));
    subplot(1,1,1);
    imshow(imgIn);
    
    % Load the finger contour(s)
    finger_points = cell(num_mats, 2);
    eliminate = true(num_mats,1);
    for matIdx = 1:num_mats
        file_name = sprintf('%s/%s', data_folder, mat_points(matIdx).name);
        temp = whos('finger_points','-file',file_name);
        if ((~isempty(temp)) && (temp.size(1) > 0))
            % Mark this file not to be eliminated
            eliminate(matIdx) = false;
            
            % Load the finger points from the file
            temp = load(file_name,'finger_points');
            
            % Find a set of smooth points around the finger
            x_finger = temp.finger_points(:,1);
            y_finger = temp.finger_points(:,2);
            
            % Store the finger points
            finger_points{matIdx, 1} = x_finger;
            finger_points{matIdx, 2} = y_finger;
            
            % Plot the finger contour
            figure(fig_main);
            hold on;
            plot(x_finger,y_finger,'.-','Color',options.marker_colors(matIdx,:),'LineWidth',options.line_width,'MarkerSize',options.marker_size);
            hold off;
            legend_names{matIdx} = sprintf('Finger (User %s)', mat_points(matIdx).name(12:13));
        end
    end % matIdx
    if (sum(~eliminate) == 0)
        fprintf('(%02d) No Finger points in .MAT file(s)!\n', calibIdx);
        continue;
    end
    
    % Eliminate missing finger contour(s)
    temp = find(eliminate);
    if (~isempty(temp))
        fprintf('Need to generate finger contours on Calibration image %02d for users ', calibIdx);
        for tempIdx = 1:length(temp)
            fprintf('%d ', temp(tempIdx));
        end % userIdx
    end
    
    % Average the nail contour(s)
    nail_points = cell(num_mats, 2);
    eliminate = true(num_mats,1);
    for matIdx = 1:num_mats
        file_name = sprintf('%s/%s', data_folder, mat_points(matIdx).name);
        temp = whos('nail_points','-file',file_name);
        if ((~isempty(temp)) && (temp.size(1) > 0))
            % Mark this file not to be eliminated
            eliminate(matIdx) = false;
            
            % Load the nail points from the file
            temp = load(file_name,'nail_points');
            
            % Find a set of smooth points around the nail
            x_nail = temp.nail_points(:,1);
            y_nail = temp.nail_points(:,2);
            
            % Store the nail points
            nail_points{matIdx, 1} = x_nail;
            nail_points{matIdx, 2} = y_nail;
            
            % Plot the nail contour
            figure(fig_main);
            hold on;
            plot(x_nail,y_nail,'.-','Color',options.marker_colors(matIdx+num_mats,:),'LineWidth',options.line_width,'MarkerSize',options.marker_size);
            hold off;
            legend_names{matIdx+num_mats} = sprintf('Nail (User %s)', mat_points(matIdx).name(12:13));
        end
    end % matIdx
    if (sum(~eliminate) == 0)
        fprintf('(%02d) No Nail points in .MAT file(s)!\n', calibIdx);
        continue;
    end
    figure(fig_main);
    legend(legend_names);
    
    % Eliminate missing finger contour(s)
    temp = find(eliminate);
    if (~isempty(temp))
        fprintf('Need to generate finger contours on Calibration image %02d for users ', calibIdx);
        for tempIdx = 1:length(temp)
            fprintf('%d ', temp(tempIdx));
        end % userIdx
    end
    
    % Plot the smoothed contour and adjust the contour points
    hold on;
    [new_finger, new_nail] = adjust_finger_contour(finger_points, nail_points, options);
    hold off;
    
    % Assemble both arrays into one
    points_array = [new_finger(:,1); new_nail(:,1); new_finger(:,2); new_nail(:,2)];
    
    % Write the .PTS file
    success = write_points_file(pts_file, points_array);
    if (~success)
        error('Could not write .PTS file!');
    end
    
    % Add points to the aggregate matrix
    all_points(:,calibIdx) = points_array;
    all_dates(calibIdx) = now();
    pause(5);
end % calibIdx

fprintf('#######################################################\n')
fprintf('#          POINTS FILES GENERATION HAS BEEN           #\n')
fprintf('#     HAS BEEN SEUCCESSFULLY COMPLETED FOR SUBJECT_%d  #\n', subjectIdx)
fprintf('#######################################################\n')

end

