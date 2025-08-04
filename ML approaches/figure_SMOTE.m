%% Run SMOTE+SVM model for CAPE
%% Set paths etc.
addpath('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/scripts');
addpath('/ess/p697/cluster/users/parekh/software/tight_subplot');
dirWork = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
toLoad  = 'CAPE.mat';
load(fullfile(dirWork, toLoad));

%% Settings
numRepeats      = 50;
numPermutations = 100;
numOuterFolds   = 5;
numInnerFolds   = 5;
locFeatures     = 4:size(CAPE,2);
locCovariates   = [];
numObservations = size(CAPE,1);
optimizeHow     = 'balacc';
doOpt           = true;
innerSeeds      = [];
sendDouble      = false;

%% Generate seeds
rng(20241218, 'twister');
allSeeds  = randperm(20241218, numPermutations);
permSeeds = randperm(20241218, numPermutations);

%% Call the original dataset as data so nothing else in the code needs to change
data = CAPE;

%% Create features, covariates, etc.
allFeatures = data{:,locFeatures};
allClasses  = data.caseStatus;
covars      = data{:, locCovariates};
parentID    = data.ParentID;

%% Find out which variables are continous
stdLocs     = find(cell2mat(cellfun(@(x) numel(unique(x)) > 2, mat2cell(allFeatures, numObservations, ones(length(locFeatures),1)), 'UniformOutput', false)));

%% Find our which variables are categorical
catgLocs    = setdiff(1:size(allFeatures,2), stdLocs);

%% Determine which variants of SMOTE to call
% Case 1: only categorical features
if isempty(stdLocs) && ~isempty(catgLocs)
    variant = 'smoten';
else
    % Case 2: only continuous features
    if ~isempty(stdLocs) && isempty(catgLocs)
        variant = 'smote';
    else
        % Case 3: both categorical and continuous features
        if ~isempty(stdLocs) && ~isempty(catgLocs)
            variant = 'smotenc';
        else
            % Case 4: neither feature set found: error!
            error('Something went wrong; neither continuous nor categorical features found!');
        end
    end
end

%% Which features need to be corrected for covariates?
covarLocs   = [];
if isempty(covarLocs)
    toRegress = false;
else
    toRegress = true;
end

%% Initialize
[trainPrd, trainWts, testPrd, testWts] = deal(cell(numOuterFolds, numRepeats));

[train_FP,          train_TP,    train_FN,     train_TN,      ...
 train_sensitivity, train_specificity, train_balAccuracy,     ...
 train_AUC,         train_brier, train_brier0, train_brier1,  ...
 test_FP,           test_TP,     test_FN,      test_TN,       ...
 test_sensitivity,  test_specificity,  test_balAccuracy,      ...
 test_AUC,          test_brier,  test_brier0,  test_brier1] = ...
 deal(zeros(numOuterFolds, numRepeats));

[mean_trainSensitivity, mean_trainSpecificity, mean_trainBalAccuracy, ...
 mean_trainBrierScore,  mean_trainBrierScore0, mean_trainBrierScore1, ...
 mean_trainAUC,         mean_testSensitivity,  mean_testSpecificity,  ...
 mean_testBalAccuracy,  mean_testBrierScore,   mean_testBrierScore0,  ...
 mean_testBrierScore1,  mean_testAUC] = deal(zeros(numRepeats, 1));

% %% For some reason Python/MATLAB gets killed the first time we call Smote only for CAPE
% % Do a test call here
% Smote     = py.imblearn.over_sampling.SMOTE;
% resampled = Smote.fit_resample(allFeatures, py.numpy.array(allClasses));

%% Settings
% rep = 2;
% folds = 5;
% feat = 25

%% Main cross-validation module
for rep = 2

    % Set seed
    rng(allSeeds(rep), 'twister');

    % Partition
    [trainIDX, testIDX] = makeCV(parentID, allClasses, numOuterFolds);

    %% Cross-validation
    for folds = 1:numOuterFolds
        %% For clarity, slice the variables
        tmp_trainFeatures = allFeatures(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures  = allFeatures(testIDX{folds},  :);
        tmp_trainClasses  = allClasses(trainIDX{folds});
        tmp_testClasses   = allClasses(testIDX{folds});
        tmp_trainCovars   = covars(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars    = covars(testIDX{folds},  :);
        tmp_parentID      = parentID(trainIDX{folds});

        % Regress covariates from training features and apply to test prior
        % to SMOTE as there is no way to create matching covariates
        if toRegress
            [tmp_trainFeatures(:,covarLocs), tmpCoeff] = regress_covariates(tmp_trainFeatures(:,covarLocs), tmp_trainCovars);
            tmp_testFeatures(:,  covarLocs)            = regress_covariates(tmp_testFeatures(:, covarLocs), tmp_testCovars, tmpCoeff);
        end

        % Invoke SMOTE - overwrite training features and classess
        [tmp_trainFeatures_oversampled, tmp_trainClasses_oversampled] = doSMOTE(tmp_trainFeatures, tmp_trainClasses, variant, catgLocs, sendDouble);
    end
end

%% Make figure
fig  = figure('Units', 'centimeters', 'Position', [10 10 18 10]);
allH = tight_subplot(1, 3, 0.08, [0.08 0.04], [0.04 0.01]);

feat     = 25;
featName = data.Properties.VariableNames{3+feat};
hold(allH(:), 'on');

% Plot 1: training data before undersampling
histogram(allH(1), categorical(tmp_trainFeatures(tmp_trainClasses == 1, feat)), 'FaceColor', [217,95,2]./255);
allH(1).YTickLabelMode = 'auto';
allH(1).XTickLabelRotation = 0;

% Plot 2: training data after undersampling
histogram(allH(2), categorical(tmp_trainFeatures_oversampled(tmp_trainClasses_oversampled == 1, feat)), 'FaceColor', [217,95,2]./255);
allH(2).YTickLabelMode = 'auto';
allH(2).XTickLabelRotation = 90;

% Plot 3: test data
histogram(allH(3), categorical(tmp_testFeatures(tmp_testClasses == 1, feat)), 'FaceColor', [217,95,2]./255);
allH(3).YTickLabelMode = 'auto';
allH(3).XTickLabelRotation = 0;
allH(3).YTick = 0:5;

title(allH(1), [featName, ': training data - cases'], 'FontSize', 8);
title(allH(2), [featName, ': oversampled training data - cases'], 'FontSize', 8);
title(allH(3), [featName, ': test data - cases'], 'FontSize', 8);

print('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/SMOTE_issue.png', '-dpng', '-r900');
close(fig);