% ###############################################################
% Written by Navid Fallahinia
% Modified 2 Feb 2017 to allow assembling lists of grasping data
% BioRobotics Lab
% University of Utah
% ###############################################################

function data_registration_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx )

% This script calls 4 sets of functions for data assembly and preparing
% data for AAM registration
% The 5 steps of this script includes:
%    1. Assemble a data set (test_assemble_data)
%    2. Create the model (SMD) file and "To-Do" lists (test_create_todo_lists)
%    3. Select the points files (.pts) for the calibration set
%       (test_select_points_single)
%    4. Generate the initial .pts files for the calibration set
%       (test_generate_points_files)
%    5. Assemble the TrainingData, ShapeData, TextureData and AppearanceData
%       structures and the .TRI file (test_assemble_AAM_model)

 fprintf('==== REGISTERATION STARTED FOR SUBJECT_%d ====\n', subjectIdx)

% Assemble a data set (test_assemble_data)
 test_assemble_data_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)

% Create the model (SMD) file and "To-Do" lists (test_create_todo_lists)
 test_create_todo_lists_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)

 if typeIdx ~=4 
    % Select the points files (.pts) for the calibration set
    test_select_points_singl_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)

    % Generate the initial .pts files for the calibration set
    test_generate_points_files_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
     
    % Assemble the TrainingData, ShapeData, TextureData and AppearanceData structures and the .TRI file
    test_assemble_AAM_model_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx)
 end    
 
 fprintf('==== REGISTERATION COMPLETED FOR SUBJECT_%d ====\n', subjectIdx)

end

