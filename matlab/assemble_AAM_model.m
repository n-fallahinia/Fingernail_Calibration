%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assemble the Active Appearance Model (except for the Search Matrix) from
% the supplied TrainingData.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ShapeData, AppearanceData, ShapeAppearanceData] = assemble_AAM_model(TrainingData, options)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Shape Model
    % Make the Shape model, which finds the variations between contours
    % in the training data sets. And makes a PCA model describing normal
    % contours
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Making the Shape Model\n');
    [ShapeData,TrainingData] = AAM_MakeShapeModel2D(TrainingData, options);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Appearance model
    % Piecewise linear image transformation is used to align all texture
    % information inside the object (hand), to the mean handshape.
    % After transformation of all trainingdata textures to the same shape
    % PCA is used to describe the mean and variances of the object texture.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Making the Appearance Model\n');
    AppearanceData = AAM_MakeAppearanceModel2D(TrainingData, ShapeData, options);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Combined model
    % Often Shape and Texture are correlated in some way. Thus we can use
    % PCA to get a combined Shape-Appearance model.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Making the Combined Model\n');
    ShapeAppearanceData = AAM_CombineShapeAppearance2D(TrainingData, ShapeData, AppearanceData, options);

end % assemble_AAM_model