%% Run RUSBoost model for Q14
%% Set paths etc.
addpath('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/scripts');
dirWork = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
dirOut  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/analysis_RUS';
toLoad  = 'Q14.mat';
toSave  = 'Results_RUS_Q14_noSex.mat';
load(fullfile(dirWork, toLoad));

%% Settings
numRepeats      = 50;
numPermutations = 100;
numOuterFolds   = 5;
locFeatures     = 5:size(Q14,2); % no sex
locCovariates   = [];
numObservations = size(Q14,1);

%% Generate seeds
rng(20241218, 'twister');
allSeeds  = randperm(20241218, numPermutations);
permSeeds = randperm(20241218, numPermutations);

%% Call the original dataset as data so nothing else in the code needs to change
data = Q14;

%% Create features, covariates, etc.
allFeatures = data{:,locFeatures};
allClasses  = data.caseStatus;
covars      = data{:, locCovariates};
parentID    = data.ParentID;

%% Find out which variables are continous
stdLocs     = find(cell2mat(cellfun(@(x) numel(unique(x)) > 2, mat2cell(allFeatures, numObservations, ones(length(locFeatures),1)), 'UniformOutput', false)));

%% Which features need to be corrected for covariates?
covarLocs   = [];

%% Initialize
[trainPrd, trainWts, testPrd, testWts] = deal(cell(numOuterFolds, numRepeats));

[train_FP,          train_TP,    train_FN,     train_TN,      ...
 train_sensitivity, train_specificity, train_balAccuracy,     ...
 train_AUC,         train_brier, train_brier0, train_brier1,  ...
 test_FP,           test_TP,     test_FN,      test_TN,       ...
 test_sensitivity,  test_specificity,  test_balAccuracy,      ...
 test_AUC,          test_brier,  test_brier0,  test_brier1] = ...
 deal(zeros(numOuterFolds, numRepeats));

[perm_trainPrd, perm_trainWts, perm_testPrd, perm_testWts] = deal(cell(numOuterFolds, numPermutations));

[perm_train_FP,          perm_train_TP,    perm_train_FN,     perm_train_TN,      ...
 perm_train_sensitivity, perm_train_specificity, perm_train_balAccuracy,          ...
 perm_train_AUC,         perm_train_brier, perm_train_brier0, perm_train_brier1,  ...
 perm_test_FP,           perm_test_TP,     perm_test_FN,      perm_test_TN,       ...
 perm_test_sensitivity,  perm_test_specificity,  perm_test_balAccuracy,           ...
 perm_test_AUC,          perm_test_brier,  perm_test_brier0,  perm_test_brier1] = ...
 deal(zeros(numOuterFolds, numPermutations));

[mean_trainSensitivity, mean_trainSpecificity, mean_trainBalAccuracy, ...
 mean_trainBrierScore,  mean_trainBrierScore0, mean_trainBrierScore1, ...
 mean_trainAUC,         mean_testSensitivity,  mean_testSpecificity,  ...
 mean_testBalAccuracy,  mean_testBrierScore,   mean_testBrierScore0,  ...
 mean_testBrierScore1,  mean_testAUC] = deal(zeros(numRepeats, 1));

[perm_mean_trainSensitivity, perm_mean_trainSpecificity, perm_mean_trainBalAccuracy, ...
 perm_mean_trainBrierScore,  perm_mean_trainBrierScore0, perm_mean_trainBrierScore1, ...
 perm_mean_trainAUC,         perm_mean_testSensitivity,  perm_mean_testSpecificity,  ...
 perm_mean_testBalAccuracy,  perm_mean_testBrierScore,   perm_mean_testBrierScore0,  ...
 perm_mean_testBrierScore1,  perm_mean_testAUC] = deal(zeros(numPermutations, 1));

%% Parallel pool
local            = parcluster('local');
local.NumThreads = 2;
pool             = local.parpool(50, 'IdleTimeout', 240);

%% Main cross-validation module
parfor rep = 1:numRepeats

    % Set seed
    rng(allSeeds(rep), 'twister');

    % Partition
    [trainIDX, testIDX] = makeCV(parentID, allClasses, numOuterFolds);

    %% Cross-validation
    for folds = 1:numOuterFolds
        % For clarity, slice the variables
        tmp_trainFeatures = allFeatures(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures  = allFeatures(testIDX{folds},  :);
        tmp_trainClasses  = allClasses(trainIDX{folds});
        tmp_testClasses   = allClasses(testIDX{folds});
        tmp_trainCovars   = covars(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars    = covars(testIDX{folds},  :);
        tmp_parentID      = parentID(trainIDX{folds});

        % Train RUSBoost and make prediction using this trained model
        [trainPrd{folds,rep}, trainWts{folds,rep}, testPrd{folds,rep},  testWts{folds,rep}] = ...
         doRUS(tmp_trainFeatures,   tmp_testFeatures,    tmp_trainClasses, ...
               tmp_trainCovars,     tmp_testCovars,      covarLocs,  stdLocs);

        % Evaluate the model training performance
        [train_FP(folds,rep), train_TP(folds,rep), train_FN(folds,rep), train_TN(folds,rep),         ...
         train_sensitivity(folds,rep), train_specificity(folds,rep), train_balAccuracy(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, trainPrd{folds,rep});

        % Evaluate the model test performance
        [test_FP(folds,rep), test_TP(folds,rep), test_FN(folds,rep), test_TN(folds,rep),          ...
         test_sensitivity(folds,rep), test_specificity(folds,rep), test_balAccuracy(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, testPrd{folds,rep});

        % Calculate area under the curve
        [~, ~, ~, train_AUC(folds,rep)] = perfcurve(tmp_trainClasses, trainWts{folds,rep}(:,2), 1);
        [~, ~, ~, test_AUC(folds, rep)] = perfcurve(tmp_testClasses,  testWts{folds,rep}(:,2),  1);
        
        % Stratified Brier score for training
        [train_brier(folds,rep), train_brier0(folds,rep), train_brier1(folds,rep)] = ...
         stratified_brier_score(trainWts{folds,rep}(:,1), trainWts{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for test
        [test_brier(folds,rep), test_brier0(folds,rep), test_brier1(folds,rep)] = ...
         stratified_brier_score(testWts{folds,rep}(:,1), testWts{folds,rep}(:,2), tmp_testClasses);
    end
end

%% Average performance metrics over each fold for every repeat
for rep = 1:numRepeats
    mean_trainSensitivity(rep,1) = mean(train_sensitivity(:,rep));
    mean_trainSpecificity(rep,1) = mean(train_specificity(:,rep));
    mean_trainBalAccuracy(rep,1) = mean(train_balAccuracy(:,rep));
    mean_trainBrierScore(rep, 1) = mean(train_brier(:,rep));
    mean_trainBrierScore0(rep,1) = mean(train_brier0(:,rep));
    mean_trainBrierScore1(rep,1) = mean(train_brier1(:,rep));
    mean_trainAUC(rep,1)         = mean(train_AUC(:,rep));

    mean_testSensitivity(rep,1) = mean(test_sensitivity(:,rep));
    mean_testSpecificity(rep,1) = mean(test_specificity(:,rep));
    mean_testBalAccuracy(rep,1) = mean(test_balAccuracy(:,rep));
    mean_testBrierScore(rep, 1) = mean(test_brier(:,rep));
    mean_testBrierScore0(rep,1) = mean(test_brier0(:,rep));
    mean_testBrierScore1(rep,1) = mean(test_brier1(:,rep));
    mean_testAUC(rep,1)         = mean(test_AUC(:,rep));
end

%% Permutation testing module
parfor rep = 1:numPermutations

    % First set the seed for permuting dataset
    rng(permSeeds(rep), 'twister');

    % Permuted labels
    numCases    = sum(allClasses);
    permClasses = zeros(length(allClasses), 1);
    someLocs    = randperm(length(allClasses), numCases);
    permClasses(someLocs) = 1;
    
    % Set seed
    rng(allSeeds(rep), 'twister');

    % Partition
    [trainIDX, testIDX] = makeCV(parentID, permClasses, numOuterFolds);

    % Cross-validation
    for folds = 1:numOuterFolds
        % For clarity, slice the variables
        tmp_trainFeatures = allFeatures(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures  = allFeatures(testIDX{folds},  :);
        tmp_trainClasses  = permClasses(trainIDX{folds});
        tmp_testClasses   = permClasses(testIDX{folds});
        tmp_trainCovars   = covars(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars    = covars(testIDX{folds},  :);
        tmp_parentID      = parentID(trainIDX{folds});

        % Train RUSBoost and make prediction using this trained model
        [perm_trainPrd{folds,rep}, perm_trainWts{folds,rep}, perm_testPrd{folds,rep},  perm_testWts{folds,rep}] = ...
         doRUS(tmp_trainFeatures,   tmp_testFeatures,    tmp_trainClasses, ...
               tmp_trainCovars,     tmp_testCovars,      covarLocs,  stdLocs);

        % Evaluate the model training performance
        [perm_train_FP(folds,rep), perm_train_TP(folds,rep), perm_train_FN(folds,rep), perm_train_TN(folds,rep),    ...
         perm_train_sensitivity(folds,rep), perm_train_specificity(folds,rep), perm_train_balAccuracy(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, perm_trainPrd{folds,rep});

        % Evaluate the model test performance
        [perm_test_FP(folds,rep), perm_test_TP(folds,rep), perm_test_FN(folds,rep), perm_test_TN(folds,rep),     ...
         perm_test_sensitivity(folds,rep), perm_test_specificity(folds,rep), perm_test_balAccuracy(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, perm_testPrd{folds,rep});

        % Calculate area under the curve
        [~, ~, ~, perm_train_AUC(folds,rep)] = perfcurve(tmp_trainClasses, perm_trainWts{folds,rep}(:,2), 1);
        [~, ~, ~, perm_test_AUC(folds, rep)] = perfcurve(tmp_testClasses,  perm_testWts{folds,rep}(:,2),  1);
        
        % Stratified Brier score for training
        [perm_train_brier(folds,rep), perm_train_brier0(folds,rep), perm_train_brier1(folds,rep)] = ...
         stratified_brier_score(perm_trainWts{folds,rep}(:,1), perm_trainWts{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for test
        [perm_test_brier(folds,rep), perm_test_brier0(folds,rep), perm_test_brier1(folds,rep)] = ...
         stratified_brier_score(perm_testWts{folds,rep}(:,1), perm_testWts{folds,rep}(:,2), tmp_testClasses);
    end
end

% Average performance metrics over each fold for every repeat
for rep = 1:numPermutations
    perm_mean_trainSensitivity(rep,1) = mean(perm_train_sensitivity(:,rep));
    perm_mean_trainSpecificity(rep,1) = mean(perm_train_specificity(:,rep));
    perm_mean_trainBalAccuracy(rep,1) = mean(perm_train_balAccuracy(:,rep));
    perm_mean_trainBrierScore(rep, 1) = mean(perm_train_brier(:,rep));
    perm_mean_trainBrierScore0(rep,1) = mean(perm_train_brier0(:,rep));
    perm_mean_trainBrierScore1(rep,1) = mean(perm_train_brier1(:,rep));
    perm_mean_trainAUC(rep,1)         = mean(perm_train_AUC(:,rep));

    perm_mean_testSensitivity(rep,1) = mean(perm_test_sensitivity(:,rep));
    perm_mean_testSpecificity(rep,1) = mean(perm_test_specificity(:,rep));
    perm_mean_testBalAccuracy(rep,1) = mean(perm_test_balAccuracy(:,rep));
    perm_mean_testBrierScore(rep, 1) = mean(perm_test_brier(:,rep));
    perm_mean_testBrierScore0(rep,1) = mean(perm_test_brier0(:,rep));
    perm_mean_testBrierScore1(rep,1) = mean(perm_test_brier1(:,rep));
    perm_mean_testAUC(rep,1)         = mean(perm_test_AUC(:,rep));
end

%% Delete parallel pool
delete(pool);
clear local;
clear data *_workSet

%% Save variables
if not(exist(dirOut, 'dir'))
    mkdir(dirOut);
end
save(fullfile(dirOut, toSave), '-v7.3');