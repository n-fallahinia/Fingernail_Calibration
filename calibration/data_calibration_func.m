% ###############################################################
% Written by Navid Fallahinia
% Modified 2 Feb 2017 to allow assembling lists of grasping data
% BioRobotics Lab
% University of Utah
% ###############################################################

function data_calibration_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx )

%     8. Verify that the AAM has properly registered all images and that no
%        duplicates exist (test_verify_aam_registration)
%     9. Transform the images (test_transform_images)
%    10. Extract the AAM parameters (test_assemble_parameters)
%    11. Extract the pixel matrices (test_assemble_pixels)
%    12. Calibrate the models:
%      (a) Linearized Sigmoid Model (test_calibrate_linearized_sigmoid_model)
%          (WARNING: This takes a LONG time!)
%      (b) EigenNail Magnitude Model (test_calibrate_eigennail_model)
%      (c) AAM Parameters Models (test_calibrate_AAMFinger_model)
%    13. Analyze the model -- Multiple possibilities:
%      (a) Calculate the Registration Error (test_calculate_registration_error)
%      (b) Calculate the Training Error (test_calculate_training_error)
%      (c) Estimate the Validation Error (test_calculate_validation_error)
%      (d) Display one of the above errors (e.g., test_display_validation_error)
%    14. Estimate grasping forces (test_eigennail_predic_func)

fprintf('==== CALIBRATION STARTED FOR SUBJECT_%d ====\n', subjectIdx)

%   Verify that the AAM has properly registered all images
    test_verify_aam_registration_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
    
%   Transform the images
    test_transform_images_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);

    if typeIdx ~= 4
%       Extract the AAM parameters
        test_assemble_parameters_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
    end
    
%   Extract the pixel matrices
    test_assemble_pixels_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
    
    if typeIdx ==4              
%       Estimate grasping forces
        test_eigennail_predic_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);

    else
%       EigenNail Magnitude Model
        test_calibrate_eigennail_model_func(subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx);
    end
    
 fprintf('==== CALIBRATION COMPLETED FOR SUBJECT_%d ====\n', subjectIdx)

end



