 # ============================
 #    General Information 
 # ============================
All code in this folder is for registration, calibration and data analysis.  For the purposes of this file, "subject" refers to an individual, "finger" refers to any of the digits of the hand (thumb, index, middle, ring or little) and "light color" refers to the LED color used to illuminate the finger while images are collected.

The 'matlab' folder contains functions that form Active Appearance Models and display the results.  The files in this folder will either need to be placed in 'C:\fingerdata\finger_asm\matlab', or somewhere that is already on the MATLAB path, or else many of the scripts in the other subfolders will not run correctly.

The 'lib' folder, which contains other "helper" functions written to make sorting the data easier, as well as other general-purpose functions.  These functions will need to be in a folder on your MATLAB path, or else many of the scripts in the other subfolders will not run correctly.

The 'registration' folder contains scripts that assemble the data into a format used by the am_tools software, then reads the results from that software and uses them to align the images to a common reference image.  These scripts generally work on a single combination of subject/finger/light color at a time.

The 'calibration' folder contains scripts that extract data from the registered images and form mathematical models relating this data to the force values associated with those images.  These scripts generally work on a single combination of subject/finger/light color at a time.

The 'analysis' folder contains scripts that perform large-scale statistical analysis to detect trends across the population.  These scripts generally work on all combinations of subject/finger/light color, or some subset of all combinations.  This is missing some components right now as I need to sort through all of the various files I have and pick out the ones we'll need to use.

The 'am_tools' folder contains the am_tools functions.  For your use in registration, the appropriate file should be unpacked to your computer.  I would strongly recommend that you add the appropriate folder (win_bin or linux_bin) to your Windows/Linux path.

The current file has the "Entire Process" part which gives a list of all steps that need to be taken from initial data collection to data analysis.

# ============================
#     Entire Process 
# ============================

(How to run)

NO installation or compile required! You just need to navigate to the /bin directory and execute the following command:
     
    sudo chmod +x runscript_aam runscript_gui
    ./runscript_gui

You will be asked a few questions regarding the path file and then the GUI will show up!

(Files, Folders and Formats)

    1. Collected data
      1. Calibration Data
        a. Data Folder: ~/finger_data/grasping/subj_0**/grasping_calibration
        b. Data Format: data_subjIdx_fingerIdx_groupIdx
        c. Data structure: savedforces.txt(measured forces) , img_***.ppm(raw image)
        d. Output: calibration model in data folder (eigennail_FingerIdx_ResIdx.mat) 

      2. Grasping Experiment
        a. Data Folder: ~/finger_data/grasping/subj_0**/grasping_experiment
        b. Data Format: test_fingerIdx_trialIdx.mat
        c. Data structure: forces(recorded forces), images(captured images), x_pose(end_effector position)
        d. Output: estimated forces in data folder (force_FingerIdx_ResIdx.mat) 

Steps to Complete the Registration, Calibration & Force Estimation Process
(Part 1, MATLAB)

    1. Assemble a data set (test_assemble_data)
    2. Create the model (SMD) file and "To-Do" lists (test_create_todo_lists)
    3. Select the points files (.pts) for the calibration set
       (test_select_points_single)
    4. Generate the initial .pts files for the calibration set
       (test_generate_points_files)
    5. Assemble the TrainingData, ShapeData, TextureData and AppearanceData
       structures and the .TRI file (test_assemble_AAM_model)
# ============================================

(Part 2, C++)

    6. Build the AAM (am_build_apm, am_build_aam)
    7. Create .pts files corresponding to all of the "To-Do" list images
       (am_markup).
# ============================================

(Part 3, MATLAB)

    8. Verify that the AAM has properly registered all images and that no
       duplicates exist (test_verify_aam_registration)
    9. Transform the images (test_transform_images)
   10. Extract the AAM parameters (test_assemble_parameters)
   11. Extract the pixel matrices (test_assemble_pixels)
   12. Calibrate the models:
     (a) Linearized Sigmoid Model (test_calibrate_linearized_sigmoid_model)
         (WARNING: This takes a LONG time!)
     (b) EigenNail Magnitude Model (test_calibrate_eigennail_model)
     (c) AAM Parameters Models (test_calibrate_AAMFinger_model)
   13. Analyze the model -- Multiple possibilities:
     (a) Calculate the Registration Error (test_calculate_registration_error)
     (b) Calculate the Training Error (test_calculate_training_error)
     (c) Estimate the Validation Error (test_calculate_validation_error)
     (d) Display one of the above errors (e.g., test_display_validation_error)
   14. Estimate grasping forces (test_eigennail_predic_func)

# ============================================
This document was prepared by Navid Fallahinia

Created 01 April 2018

Modified 26 August 2018
