function trajectories = get_assigned_trajectories()

    % Define constants
    num_subjects = 19;
    num_fingers = 2;
    num_colors = 2;
    
    % Preallocate output
    trajectories = zeros(num_subjects, num_fingers, num_colors);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assign each subject (1=Cartesian, 2=Cylindrical)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Subject 1
    trajectories(1, 1, 1) = 1;
    trajectories(1, 1, 2) = 2;
    trajectories(1, 2, 1) = 2;
    trajectories(1, 2, 2) = 2;
    
    % Subject 2
    trajectories(2, 1, 1) = 2;
    trajectories(2, 1, 2) = 2;
    trajectories(2, 2, 1) = 2;
    trajectories(2, 2, 2) = 1;
    
    % Subject 3
    trajectories(3, 1, 1) = 1;
    trajectories(3, 1, 2) = 2;
    trajectories(3, 2, 1) = 1;
    trajectories(3, 2, 2) = 2;
    
    % Subject 4
    trajectories(4, 1, 1) = 2;
    trajectories(4, 1, 2) = 2;
    trajectories(4, 2, 1) = 1;
    trajectories(4, 2, 2) = 1;
    
    % Subject 5
    trajectories(5, 1, 1) = 1;
    trajectories(5, 1, 2) = 1;
    trajectories(5, 2, 1) = 1;
    trajectories(5, 2, 2) = 1;
    
    % Subject 6
    trajectories(6, 1, 1) = 1;
    trajectories(6, 1, 2) = 1;
    trajectories(6, 2, 1) = 2;
    trajectories(6, 2, 2) = 2;
    
    % Subject 8
    trajectories(8, 1, 1) = 1;
    trajectories(8, 1, 2) = 1;
    trajectories(8, 2, 1) = 2;
    trajectories(8, 2, 2) = 2;
    
    % Subject 9
    trajectories(9, 1, 1) = 1;
    trajectories(9, 1, 2) = 1;
    trajectories(9, 2, 1) = 1;
    trajectories(9, 2, 2) = 2;
    
    % Subject 10
    trajectories(10, 1, 1) = 2;
    trajectories(10, 1, 2) = 1;
    trajectories(10, 2, 1) = 2;
    trajectories(10, 2, 2) = 2;
    
    % Subject 11
    trajectories(11, 1, 1) = 1;
    trajectories(11, 1, 2) = 1;
    trajectories(11, 2, 1) = 2;
    trajectories(11, 2, 2) = 1;
    
    % Subject 12
    trajectories(12, 1, 1) = 2;
    trajectories(12, 1, 2) = 1;
    trajectories(12, 2, 1) = 1;
    trajectories(12, 2, 2) = 1;
    
    % Subject 13
    trajectories(13, 1, 1) = 1;
    trajectories(13, 1, 2) = 2;
    trajectories(13, 2, 1) = 1;
    trajectories(13, 2, 2) = 1;
    
    % Subject 14
    trajectories(14, 1, 1) = 1;
    trajectories(14, 1, 2) = 2;
    trajectories(14, 2, 1) = 2;
    trajectories(14, 2, 2) = 1;
    
    % Subject 15
    trajectories(15, 1, 1) = 2;
    trajectories(15, 1, 2) = 1;
    trajectories(15, 2, 1) = 2;
    trajectories(15, 2, 2) = 1;
    
    % Subject 17
    trajectories(17, 1, 1) = 2;
    trajectories(17, 1, 2) = 1;
    trajectories(17, 2, 1) = 1;
    trajectories(17, 2, 2) = 2;
    
    % Subject 19
    trajectories(19, 1, 1) = 2;
    trajectories(19, 1, 2) = 1;
    trajectories(19, 2, 1) = 2;
    trajectories(19, 2, 2) = 1;

end % get_assigned_trajectories
