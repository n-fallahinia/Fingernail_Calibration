% Generate a Delaunay triangulation and write it to a file in the format
% expected by am_tools.
% 

function success = write_tri_file(file_name, triangles, options)

    % Process inputs
    if (nargin() == 2)
        [check_file_existence, debug_mode] = process_inputs([]);
    elseif (nargin() == 3)
        [check_file_existence, debug_mode] = process_inputs(options);
    else
        error('Must have 2 or 3 inputs!');
    end
    success = false;
    
    if (check_file_existence)
        % Verify that the file does not exist already
        if (exist(file_name,'file'))
            choice = [];
            while (isempty(choice))
                choice = questdlg(sprintf('Triangle file already exists!\nDo you want to overwrite?'),'Overwrite','Yes','No','Yes');
            end
            if (strcmp(choice,'No'))
                success = true;
                return;
            end
        end
    end
    
    % Determine size of triangles input and correct for "am_tools" starting
    % with '0' where Matlab starts with '1'
    num_triangles = size(triangles,1);
    triangles = triangles - 1;
    
    % Open the output file
    output_file = fopen(file_name, 'w');
    
    % Write the initial material
    fprintf(output_file, 'version: 1\n');
    fprintf(output_file, 'n_triangles: %d\n', num_triangles);
    fprintf(output_file, '{\n');
    
    % Write each set of triangles
    for triangleIdx = 1:num_triangles
        fprintf(output_file, ' { v1: %d v2: %d v3: %d } \n', triangles(triangleIdx, 1), triangles(triangleIdx, 2), triangles(triangleIdx, 3));
    end % triangleIdx
    
    % Write the closing material
    fprintf(output_file, '}\n');
    
    % Close the output file
    fclose(output_file);
    
    % Declare success
    success = true;

end % write_tri_file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process inputs, verifying size and shape and setting up weight matrix, if
% needed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [check_file_existence, debug_mode] = process_inputs(options)

    % Determine whether to check for an existing file
    if (isfield(options,'check_file_existence'))
        check_file_existence = options.check_file_existence;
    else
        check_file_existence = true;
    end
    
    % Determine whether to use Debug mode
    if (isfield(options,'debug_mode'))
        debug_mode = options.debug_mode;
    else
        debug_mode = false;
    end

end % process_inputs
