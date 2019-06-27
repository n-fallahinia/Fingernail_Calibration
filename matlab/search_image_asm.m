clear;
clc;
close all;

% Define image size
num_rows = 240;
num_columns = 320;
limits_x = [-3 3];
desired_length = 20;
num_linePoints = 100;
edge_scale = 0.01;
debug_mode = false;
stdNoise = 5;
param_weights = ones(4,1);

% Load the ASM model
load('sample_asm_model.mat');

% Generate a new sample image
deviation = 0.33;
theta_new = 0.3;
scale_new = 1.1;
tx_new = 0.5;
ty_new = -0.5;
new_shape = [1 -1; 0 -1; -1 -1; -1 1; 0 1; 1 1];
num_points = size(new_shape,1);
new_shape(1,1) = new_shape(1,1) - deviation;
new_shape(1,2) = new_shape(1,2) - deviation;
new_shape(num_points,1) = new_shape(num_points,1) - deviation;
new_shape(num_points,2) = new_shape(num_points,2) + deviation;
new_shape = move_shape(new_shape, theta_new, scale_new, tx_new, ty_new);

% Form a sample image
imgIn = form_sample_image(new_shape, [num_rows num_columns], limits_x, debug_mode);
imgIn = uint8(double(imgIn) + randn(size(imgIn))*stdNoise);

% Display the sample image
new_image = shape_to_image_coordinates(new_shape, [num_rows num_columns], limits_x);
P1 = new_image(contour(:,1),:);
P2 = new_image(contour(:,2),:);
figure(1);
subplot(2,2,1);
imshow(imgIn);
hold on;
plot([P1(:,2) P2(:,2)],[P1(:,1) P2(:,1)],'k.-');

% Generate an estimate of the position and orientation
current_shape = move_shape(mean_shape,0.3,1.5,50,-100);

% Iterate
iter = 0;
pct_err = 100;
err_tol = 0.01;
max_iter = 10;
while ((pct_err > err_tol) && (iter < max_iter))
    % Increment the iter counter
    iter = iter + 1;
    
    % Plot the current shape
    P1 = [current_shape(contour(:,1)) current_shape(contour(:,1)+num_points)];
    P2 = [current_shape(contour(:,2)) current_shape(contour(:,2)+num_points)];
    figure(1);
    subplot(2,2,2);
    imshow(imgIn);
    hold on;
    plot([P1(:,2) P2(:,2)],[P1(:,1) P2(:,1)],'k.-');
    hold off;
    
    % Calculate estimate of model parameters
    params = eigenvectors' * (current_shape - mean_shape);
    
    % Estimate suggested movement
    dx = calculate_suggested_movement(current_shape, imgIn, contour, desired_length, num_linePoints, edge_scale);
    
    % Estimate changes to model parameters
    d_params = eigenvectors' * dx;
    
    % Update the model parameters
    params = params + param_weights.*d_params;
    
    % Verify that each parameter varies within the allowed limits
    num_params = length(d_params);
    param_scale = 1;
    for paramIdx = 1:num_params
        % If not, truncate to the limit
        if ((abs(params(paramIdx)) > 3*eigenvalues(paramIdx)) && (param_scale < params(paramIdx)/(3*eigenvalues(paramIdx))))
            param_scale = 3*eigenvalues(paramIdx)*sign(params(paramIdx))/params(paramIdx);
        end
    end % paramIdx
    params = params * param_scale;
    
    % Calculate the new shape
    new_shape = mean_shape + eigenvectors * params;
    
    % Find the percent error
    pct_err = max(abs((new_shape - current_shape) ./ new_shape) * 100);
    fprintf('%02d | %6.3f\n', iter, pct_err);
    current_shape = new_shape;
end