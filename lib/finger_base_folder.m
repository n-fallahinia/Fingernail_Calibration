function base_folder = finger_base_folder(subjectIdx, typeIdx, fingerIdx, colorIdx, test_Idx)

    if (nargin() == 2)
        no_subfolder = true;
    elseif (nargin() == 3)
        no_subfolder = false;
        colorIdx = 1;
    elseif (nargin() == 4 )
        no_subfolder = false;
    elseif (nargin() == 5)
        no_subfolder = true;
    else
        error('Bad inputs!');
    end
    
    % Get data folder
    [zero_folder, work_computer] = find_base_folder();
    %###### already been added
    %addpath(sprintf('%s\\finger_asm\\matlab', zero_folder));
    %######
    % Define data types
    type_names = {'manual','indiv','grasp_cal','grasp_exp','aam_compare'};
    finger_names = {'thumb','index','middle','ring','little'};
    color_names = {'w','g'};
    
    % Generate new base folder name
    switch(typeIdx)
        case 1 % Yu Sun's Manual 1-D Calibration
            base_folder = sprintf('%s/finger_asm/yuSun_%03d', zero_folder, subjectIdx);
        case 2 % Automated 3-D Calibration
            base_folder = sprintf('%s/finger_asm/indiv_%02d', zero_folder, subjectIdx);
        case 3 % Grasping Calibration
            if (no_subfolder)
                base_folder = sprintf('%s/finger_asm/grasp_%02d/%s_cal', zero_folder, subjectIdx, finger_names{fingerIdx});
            else
                base_folder = sprintf('%s/finger_asm/grasp_%02d/%s_cal', zero_folder, subjectIdx, finger_names{fingerIdx});
            end
        case 4 % Grasping Experiment
            if (no_subfolder)
                base_folder = sprintf('%s/finger_asm/grasp_%02d/%s_exp/test_%02d', zero_folder, subjectIdx, finger_names{fingerIdx}, test_Idx);
            else
                base_folder = sprintf('%s/finger_asm/grasp_%02d/%s_exp/%test_%02d', zero_folder, subjectIdx, finger_names{fingerIdx}, test_Idx);
            end
        case 5 % AAM Comparison Experiments
            if (no_subfolder)
                base_folder = sprintf('%s/finger_asm/aam_%02d', zero_folder, subjectIdx);
            else
                base_folder = sprintf('%s/finger_asm/aam_%02d/index_cal', zero_folder, subjectIdx);
            end
        case 6 % AAM Comparison Experiments
            if (no_subfolder)
                base_folder = sprintf('%s/finger_asm/dis_%02d', zero_folder, subjectIdx);
            else
                base_folder = sprintf('%s/finger_asm/dis_%02d/%s_cal_%s', zero_folder, subjectIdx, finger_names{fingerIdx}, color_names{colorIdx});
            end
        otherwise
            error('Unknown data type!');
    end

end % finger_base_folder