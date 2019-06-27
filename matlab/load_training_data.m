% Load the training data, creating a structure to be saved, which simulates
% that used by the AAM/ASM functions used by the Matlab package
% 'ActiveModels_version7' created by D.Kroon of the University of Twente.
% 
% The training data is extracted from the .SMD model file (model_file) that
% follows the format used by the am_tools package.  (This function only
% works if the .SMD file is stored in a folder called 'models' and the
% other data folders are in the same location as the 'models' folder.
% 

function TrainingData = load_training_data(file_list, options)

    % Extract options from structure
    if (nargin() == 1)
        [load_images, color_channel, scale_factor, selected_files, all_contours, verbose] = process_options([]);
    elseif (nargin() == 2)
        [load_images, color_channel, scale_factor, selected_files, all_contours, verbose] = process_options(options);
    else
        error('Must have 1 or 2 inputs!');
    end
    
    % Determine number of files to process
    if (isempty(selected_files))
        selected_files = 1:length(file_list);
        num_print = 50;
    else
        num_print = 1;
    end
    num_training = length(selected_files);
    
    % Assemble training data
    TrainingData = struct('Vertices',{},'Lines',{},'I',{});
    for trainingIdx = num_training:-1:1
        fileIdx = selected_files(trainingIdx);
        
        % Generate base file name
        point_file = file_list(fileIdx).points_file;
        if (~exist(point_file, 'file'))
            fprintf('Point file does not exist! (%s)', point_file);
            continue;
        end
        
        % Read the points file
        identified_position = read_points_file(point_file);
        Vertices = identified_position*scale_factor;
        
        % Show the image
        if ((verbose) && (mod(trainingIdx,num_print) == 0))
            fprintf('.');
        end
        
        % Put everything in the TrainingData array
        TrainingData(trainingIdx).Vertices = Vertices;
        TrainingData(trainingIdx).Lines = all_contours;
        if (load_images)
            image_file = file_list(fileIdx).original_image;
            imgIn = imread(image_file);
            TrainingData(trainingIdx).I = imresize(convert_image(imgIn, color_channel), scale_factor);
        else
            TrainingData(trainingIdx).I = [];
        end
    end % trainingIdx

end % load_training_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [load_images, color_channel, scale_factor, selected_files, contour_array, verbose] = process_options(options)

    % Boolean that determines whether or not to load the images into the
    % training data
    if (isfield(options,'load_images'))
        load_images = options.load_images;
        
        % Determine the color processing method to use
        if (isfield(options,'color_channel'))
            color_channel = options.color_channel;
        else
            color_channel = 'green';
        end
    else
        load_images = false;
        color_channel = 'gray'; % Should not matter
    end
    
    % Scale factor for processing the image
    if (isfield(options,'scale_factor'))
        scale_factor = options.scale_factor;
    else
        scale_factor = 0.25;
    end
    
    % Provide verbose output?
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end
    
    % Extract contour array
    if (isfield(options,'contour_array'))
        contour_array = options.contour_array;
        num_contours = length(contour_array);
        all_contours = [];
        
        % Create the current contour list
        for contourIdx = 1:num_contours
            % First column follows specified contour from point to point
            current_contour = contour_array(contourIdx).array;
            
            % Second column gives the following point
            current_contour(1:(end-1),2) = current_contour(2:end,1);
            
            % Close the contour
            current_contour(end,2) = current_contour(1,1);
            
            % Add to the list of all contours
            all_contours = [all_contours; current_contour];
        end % contourIdx
        contour_array = all_contours;
    else
        contour_array = [];
    end
    
    % Determine the files to add to the TrainingData structure
    if ((isfield(options,'use_selected')) && (options.use_selected))
        if (isfield(options,'selected_files'))
            selected_files = options.selected_files;
        else
            selected_files = [];
        end
    else
        selected_files = [];
    end

end % process_options
