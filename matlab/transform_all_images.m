% Transforms all images in a file_list according to the AAM defined by
% base_points and texture_size.  Saves the transformed image to the file
% named in the field 'aligned_image' of the structure 'file_list'.
% 

function success = transform_all_images(file_list, points_array, base_points, texture_size, triangles, options)

    if (nargin() == 5)
        [stdErr, aam_date, verbose, debug_mode] = process_options([]);
    elseif (nargin() == 6)
        [stdErr, aam_date, verbose, debug_mode] = process_options(options);
    else
        error('Must have 5 or 6 inputs!');
    end
    
    % Turn off the 'Images:cp2tform:foldOverTriangles' warning
    warning('off','Images:cp2tform:foldOverTriangles');
    
    % Clear the last warning
    if (strcmp(lastwarn,'Images:cp2tform:foldOverTriangles'))
        lastwarn('<none>');
    end
    
    % Determine the number of image files
    num_files = length(file_list);
    
    % Determine the number of points
    [num_points, num_images] = size(points_array);
    num_points = num_points / 2;
    pts_file = file_list(1).points_file;
    imageIdx = 1;
    while (~exist(pts_file,'file'))
        imageIdx = imageIdx + 1;
        pts_file = file_list(imageIdx).points_file;
    end
    pts_array = read_points_file(pts_file);
    if (num_points ~= size(pts_array, 1))
        error('Array of points has the wrong number of points!');
    end
    if (num_files ~= num_images)
        error('Array of points has the wrong number of images!');
    end
    
    % Process all images
    for imageIdx = num_files:-1:1
        if ((mod(imageIdx, round(num_files/10)) == 0) && (verbose))
            if (debug_mode)
                fprintf('\tProcessing %d\n', imageIdx);
            else
                fprintf('.');
            end
        end
        
        % Check file dates
        aligned_file = file_list(imageIdx).aligned_image;
        aligned_dir = dir(aligned_file);
        points_file = file_list(imageIdx).points_file;
        points_dir = dir(points_file);
        if ((~isempty(aligned_dir)) && (aam_date < aligned_dir.datenum) && (~isempty(points_dir)) && (points_dir.datenum < aligned_dir.datenum))
            continue;
        end
        
        % Read the image file
        image_file = file_list(imageIdx).original_image;
        if (~exist(image_file,'file'))
            continue;
        end
        imgIn = imread(image_file);
        
        % Load the points
        current_points = [points_array(1:num_points, imageIdx) points_array((num_points+1):end, imageIdx)];
        
        % Align the image
        try
            imgAligned = transform_image(imgIn, current_points, base_points, texture_size, triangles, debug_mode);
        catch exception
            if (strcmp(exception.identifier,'Images:cp2tform:atLeast4NonColinearPointsReq'))
                % Perturb the points array to remove triangles containing 3
                % points in a straight line
                pts_array = perturb_points(current_points, stdErr, debug_mode);
                
                % Align the image
                imgAligned = transform_image(imgIn, pts_array, base_points, texture_size, triangles, debug_mode);
                
                % Rename the .PTS file
                [success, msg, msgID] = movefile(point_file, sprintf('%s2', point_file));
                if (~success)
                    fprintf('Could not rename .PTS file (%s) to replace it!\n\t%s::%s\n', point_file, msgID, msg);
                    keyboard;
                end
                try
                    success = write_points_file(point_file, [pts_array(:,2); pts_array(:,1)]);
                catch exception
                    keyboard;
                end
                if (~success)
                    fprintf('Could not write updated .PTS file (%s)!\n\t%s::%s\n', point_file);
                    keyboard;
                end
            else
                fprintf('\n\tUnknown error -- Skipped %d', imageIdx);
                keyboard;
                continue;
            end
        end
        
        % Was a 'Images:cp2tform:foldOverTriangles' warning generated?
        [msgstr, msgID] = lastwarn();
        if (strcmp(msgID,'Images:cp2tform:foldOverTriangles'))
            if (verbose)
                % Show the user our custom 'Fold-over Triangles warning
                fprintf('Fold-over Triangles warning on Image %d--Using warp_triangle\n', imageIdx);
            end
            
            % Warp using the warp_triangle function
            imgAligned = warp_triangle(imgIn, current_points(:,[2 1]), base_points(:,[2 1]), texture_size, triangles);
            
            % Clear the last warning
            lastwarn('<none>');
        end
        
        % Save the results
        save(aligned_file, 'imgAligned');
    end % imageIdx
    
    % Declare success
    success = true;
    
    % Turn on the 'Images:cp2tform:foldOverTriangles' warning
    warning('on','Images:cp2tform:foldOverTriangles');

end % transform_all_images

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stdErr, aam_date, verbose, debug_mode] = process_options(options)

    if (isfield(options,'stdErr'))
        stdErr = options.stdErr;
    else
        stdErr = 0.5;
    end
    if (isfield(options,'aam_date'))
        aam_date = options.aam_date;
    else
        aam_date = Inf;
    end
    if (isfield(options,'verbose'))
        verbose = options.verbose;
    else
        verbose = false;
    end
    if (isfield(options,'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end

end % process_options
