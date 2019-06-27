clear;
clc;
close all;

num_rows = 240;
num_columns = 320;
limits_x = [-3 3];
num_images = 10;
marker_colors = hsv(num_images);
fig_rows = ceil(sqrt(num_images));
fig_cols = ceil(num_images / fig_rows);
stdTrans = 0.5;
stdTheta = 0.2;
stdScale = 0.1;

% Define the training set
zero_shape = [1 -1; 0 -1; -1 -1; -1 1; 0 1; 1 1];
num_points = size(zero_shape,1);
contour = [1:num_points; [2:num_points 1]]';

% Plot the contour
P1 = zero_shape(contour(:,1),:);
P2 = zero_shape(contour(:,2),:);
figure(1);
plot([P1(:,1) P2(:,1)],[P1(:,2) P2(:,2)],'k.-');
axis equal;

% Assemble a data set
point_array = zeros(2*num_points, num_images);

% First image throughout array as a base shape
for imageIdx = 1:num_images
    point_array(:,imageIdx) = [zero_shape(:,1); zero_shape(:,2)];
end % imageIdx

% Three images expand the right side only
for imageIdx = 2:4
    % Bottom point
    point_array(1,imageIdx) = point_array(1,imageIdx) - 0.25*(imageIdx-1);
    point_array(num_points+1,imageIdx) = point_array(num_points+1,imageIdx) - 0.25*(imageIdx-1);
    
    % Top point
    point_array(num_points,imageIdx) = point_array(num_points,imageIdx) - 0.25*(imageIdx-1);
    point_array(2*num_points,imageIdx) = point_array(2*num_points,imageIdx) + 0.25*(imageIdx-1);
end % imageIdx

% Three images expand the left side only
for imageIdx = 5:7
    % Bottom point
    point_array(3,imageIdx) = point_array(3,imageIdx) + 0.15*(imageIdx-4);
    point_array(num_points+3,imageIdx) = point_array(num_points+3,imageIdx) - 0.15*(imageIdx-4);
    
    % Top point
    point_array(4,imageIdx) = point_array(4,imageIdx) + 0.15*(imageIdx-4);
    point_array(num_points+4,imageIdx) = point_array(num_points+4,imageIdx) + 0.15*(imageIdx-4);
end % imageIdx

% Three images expand the middle only
for imageIdx = 8:10
    % Bottom point
    point_array(num_points+2,imageIdx) = point_array(num_points+3,imageIdx) - 0.5*(imageIdx-7);
    
    % Top point
    point_array(num_points+5,imageIdx) = point_array(num_points+5,imageIdx) + 0.5*(imageIdx-7);
end % imageIdx

% Plot all images
figure(2);
for imageIdx = 1:num_images
    current_shape = [point_array(1:num_points,imageIdx) point_array(num_points+1:end,imageIdx)];
    subplot(fig_rows, fig_cols, imageIdx);
    P1 = zero_shape(contour(:,1),:);
    P2 = zero_shape(contour(:,2),:);
    plot([P1(:,1) P2(:,1)],[P1(:,2) P2(:,2)],'k.-');
    hold on;
    P1 = current_shape(contour(:,1),:);
    P2 = current_shape(contour(:,2),:);
    plot([P1(:,1) P2(:,1)],[P1(:,2) P2(:,2)],'-o','Color',marker_colors(imageIdx,:));
    hold off;
    axis equal;
end

% Translate, rotate and scale each image
tx = [0; randn(num_images-1,1)*stdTrans];
ty = [0; randn(num_images-1,1)*stdTrans];
scale = [0; randn(num_images-1,1)*stdScale] + 1.0;
theta = [0; randn(num_images-1,1)*stdTheta];
new_points = zeros(2*num_points, num_images);
for imageIdx = 1:num_images
    % Rotate, scale and translate image
    new_points(:,imageIdx) = move_shape(point_array(:,imageIdx), theta(imageIdx), scale(imageIdx), tx(imageIdx), ty(imageIdx));
end

% Plot all new images
figure(3);
for imageIdx = 1:num_images
    current_shape = [new_points(1:num_points,imageIdx) new_points(num_points+1:end,imageIdx)];
    subplot(fig_rows, fig_cols, imageIdx);
    P1 = zero_shape(contour(:,1),:);
    P2 = zero_shape(contour(:,2),:);
    plot([P1(:,1) P2(:,1)],[P1(:,2) P2(:,2)],'k.-');
    hold on;
    P1 = current_shape(contour(:,1),:);
    P2 = current_shape(contour(:,2),:);
    plot([P1(:,1) P2(:,1)],[P1(:,2) P2(:,2)],'-o','Color',marker_colors(imageIdx,:));
    hold off;
    axis equal;
end

% Convert shapes to images
for imageIdx = 1:num_images
    point_array(:,imageIdx) = shape_to_image_coordinates(new_points(:,imageIdx), [num_rows num_columns], limits_x);
end % imageIdx

% Save the data set
save('sample_data.mat','point_array','tx','ty','scale','theta','contour');
