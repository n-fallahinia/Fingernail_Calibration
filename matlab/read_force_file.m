% READ_FORCE_FILE Reads an ASCII text file (force_file) containing grasping
% experiment results and extracts the corresponding forces for the finger
% specified by finger_name.
% 
% Created by Thomas R. Grieve
% 3 May 2012
% University of Utah
% 

function forces = read_force_file(force_file, finger_name)

    % Read the data from the text file
    data = load(force_file);
    t = data(:,1) - data(1,1);
    
    % Extract appropriate sensor data
    if (strcmp(finger_name,'thumb'))
        sensor_data = data(:,8:13);
        sensor_number = 1;
    elseif (strcmp(finger_name,'index'))
        sensor_data = data(:,2:7);
        sensor_number = 2;
    elseif (strcmp(finger_name,'middle'))
        sensor_data = data(:,14:19);
        sensor_number = 3;
    elseif (strcmp(finger_name,'ring'))
        sensor_data = data(:,20:25);
        sensor_number = 4;
    elseif (strcmp(finger_name,'little'))
        forces = zeros(1,6);
        return;
    else
        error('Unknown finger name!');
    end
    
    % Convert the data using the appropriate matrices
    forces = convert_sensor_to_force(sensor_data, sensor_number);

end % read_force_file

% CONVERT_SENSOR_TO_FORCE Converts a 6x1 vector representing a voltage
%   reading from a force sensor into a 6x1 vector representing a
%   force/torque measurement, in Newtons/Newton-meters.  The offsets,
%   calibration matrices and gain vectors are hard-coded into this
%   function.
%
% sensor_reading - nx6 array of voltage readings
% sensor_number  - ID number of the sensor, from 1 to 4
% 
% force_reading  - nx6 array of force/torque readings
% 

function force_reading = convert_sensor_to_force(sensor_reading, sensor_number)

    % Define offset vectors
    %offset1 = [ 0.1551    0.5446   -0.0415   -1.3598    0.1004    0.7434]; % Possibly adjusted 24 Jan 2011, Changed 01 Mar 2011.
    offset1 = [-0.1581    0.5625   -0.0669    1.3723    0.1522    0.7553]; % Adjusted 01 Mar 2011
    %offset2 = [-0.3342    0.3900   -0.3405    1.4580    0.4531    1.0799]; % Possibly adjusted 24 Jan 2011, Changed 01 Mar 2011.
    offset2 = [-0.3208    0.3220   -0.3722    1.5116    0.4719    1.0425]; % Adjusted 01 Mar 2011
    offset3 = [ 0.0252    0.9114   -0.4375    1.5700    0.2905    1.4531]; % Possibly adjusted 24 Jan 2011
    offset4 = [ 0.1772   -0.9062    0.1547   -0.0940   -0.4556   -0.7742]; % Possibly adjusted 24 Jan 2011

    % Force calibration matrices
    calib1 =[  0.06105,  -0.19672,  -1.79433,  37.70342,   2.06223, -37.52904;
               2.02210, -44.83887,  -1.40611,  21.12528,  -1.40373,  22.29920;
             -22.17321,  -0.29397, -22.09094,  -0.75540, -22.46264,  -0.83756;
               0.86343,   0.62380, -37.57811,  -1.73684,  39.28231,   1.42668;
              43.45049,   0.61411, -21.70741,  -0.41397, -23.31255,  -1.47309;
               0.44082, -22.53919,   1.48699, -21.63087,   1.43589, -22.34803];
    calib2 =[ -0.65842,  -1.15648,   0.09305, -39.16140,  -2.19197,  37.83393;
               2.89946,  47.34340, - 0.92348, -24.57660,   1.37172, -20.41436;
              22.10481,   1.67974,  23.25470,   0.44445,  21.73418,   0.82824;
               0.97212,  -0.55362,  38.70719,   1.13352, -38.59891,  -1.29096;
             -43.21316,  -3.46360,  24.60313,   0.09078,  21.31790,   1.38570;
               1.03991,  23.52516,   0.37988,  23.53217,  -1.17453,  22.59423];
    calib3 =[ -0.65842,  -1.15648,   0.09305, -39.16140,  -2.19197,  37.83393;
               2.89946,  47.34340,  -0.92348, -24.57660,   1.37172, -20.41436;
              22.10481,   1.67974,  23.25470,   0.44445,  21.73418,   0.82824;
               0.97212,  -0.55362,  38.70719,   1.13352, -38.59891,  -1.29096;
             -43.21316,  -3.46360,  24.60313,   0.09078,  21.31790,   1.38570;
               1.03991,  23.52516,   0.37988,  23.53217,  -1.17453,  22.59423];
    calib4 =[ -0.65842,  -1.15648,   0.09305, -39.16140,  -2.19197,  37.83393;
               2.89946,  47.34340, - 0.92348, -24.57660,   1.37172, -20.41436;
              22.10481,   1.67974,  23.25470,   0.44445,  21.73418,   0.82824;
               0.97212,  -0.55362,  38.70719,   1.13352, -38.59891,  -1.29096;
             -43.21316,  -3.46360,  24.60313,   0.09078,  21.31790,   1.38570;
               1.03991,  23.52516,   0.37988,  23.53217,  -1.17453,  22.59423];

    % Force Gain matrices
    gain = [22.7300084098357, 22.7300084098357, 11.7868333238604, 3.64585766892664, 3.64585766892664, 3.1484034675519];

    % Choose your own adventure
    if sensor_number == 1,
        % Load appropriate parameters
        calibration_matrix = calib1;
        sensor_offset = offset1;
        
        % Correction for sensors wired backwards
        sensor_reading(:,[1 4]) = -sensor_reading(:,[1 4]);
    elseif sensor_number == 2,
        % Load appropriate parameters
        calibration_matrix = calib2;
        sensor_offset = offset2;
    elseif sensor_number == 3,
        % Load appropriate parameters
        calibration_matrix = calib3;
        sensor_offset = offset3;
        
        % Correction for sensors wired backwards
        sensor_reading(:,[2 3 5 6]) = -sensor_reading(:,[2 3 5 6]);
    elseif sensor_number == 4,
        % Load appropriate parameters
        calibration_matrix = calib4;
        sensor_offset = offset4;
        
        % Correction for sensors wired backwards
        sensor_reading(:,[2 3 5 6]) = -sensor_reading(:,[2 3 5 6]);
    elseif (sensor_number == 5)
        % No sensor implemented for little finger yet
        sensor_reading = zeros(1,6);
        sensor_offset = zeros(1,6);
        calibration_matrix = zeros(6);
    else
        error('Invalid sensor!');
    end
    
    % Subtract the sensor offset
    nReadings = size(sensor_reading,1);
    sensor_reading_zeroed = sensor_reading - ones(nReadings,1)*sensor_offset;
    
    % Change to force readings (multiply by calibration matrix and then
    % divide by gain factor)
    force_reading = (calibration_matrix*sensor_reading_zeroed')';
    for i=1:6,
        force_reading(:,i) = force_reading(:,i) / gain(i);
    end
    
    % Correction for directionality of sensors
    if sensor_number == 1,
        % Thumb sensor is oriented 90 degrees with respect to the sensor,
        % while the z-direction force is negative because of our force
        % convention
        temp = force_reading(:,1);
        force_reading(:,1) = force_reading(:,2);
        force_reading(:,2) = -temp;
        force_reading(:,3) = -force_reading(:,3);
    else
        % Finger sensors are oriented correctly, but XY forces are
        % backwards due to our force convention
        force_reading(:,1) = -force_reading(:,1);
        force_reading(:,2) = -force_reading(:,2);
    end

end % function
