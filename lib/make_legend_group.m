% MAKE_LEGEND_GROUP Groups a series of Matlab's lineseries objects together
% to make it easier to create legend entries for plots.  If the standard
% method of plotting Vertices from the AAM/ASM toolbox is used (i.e., the
% Lines object is used to create a set of point-pairs that are joined with
% lines), one lineseries object is created for each pair of points in the
% Shape contour.  If multiple contours are plotted and a legend is added to
% the plot, this is undesirable.  However, this function may be used to
% group all of the lineseries objects into one 'handle group' to simplify
% the legend.  An example follows.
% 
% Suppose you wish to plot the Training Data Vertices for a given image,
% and you have calculated an approximation for those vertices using the
% Active Appearance Model.  The standard method given in the  sample code
% is to form two pairs of arrays of points, P1 and P2, as follows:
% 
% P1t = TrainingData(trainingIdx).Vertices(ShapeData.Lines(:,1),:);
% P2t = TrainingData(trainingIdx).Vertices(ShapeData.Lines(:,2),:);
% P1a = shape_real_approx(ShapeData.Lines(:,1),:);
% P2a = shape_real_approx(ShapeData.Lines(:,2),:);
% figure(1);
% imshow(TrainingData(trainingIdx).I);
% hold on;
% ht = plot([P1t(:,2) P2t(:,2)]',[P1t(:,1) P2t(:,1)]','g.-');
% ha = plot([P1a(:,2) P2a(:,2)]',[P1a(:,1) P2a(:,1)]','ro-');
% hold off;
% htGroup = make_legend_group(ht);
% haGroup = make_legend_group(ha);
% legend('Training Vertices','Approximate Shape','Location','Best');
% 
% As shown above, the output of the plot commands, ht and ha, may be used
% to make legend groups that allow the two contours to be displayed and
% identified.
% 
% Created by Thomas R. Grieve
% 13 April 2012
% University of Utah
% 

function handle_group = make_legend_group(graphic_handle)

    % Create a 'legend entry' graphics handle group
    handle_group = hggroup;
    
    % Set the graphic handle's parent to be the output handle group
    set(graphic_handle,'Parent',handle_group);
    
    % Extract a pointer to the Annotation for the output handle group
    hgAnnotation = get(handle_group,'Annotation');
    
    % Extract a pointer to the Legend Entry for handle group's Annotation
    hgLegendEntry = get(hgAnnotation,'LegendInformation');
    
    % Turn on the Legend Entry for the output handle group
    set(hgLegendEntry,'IconDisplayStyle','on');

end % make_legend_group
