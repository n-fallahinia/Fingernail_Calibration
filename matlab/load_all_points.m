% Load all points files in a file list.
% 

function all_points = load_all_points(file_list, typeIdx, options)

    % Extract options from structure
    if (nargin() == 2)
        [scale_factor, verbose] = process_options([]);
    elseif (nargin() == 3)
        [scale_factor, verbose] = process_options(options);
    else
        error('Must have 2 or 3 inputs!');
    end
    
    % Preallocate output matrix
    num_files = length(file_list);
    done = false;
    fileIdx = 0;
    while (~done)
        fileIdx = fileIdx + 1;
        first_file = file_list(fileIdx).points_file;
        if (exist(first_file,'file'))
            done = true;
        end
    end
    points_array = read_points_file(first_file);
    num_points = size(points_array, 1);
    all_points = zeros(2*num_points, num_files);
    all_points(:,1) = [points_array(:,1); points_array(:,2)];
    
    % Assemble file data
    for fileIdx = 2:num_files
        % Generate base file name
        point_file = file_list(fileIdx).points_file;
        if (~exist(point_file, 'file'))
            fprintf('_');
            continue;
        end
        if ((verbose) && (mod(fileIdx,50) == 0))
            fprintf('.');
        end
        
        % Read the points file
        points_array = read_points_file(point_file);
        
        % Save the points to the aggregate array
        all_points(:,fileIdx) = [points_array(:,1); points_array(:,2)];
    end % fileIdx
    
    % Scale the points
    all_points = all_points * scale_factor;

end % load_all_points

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [scale_factor, verbose] = process_options(options)

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

end % process_options
