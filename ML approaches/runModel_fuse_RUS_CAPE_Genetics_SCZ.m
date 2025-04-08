%% Run RUSBoost model for CAPE + Genetics
%% Set paths etc.
addpath('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/scripts');
dirWork = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
dirOut  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/analysis_fuse_RUS';
toLoad  = 'CAPE.mat';
toLoad2 = 'Genetics.mat';
toSave  = 'Results_fuse_RUS_CAPE_Genetics_SCZ.mat';
load(fullfile(dirWork, toLoad));
load(fullfile(dirWork, toLoad2));

%% Call these datasets 1, 2, and 3
data1 = CAPE;
data2 = Genetics;

%% Subset to common
[a, b]      = histcounts(categorical(vertcat(data1.ID_2445, data2.ID_2445)));
commonSubjs = b(a == 2);
data1       = data1(ismember(data1.ID_2445, commonSubjs), :);
data2       = data2(ismember(data2.ID_2445, commonSubjs), :);

%% Ensure same ordering
data1 = sortrows(data1, 'ID_2445');
data2 = sortrows(data2, 'ID_2445');

if sum(strcmpi(data1.ID_2445, data2.ID_2445)) ~= height(data1)
        error('Something went wrong when aligning tables');
end

%% Additionally merge
dataFuse = innerjoin(data1, data2);

%% Ensure same ordering
if sum(strcmpi(data1.ID_2445, dataFuse.ID_2445)) ~= height(data1)
        error('Something went wrong when aligning tables');
end

%% Settings
numRepeats      = 50;
numPermutations = 100;
numOuterFolds   = 5;
numObservations = size(data1,1);

%% Feature locations
locFeatures_1 = 4:size(data1,2);
locFeatures_2 = find(not(cellfun(@isempty, regexpi(data2.Properties.VariableNames, '^SCZ_Pt'))));
locFeatures_F = [locFeatures_1, find(not(cellfun(@isempty, regexpi(dataFuse.Properties.VariableNames, '^SCZ_Pt'))))];

%% Covariate locations
locCovariates_1 = [];
locCovariates_2 = setdiff([find(not(cellfun(@isempty, regexpi(data2.Properties.VariableNames, '^PC')))), ...
                   find(strcmpi(data2.Properties.VariableNames, 'sex')), ...
                   find(not(cellfun(@isempty, regexpi(data2.Properties.VariableNames, '^Batch'))))], ...
                   find(strcmpi(data2.Properties.VariableNames, 'Batch_24')));
locCovariates_F = setdiff([find(not(cellfun(@isempty, regexpi(dataFuse.Properties.VariableNames, '^PC')))), ...
                   find(strcmpi(dataFuse.Properties.VariableNames, 'sex')), ...
                   find(not(cellfun(@isempty, regexpi(dataFuse.Properties.VariableNames, '^Batch'))))], ...
                   find(strcmpi(dataFuse.Properties.VariableNames, 'Batch_24')));

%% Generate seeds
rng(20241218, 'twister');
allSeeds  = randperm(20241218, numPermutations);
permSeeds = randperm(20241218, numPermutations);

%% Create features, covariates, etc.
allFeatures_1 = data1{:, locFeatures_1};
allFeatures_2 = data2{:, locFeatures_2};
allFeatures_F = dataFuse{:, locFeatures_F};
covars_1      = data1{:, locCovariates_1};
covars_2      = data2{:, locCovariates_2};
covars_F      = dataFuse{:, locCovariates_F};

% Remains same across datasets
allClasses   = data1.caseStatus;
parentID     = data1.ParentID;

%% Find out which variables are continous
stdLocs_1 = find(cell2mat(cellfun(@(x) numel(unique(x)) > 2, mat2cell(allFeatures_1, numObservations, ones(length(locFeatures_1),1)), 'UniformOutput', false)));
stdLocs_2 = find(cell2mat(cellfun(@(x) numel(unique(x)) > 2, mat2cell(allFeatures_2, numObservations, ones(length(locFeatures_2),1)), 'UniformOutput', false)));
stdLocs_F = find(cell2mat(cellfun(@(x) numel(unique(x)) > 2, mat2cell(allFeatures_F, numObservations, ones(length(locFeatures_F),1)), 'UniformOutput', false)));

%% Which features need to be corrected for covariates?
covarLocs_1 = [];
covarLocs_2 = 1:size(allFeatures_2,2);
covarLocs_F = size(allFeatures_1,2)+1:size(allFeatures_F,2);

%% Initialize
[trainPrd_1, trainWts_1, testPrd_1, testWts_1] = deal(cell(numOuterFolds, numRepeats));
[trainPrd_2, trainWts_2, testPrd_2, testWts_2] = deal(cell(numOuterFolds, numRepeats));
[trainPrd_F, trainWts_F, testPrd_F, testWts_F] = deal(cell(numOuterFolds, numRepeats));

[train_FP_1,          train_TP_1,    train_FN_1,     train_TN_1,        ...
 train_sensitivity_1, train_specificity_1, train_balAccuracy_1,         ...
 train_AUC_1,         train_brier_1, train_brier0_1, train_brier1_1,    ...
 test_FP_1,           test_TP_1,     test_FN_1,      test_TN_1,         ...
 test_sensitivity_1,  test_specificity_1,  test_balAccuracy_1,          ...
 test_AUC_1,          test_brier_1,  test_brier0_1,  test_brier1_1] =   ...
 deal(zeros(numOuterFolds, numRepeats));

[train_FP_2,          train_TP_2,    train_FN_2,     train_TN_2,        ...
 train_sensitivity_2, train_specificity_2, train_balAccuracy_2,         ...
 train_AUC_2,         train_brier_2, train_brier0_2, train_brier1_2,    ...
 test_FP_2,           test_TP_2,     test_FN_2,      test_TN_2,         ...
 test_sensitivity_2,  test_specificity_2,  test_balAccuracy_2,          ...
 test_AUC_2,          test_brier_2,  test_brier0_2,  test_brier1_2] =   ...
 deal(zeros(numOuterFolds, numRepeats));

[train_FP_F,          train_TP_F,    train_FN_F,     train_TN_F,        ...
 train_sensitivity_F, train_specificity_F, train_balAccuracy_F,         ...
 train_AUC_F,         train_brier_F, train_brier0_F, train_brier1_F,    ...
 test_FP_F,           test_TP_F,     test_FN_F,      test_TN_F,         ...
 test_sensitivity_F,  test_specificity_F,  test_balAccuracy_F,          ...
 test_AUC_F,          test_brier_F,  test_brier0_F,  test_brier1_F] =   ...
 deal(zeros(numOuterFolds, numRepeats));

[perm_trainPrd_1, perm_trainWts_1, perm_testPrd_1, perm_testWts_1] = deal(cell(numOuterFolds, numPermutations));
[perm_trainPrd_2, perm_trainWts_2, perm_testPrd_2, perm_testWts_2] = deal(cell(numOuterFolds, numPermutations));
[perm_trainPrd_F, perm_trainWts_F, perm_testPrd_F, perm_testWts_F] = deal(cell(numOuterFolds, numPermutations));

[perm_train_FP_1,          perm_train_TP_1,    perm_train_FN_1,     perm_train_TN_1,        ...
 perm_train_sensitivity_1, perm_train_specificity_1, perm_train_balAccuracy_1,              ...
 perm_train_AUC_1,         perm_train_brier_1, perm_train_brier0_1, perm_train_brier1_1,    ...
 perm_test_FP_1,           perm_test_TP_1,     perm_test_FN_1,      perm_test_TN_1,         ...
 perm_test_sensitivity_1,  perm_test_specificity_1,  perm_test_balAccuracy_1,               ...
 perm_test_AUC_1,          perm_test_brier_1,  perm_test_brier0_1,  perm_test_brier1_1] =   ...
 deal(zeros(numOuterFolds, numPermutations));

[perm_train_FP_2,          perm_train_TP_2,    perm_train_FN_2,     perm_train_TN_2,        ...
 perm_train_sensitivity_2, perm_train_specificity_2, perm_train_balAccuracy_2,              ...
 perm_train_AUC_2,         perm_train_brier_2, perm_train_brier0_2, perm_train_brier1_2,    ...
 perm_test_FP_2,           perm_test_TP_2,     perm_test_FN_2,      perm_test_TN_2,         ...
 perm_test_sensitivity_2,  perm_test_specificity_2,  perm_test_balAccuracy_2,               ...
 perm_test_AUC_2,          perm_test_brier_2,  perm_test_brier0_2,  perm_test_brier1_2] =   ...
 deal(zeros(numOuterFolds, numPermutations));

[perm_train_FP_F,          perm_train_TP_F,    perm_train_FN_F,     perm_train_TN_F,        ...
 perm_train_sensitivity_F, perm_train_specificity_F, perm_train_balAccuracy_F,              ...
 perm_train_AUC_F,         perm_train_brier_F, perm_train_brier0_F, perm_train_brier1_F,    ...
 perm_test_FP_F,           perm_test_TP_F,     perm_test_FN_F,      perm_test_TN_F,         ...
 perm_test_sensitivity_F,  perm_test_specificity_F,  perm_test_balAccuracy_F,               ...
 perm_test_AUC_F,          perm_test_brier_F,  perm_test_brier0_F,  perm_test_brier1_F] =   ...
 deal(zeros(numOuterFolds, numPermutations));

[mean_trainSensitivity_1, mean_trainSpecificity_1, mean_trainBalAccuracy_1, ...
 mean_trainBrierScore_1,  mean_trainBrierScore0_1, mean_trainBrierScore1_1, ...
 mean_trainAUC_1,         mean_testSensitivity_1,  mean_testSpecificity_1,  ...
 mean_testBalAccuracy_1,  mean_testBrierScore_1,   mean_testBrierScore0_1,  ...
 mean_testBrierScore1_1,  mean_testAUC_1] = deal(zeros(numRepeats, 1));

[mean_trainSensitivity_2, mean_trainSpecificity_2, mean_trainBalAccuracy_2, ...
 mean_trainBrierScore_2,  mean_trainBrierScore0_2, mean_trainBrierScore1_2, ...
 mean_trainAUC_2,         mean_testSensitivity_2,  mean_testSpecificity_2,  ...
 mean_testBalAccuracy_2,  mean_testBrierScore_2,   mean_testBrierScore0_2,  ...
 mean_testBrierScore1_2,  mean_testAUC_2] = deal(zeros(numRepeats, 1));

[mean_trainSensitivity_F, mean_trainSpecificity_F, mean_trainBalAccuracy_F, ...
 mean_trainBrierScore_F,  mean_trainBrierScore0_F, mean_trainBrierScore1_F, ...
 mean_trainAUC_F,         mean_testSensitivity_F,  mean_testSpecificity_F,  ...
 mean_testBalAccuracy_F,  mean_testBrierScore_F,   mean_testBrierScore0_F,  ...
 mean_testBrierScore1_F,  mean_testAUC_F] = deal(zeros(numRepeats, 1));

[perm_mean_trainSensitivity_1, perm_mean_trainSpecificity_1, perm_mean_trainBalAccuracy_1, ...
 perm_mean_trainBrierScore_1,  perm_mean_trainBrierScore0_1, perm_mean_trainBrierScore1_1, ...
 perm_mean_trainAUC_1,         perm_mean_testSensitivity_1,  perm_mean_testSpecificity_1,  ...
 perm_mean_testBalAccuracy_1,  perm_mean_testBrierScore_1,   perm_mean_testBrierScore0_1,  ...
 perm_mean_testBrierScore1_1,  perm_mean_testAUC_1] = deal(zeros(numPermutations, 1));

[perm_mean_trainSensitivity_2, perm_mean_trainSpecificity_2, perm_mean_trainBalAccuracy_2, ...
 perm_mean_trainBrierScore_2,  perm_mean_trainBrierScore0_2, perm_mean_trainBrierScore1_2, ...
 perm_mean_trainAUC_2,         perm_mean_testSensitivity_2,  perm_mean_testSpecificity_2,  ...
 perm_mean_testBalAccuracy_2,  perm_mean_testBrierScore_2,   perm_mean_testBrierScore0_2,  ...
 perm_mean_testBrierScore1_2,  perm_mean_testAUC_2] = deal(zeros(numPermutations, 1));

[perm_mean_trainSensitivity_F, perm_mean_trainSpecificity_F, perm_mean_trainBalAccuracy_F, ...
 perm_mean_trainBrierScore_F,  perm_mean_trainBrierScore0_F, perm_mean_trainBrierScore1_F, ...
 perm_mean_trainAUC_F,         perm_mean_testSensitivity_F,  perm_mean_testSpecificity_F,  ...
 perm_mean_testBalAccuracy_F,  perm_mean_testBrierScore_F,   perm_mean_testBrierScore0_F,  ...
 perm_mean_testBrierScore1_F,  perm_mean_testAUC_F] = deal(zeros(numPermutations, 1));

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
        %% For clarity, slice the variables
        tmp_trainFeatures_1 = allFeatures_1(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures_1  = allFeatures_1(testIDX{folds},  :);
        tmp_trainCovars_1   = covars_1(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars_1    = covars_1(testIDX{folds},  :);

        tmp_trainFeatures_2 = allFeatures_2(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures_2  = allFeatures_2(testIDX{folds},  :);
        tmp_trainCovars_2   = covars_2(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars_2    = covars_2(testIDX{folds},  :);

        tmp_trainFeatures_F = allFeatures_F(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures_F  = allFeatures_F(testIDX{folds},  :);
        tmp_trainCovars_F   = covars_F(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars_F    = covars_F(testIDX{folds},  :);        

        tmp_parentID        = parentID(trainIDX{folds});
        tmp_trainClasses    = allClasses(trainIDX{folds});
        tmp_testClasses     = allClasses(testIDX{folds});

        % Train RUSBoost and make prediction using this trained model - 1
        [trainPrd_1{folds,rep}, trainWts_1{folds,rep}, testPrd_1{folds,rep},  testWts_1{folds,rep}] = ...
         doRUS(tmp_trainFeatures_1,   tmp_testFeatures_1,    tmp_trainClasses, ...
               tmp_trainCovars_1,     tmp_testCovars_1,      covarLocs_1,  stdLocs_1);

        % Train RUSBoost and make prediction using this trained model - 2
        [trainPrd_2{folds,rep}, trainWts_2{folds,rep}, testPrd_2{folds,rep},  testWts_2{folds,rep}] = ...
         doRUS(tmp_trainFeatures_2,   tmp_testFeatures_2,    tmp_trainClasses, ...
               tmp_trainCovars_2,     tmp_testCovars_2,      covarLocs_2,  stdLocs_2);

        % Train RUSBoost and make predictions using the fused dataset
        [trainPrd_F{folds,rep}, trainWts_F{folds,rep}, testPrd_F{folds,rep},  testWts_F{folds,rep}] = ...
         doRUS(tmp_trainFeatures_F,   tmp_testFeatures_F,    tmp_trainClasses, ...
               tmp_trainCovars_F,     tmp_testCovars_F,      covarLocs_F,  stdLocs_F);

        % Evaluate the model training performance - 1
        [train_FP_1(folds,rep), train_TP_1(folds,rep), train_FN_1(folds,rep), train_TN_1(folds,rep),         ...
         train_sensitivity_1(folds,rep), train_specificity_1(folds,rep), train_balAccuracy_1(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, trainPrd_1{folds,rep});

        % Evaluate the model training performance - 2
        [train_FP_2(folds,rep), train_TP_2(folds,rep), train_FN_2(folds,rep), train_TN_2(folds,rep),         ...
         train_sensitivity_2(folds,rep), train_specificity_2(folds,rep), train_balAccuracy_2(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, trainPrd_2{folds,rep});

        % Evaluate the model training performance - fused
        [train_FP_F(folds,rep), train_TP_F(folds,rep), train_FN_F(folds,rep), train_TN_F(folds,rep),         ...
         train_sensitivity_F(folds,rep), train_specificity_F(folds,rep), train_balAccuracy_F(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, trainPrd_F{folds,rep});
                
        % Evaluate the model test performance - 1
        [test_FP_1(folds,rep), test_TP_1(folds,rep), test_FN_1(folds,rep), test_TN_1(folds,rep),          ...
         test_sensitivity_1(folds,rep), test_specificity_1(folds,rep), test_balAccuracy_1(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, testPrd_1{folds,rep});

        % Evaluate the model test performance - 2
        [test_FP_2(folds,rep), test_TP_2(folds,rep), test_FN_2(folds,rep), test_TN_2(folds,rep),          ...
         test_sensitivity_2(folds,rep), test_specificity_2(folds,rep), test_balAccuracy_2(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, testPrd_2{folds,rep});

        % Evaluate the model test performance - fused
        [test_FP_F(folds,rep), test_TP_F(folds,rep), test_FN_F(folds,rep), test_TN_F(folds,rep),          ...
         test_sensitivity_F(folds,rep), test_specificity_F(folds,rep), test_balAccuracy_F(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, testPrd_F{folds,rep});

        % Calculate area under the curve - 1
        [~, ~, ~, train_AUC_1(folds,rep)] = perfcurve(tmp_trainClasses, trainWts_1{folds,rep}(:,2), 1);
        [~, ~, ~, test_AUC_1(folds, rep)] = perfcurve(tmp_testClasses,  testWts_1{folds,rep}(:,2),  1);

        % Calculate area under the curve - 2
        [~, ~, ~, train_AUC_2(folds,rep)] = perfcurve(tmp_trainClasses, trainWts_2{folds,rep}(:,2), 1);
        [~, ~, ~, test_AUC_2(folds, rep)] = perfcurve(tmp_testClasses,  testWts_2{folds,rep}(:,2),  1);

        % Calculate area under the curve - fused
        [~, ~, ~, train_AUC_F(folds,rep)] = perfcurve(tmp_trainClasses, trainWts_F{folds,rep}(:,2), 1);
        [~, ~, ~, test_AUC_F(folds, rep)] = perfcurve(tmp_testClasses,  testWts_F{folds,rep}(:,2),  1);

        % Stratified Brier score for training - 1
        [train_brier_1(folds,rep), train_brier0_1(folds,rep), train_brier1_1(folds,rep)] = ...
         stratified_brier_score(trainWts_1{folds,rep}(:,1), trainWts_1{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for training - 2
        [train_brier_2(folds,rep), train_brier0_2(folds,rep), train_brier1_2(folds,rep)] = ...
         stratified_brier_score(trainWts_2{folds,rep}(:,1), trainWts_2{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for training - fused
        [train_brier_F(folds,rep), train_brier0_F(folds,rep), train_brier1_F(folds,rep)] = ...
         stratified_brier_score(trainWts_F{folds,rep}(:,1), trainWts_F{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for test - 1
        [test_brier_1(folds,rep), test_brier0_1(folds,rep), test_brier1_1(folds,rep)] = ...
         stratified_brier_score(testWts_1{folds,rep}(:,1), testWts_1{folds,rep}(:,2), tmp_testClasses);

        % Stratified Brier score for test - 2
        [test_brier_2(folds,rep), test_brier0_2(folds,rep), test_brier1_2(folds,rep)] = ...
         stratified_brier_score(testWts_2{folds,rep}(:,1), testWts_2{folds,rep}(:,2), tmp_testClasses);

        % Stratified Brier score for test - fused
        [test_brier_F(folds,rep), test_brier0_F(folds,rep), test_brier1_F(folds,rep)] = ...
         stratified_brier_score(testWts_F{folds,rep}(:,1), testWts_F{folds,rep}(:,2), tmp_testClasses);
    end
end

%% Average performance metrics over each fold for every repeat
for rep = 1:numRepeats
    mean_trainSensitivity_1(rep,1) = mean(train_sensitivity_1(:,rep));
    mean_trainSpecificity_1(rep,1) = mean(train_specificity_1(:,rep));
    mean_trainBalAccuracy_1(rep,1) = mean(train_balAccuracy_1(:,rep));
    mean_trainBrierScore_1(rep, 1) = mean(train_brier_1(:,rep));
    mean_trainBrierScore0_1(rep,1) = mean(train_brier0_1(:,rep));
    mean_trainBrierScore1_1(rep,1) = mean(train_brier1_1(:,rep));
    mean_trainAUC_1(rep,1)         = mean(train_AUC_1(:,rep));

    mean_testSensitivity_1(rep,1)  = mean(test_sensitivity_1(:,rep));
    mean_testSpecificity_1(rep,1)  = mean(test_specificity_1(:,rep));
    mean_testBalAccuracy_1(rep,1)  = mean(test_balAccuracy_1(:,rep));
    mean_testBrierScore_1(rep, 1)  = mean(test_brier_1(:,rep));
    mean_testBrierScore0_1(rep,1)  = mean(test_brier0_1(:,rep));
    mean_testBrierScore1_1(rep,1)  = mean(test_brier1_1(:,rep));
    mean_testAUC_1(rep,1)          = mean(test_AUC_1(:,rep));

    mean_trainSensitivity_2(rep,1) = mean(train_sensitivity_2(:,rep));
    mean_trainSpecificity_2(rep,1) = mean(train_specificity_2(:,rep));
    mean_trainBalAccuracy_2(rep,1) = mean(train_balAccuracy_2(:,rep));
    mean_trainBrierScore_2(rep, 1) = mean(train_brier_2(:,rep));
    mean_trainBrierScore0_2(rep,1) = mean(train_brier0_2(:,rep));
    mean_trainBrierScore1_2(rep,1) = mean(train_brier1_2(:,rep));
    mean_trainAUC_2(rep,1)         = mean(train_AUC_2(:,rep));

    mean_testSensitivity_2(rep,1)  = mean(test_sensitivity_2(:,rep));
    mean_testSpecificity_2(rep,1)  = mean(test_specificity_2(:,rep));
    mean_testBalAccuracy_2(rep,1)  = mean(test_balAccuracy_2(:,rep));
    mean_testBrierScore_2(rep, 1)  = mean(test_brier_2(:,rep));
    mean_testBrierScore0_2(rep,1)  = mean(test_brier0_2(:,rep));
    mean_testBrierScore1_2(rep,1)  = mean(test_brier1_2(:,rep));
    mean_testAUC_2(rep,1)          = mean(test_AUC_2(:,rep));

    mean_trainSensitivity_F(rep,1) = mean(train_sensitivity_F(:,rep));
    mean_trainSpecificity_F(rep,1) = mean(train_specificity_F(:,rep));
    mean_trainBalAccuracy_F(rep,1) = mean(train_balAccuracy_F(:,rep));
    mean_trainBrierScore_F(rep, 1) = mean(train_brier_F(:,rep));
    mean_trainBrierScore0_F(rep,1) = mean(train_brier0_F(:,rep));
    mean_trainBrierScore1_F(rep,1) = mean(train_brier1_F(:,rep));
    mean_trainAUC_F(rep,1)         = mean(train_AUC_F(:,rep));

    mean_testSensitivity_F(rep,1)  = mean(test_sensitivity_F(:,rep));
    mean_testSpecificity_F(rep,1)  = mean(test_specificity_F(:,rep));
    mean_testBalAccuracy_F(rep,1)  = mean(test_balAccuracy_F(:,rep));
    mean_testBrierScore_F(rep, 1)  = mean(test_brier_F(:,rep));
    mean_testBrierScore0_F(rep,1)  = mean(test_brier0_F(:,rep));
    mean_testBrierScore1_F(rep,1)  = mean(test_brier1_F(:,rep));
    mean_testAUC_F(rep,1)          = mean(test_AUC_F(:,rep));    
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
        tmp_trainFeatures_1 = allFeatures_1(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures_1  = allFeatures_1(testIDX{folds},  :);
        tmp_trainCovars_1   = covars_1(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars_1    = covars_1(testIDX{folds},  :);

        tmp_trainFeatures_2 = allFeatures_2(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures_2  = allFeatures_2(testIDX{folds},  :);
        tmp_trainCovars_2   = covars_2(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars_2    = covars_2(testIDX{folds},  :);

        tmp_trainFeatures_F = allFeatures_F(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testFeatures_F  = allFeatures_F(testIDX{folds},  :);
        tmp_trainCovars_F   = covars_F(trainIDX{folds}, :); %#ok<PFBNS>
        tmp_testCovars_F    = covars_F(testIDX{folds},  :);

        tmp_parentID      = parentID(trainIDX{folds});
        tmp_trainClasses  = permClasses(trainIDX{folds});
        tmp_testClasses   = permClasses(testIDX{folds});

        % Train RUSBoost and make prediction using this trained model - 1
        [perm_trainPrd_1{folds,rep}, perm_trainWts_1{folds,rep}, perm_testPrd_1{folds,rep},  perm_testWts_1{folds,rep}] = ...
         doRUS(tmp_trainFeatures_1,   tmp_testFeatures_1,    tmp_trainClasses, ...
               tmp_trainCovars_1,     tmp_testCovars_1,      covarLocs_1,  stdLocs_1);

        % Train RUSBoost and make prediction using this trained model - 2
        [perm_trainPrd_2{folds,rep}, perm_trainWts_2{folds,rep}, perm_testPrd_2{folds,rep},  perm_testWts_2{folds,rep}] = ...
         doRUS(tmp_trainFeatures_2,   tmp_testFeatures_2,    tmp_trainClasses, ...
               tmp_trainCovars_2,     tmp_testCovars_2,      covarLocs_2,  stdLocs_2);

        % Train RUSBoost and make prediction using this trained model - fused
        [perm_trainPrd_F{folds,rep}, perm_trainWts_F{folds,rep}, perm_testPrd_F{folds,rep},  perm_testWts_F{folds,rep}] = ...
         doRUS(tmp_trainFeatures_F,   tmp_testFeatures_F,    tmp_trainClasses, ...
               tmp_trainCovars_F,     tmp_testCovars_F,      covarLocs_F,  stdLocs_F);
        
        % Evaluate the model training performance - 1
        [perm_train_FP_1(folds,rep), perm_train_TP_1(folds,rep), perm_train_FN_1(folds,rep), perm_train_TN_1(folds,rep),    ...
         perm_train_sensitivity_1(folds,rep), perm_train_specificity_1(folds,rep), perm_train_balAccuracy_1(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, perm_trainPrd_1{folds,rep});

        % Evaluate the model training performance - 2
        [perm_train_FP_2(folds,rep), perm_train_TP_2(folds,rep), perm_train_FN_2(folds,rep), perm_train_TN_2(folds,rep),    ...
         perm_train_sensitivity_2(folds,rep), perm_train_specificity_2(folds,rep), perm_train_balAccuracy_2(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, perm_trainPrd_2{folds,rep});

        % Evaluate the model training performance - fused
        [perm_train_FP_F(folds,rep), perm_train_TP_F(folds,rep), perm_train_FN_F(folds,rep), perm_train_TN_F(folds,rep),    ...
         perm_train_sensitivity_F(folds,rep), perm_train_specificity_F(folds,rep), perm_train_balAccuracy_F(folds,rep)] = ...
         checkPerf_extended(tmp_trainClasses, perm_trainPrd_F{folds,rep});        

        % Evaluate the model test performance - 1
        [perm_test_FP_1(folds,rep), perm_test_TP_1(folds,rep), perm_test_FN_1(folds,rep), perm_test_TN_1(folds,rep),     ...
         perm_test_sensitivity_1(folds,rep), perm_test_specificity_1(folds,rep), perm_test_balAccuracy_1(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, perm_testPrd_1{folds,rep});

        % Evaluate the model test performance - 2
        [perm_test_FP_2(folds,rep), perm_test_TP_2(folds,rep), perm_test_FN_2(folds,rep), perm_test_TN_2(folds,rep),     ...
         perm_test_sensitivity_2(folds,rep), perm_test_specificity_2(folds,rep), perm_test_balAccuracy_2(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, perm_testPrd_2{folds,rep});

        % Evaluate the model test performance - fused
        [perm_test_FP_F(folds,rep), perm_test_TP_F(folds,rep), perm_test_FN_F(folds,rep), perm_test_TN_F(folds,rep),     ...
         perm_test_sensitivity_F(folds,rep), perm_test_specificity_F(folds,rep), perm_test_balAccuracy_F(folds,rep)] = ...
         checkPerf_extended(tmp_testClasses, perm_testPrd_F{folds,rep});        

        % Calculate area under the curve - 1
        [~, ~, ~, perm_train_AUC_1(folds,rep)] = perfcurve(tmp_trainClasses, perm_trainWts_1{folds,rep}(:,2), 1);
        [~, ~, ~, perm_test_AUC_1(folds, rep)] = perfcurve(tmp_testClasses,  perm_testWts_1{folds,rep}(:,2),  1);

        % Calculate area under the curve - 2
        [~, ~, ~, perm_train_AUC_2(folds,rep)] = perfcurve(tmp_trainClasses, perm_trainWts_2{folds,rep}(:,2), 1);
        [~, ~, ~, perm_test_AUC_2(folds, rep)] = perfcurve(tmp_testClasses,  perm_testWts_2{folds,rep}(:,2),  1);

        % Calculate area under the curve - fused
        [~, ~, ~, perm_train_AUC_F(folds,rep)] = perfcurve(tmp_trainClasses, perm_trainWts_F{folds,rep}(:,2), 1);
        [~, ~, ~, perm_test_AUC_F(folds, rep)] = perfcurve(tmp_testClasses,  perm_testWts_F{folds,rep}(:,2),  1);        

        % Stratified Brier score for training - 1
        [perm_train_brier_1(folds,rep), perm_train_brier0_1(folds,rep), perm_train_brier1_1(folds,rep)] = ...
         stratified_brier_score(perm_trainWts_1{folds,rep}(:,1), perm_trainWts_1{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for training - 2
        [perm_train_brier_2(folds,rep), perm_train_brier0_2(folds,rep), perm_train_brier1_2(folds,rep)] = ...
         stratified_brier_score(perm_trainWts_2{folds,rep}(:,1), perm_trainWts_2{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for training - fused
        [perm_train_brier_F(folds,rep), perm_train_brier0_F(folds,rep), perm_train_brier1_F(folds,rep)] = ...
         stratified_brier_score(perm_trainWts_F{folds,rep}(:,1), perm_trainWts_F{folds,rep}(:,2), tmp_trainClasses);

        % Stratified Brier score for test - 1
        [perm_test_brier_1(folds,rep), perm_test_brier0_1(folds,rep), perm_test_brier1_1(folds,rep)] = ...
         stratified_brier_score(perm_testWts_1{folds,rep}(:,1), perm_testWts_1{folds,rep}(:,2), tmp_testClasses);

        % Stratified Brier score for test - 2
        [perm_test_brier_2(folds,rep), perm_test_brier0_2(folds,rep), perm_test_brier1_2(folds,rep)] = ...
         stratified_brier_score(perm_testWts_2{folds,rep}(:,1), perm_testWts_2{folds,rep}(:,2), tmp_testClasses);

        % Stratified Brier score for test - fused
        [perm_test_brier_F(folds,rep), perm_test_brier0_F(folds,rep), perm_test_brier1_F(folds,rep)] = ...
         stratified_brier_score(perm_testWts_F{folds,rep}(:,1), perm_testWts_F{folds,rep}(:,2), tmp_testClasses);        
    end
end

% Average performance metrics over each fold for every repeat
for rep = 1:numPermutations
    perm_mean_trainSensitivity_1(rep,1) = mean(perm_train_sensitivity_1(:,rep));
    perm_mean_trainSpecificity_1(rep,1) = mean(perm_train_specificity_1(:,rep));
    perm_mean_trainBalAccuracy_1(rep,1) = mean(perm_train_balAccuracy_1(:,rep));
    perm_mean_trainBrierScore_1(rep, 1) = mean(perm_train_brier_1(:,rep));
    perm_mean_trainBrierScore0_1(rep,1) = mean(perm_train_brier0_1(:,rep));
    perm_mean_trainBrierScore1_1(rep,1) = mean(perm_train_brier1_1(:,rep));
    perm_mean_trainAUC_1(rep,1)         = mean(perm_train_AUC_1(:,rep));

    perm_mean_testSensitivity_1(rep,1) = mean(perm_test_sensitivity_1(:,rep));
    perm_mean_testSpecificity_1(rep,1) = mean(perm_test_specificity_1(:,rep));
    perm_mean_testBalAccuracy_1(rep,1) = mean(perm_test_balAccuracy_1(:,rep));
    perm_mean_testBrierScore_1(rep, 1) = mean(perm_test_brier_1(:,rep));
    perm_mean_testBrierScore0_1(rep,1) = mean(perm_test_brier0_1(:,rep));
    perm_mean_testBrierScore1_1(rep,1) = mean(perm_test_brier1_1(:,rep));
    perm_mean_testAUC_1(rep,1)         = mean(perm_test_AUC_1(:,rep));

    perm_mean_trainSensitivity_2(rep,1) = mean(perm_train_sensitivity_2(:,rep));
    perm_mean_trainSpecificity_2(rep,1) = mean(perm_train_specificity_2(:,rep));
    perm_mean_trainBalAccuracy_2(rep,1) = mean(perm_train_balAccuracy_2(:,rep));
    perm_mean_trainBrierScore_2(rep, 1) = mean(perm_train_brier_2(:,rep));
    perm_mean_trainBrierScore0_2(rep,1) = mean(perm_train_brier0_2(:,rep));
    perm_mean_trainBrierScore1_2(rep,1) = mean(perm_train_brier1_2(:,rep));
    perm_mean_trainAUC_2(rep,1)         = mean(perm_train_AUC_2(:,rep));

    perm_mean_testSensitivity_2(rep,1) = mean(perm_test_sensitivity_2(:,rep));
    perm_mean_testSpecificity_2(rep,1) = mean(perm_test_specificity_2(:,rep));
    perm_mean_testBalAccuracy_2(rep,1) = mean(perm_test_balAccuracy_2(:,rep));
    perm_mean_testBrierScore_2(rep, 1) = mean(perm_test_brier_2(:,rep));
    perm_mean_testBrierScore0_2(rep,1) = mean(perm_test_brier0_2(:,rep));
    perm_mean_testBrierScore1_2(rep,1) = mean(perm_test_brier1_2(:,rep));
    perm_mean_testAUC_2(rep,1)         = mean(perm_test_AUC_2(:,rep));

    perm_mean_trainSensitivity_F(rep,1) = mean(perm_train_sensitivity_F(:,rep));
    perm_mean_trainSpecificity_F(rep,1) = mean(perm_train_specificity_F(:,rep));
    perm_mean_trainBalAccuracy_F(rep,1) = mean(perm_train_balAccuracy_F(:,rep));
    perm_mean_trainBrierScore_F(rep, 1) = mean(perm_train_brier_F(:,rep));
    perm_mean_trainBrierScore0_F(rep,1) = mean(perm_train_brier0_F(:,rep));
    perm_mean_trainBrierScore1_F(rep,1) = mean(perm_train_brier1_F(:,rep));
    perm_mean_trainAUC_F(rep,1)         = mean(perm_train_AUC_F(:,rep));

    perm_mean_testSensitivity_F(rep,1) = mean(perm_test_sensitivity_F(:,rep));
    perm_mean_testSpecificity_F(rep,1) = mean(perm_test_specificity_F(:,rep));
    perm_mean_testBalAccuracy_F(rep,1) = mean(perm_test_balAccuracy_F(:,rep));
    perm_mean_testBrierScore_F(rep, 1) = mean(perm_test_brier_F(:,rep));
    perm_mean_testBrierScore0_F(rep,1) = mean(perm_test_brier0_F(:,rep));
    perm_mean_testBrierScore1_F(rep,1) = mean(perm_test_brier1_F(:,rep));
    perm_mean_testAUC_F(rep,1)         = mean(perm_test_AUC_F(:,rep));     
end

%% Delete parallel pool
delete(pool);
clear local;
clear *_workSet

%% Save variables
if not(exist(dirOut, 'dir'))
    mkdir(dirOut);
end
save(fullfile(dirOut, toSave), '-v7.3');