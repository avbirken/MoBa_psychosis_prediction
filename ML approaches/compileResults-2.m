function results = compileResults(varName, data, featureName, classifierName)
%% Initialize
varNames = {'Features', 'Classifier', 'nCases', 'nControls', 'nTrainCases', 'nTrainControls', 'nTestCases', 'nTestControls', ...
            'TP', 'FP', 'TN', 'FN', 'Sensitivity', 'Specificity', 'BalAccuracy', 'PermSensitivity', 'PermSpecificity', 'PermBalAccuracy'};
results  = cell(1, length(varNames));
% results  = cell2table(results, 'VariableNames', varNames);

%% Get data
load(varName, 'test_TP', 'test_TN', 'test_FP', 'test_FN', 'test_sensitivity', 'test_specificity', 'test_balAccuracy', 'perm_test_sensitivity', 'perm_test_specificity', 'perm_test_balAccuracy', 'numOuterFolds');

%% Record model name
results{1,1} = cellstr(featureName);
results{1,2} = cellstr(classifierName);

%% Number of cases and controls
results{1,3} = sum(data.caseStatus == 1);
results{1,4} = sum(data.caseStatus == 0);

% Make one split
[trainIDX, testIDX] = makeCV(data.ParentID, data.caseStatus, numOuterFolds);

% How many cases and controls do we get (on average)?
train_numCases    = zeros(numOuterFolds, 1);
train_numControls = zeros(numOuterFolds, 1);
test_numCases     = zeros(numOuterFolds, 1);
test_numControls  = zeros(numOuterFolds, 1);
for folds = 1:numOuterFolds
    tmp_trainData               = data(trainIDX{folds}, :);
    tmp_testData                = data(testIDX{folds},  :);
    train_numCases(folds,1)     = sum(tmp_trainData.caseStatus == 1);
    train_numControls(folds,1)  = sum(tmp_trainData.caseStatus == 0);
    test_numCases(folds,1)      = sum(tmp_testData.caseStatus == 1);
    test_numControls(folds,1)   = sum(tmp_testData.caseStatus == 0);    
end

results{1,5}  = ceil(mean(train_numCases));
results{1,6}  = ceil(mean(train_numControls));
results{1,7}  = ceil(mean(test_numCases));
results{1,8}  = ceil(mean(test_numControls));

%% TP, FP, TN, FN
tmp_test_TP = ceil(mean(test_TP));
tmp_test_TN = ceil(mean(test_TN));
tmp_test_FP = ceil(mean(test_FP));
tmp_test_FN = ceil(mean(test_FN));

results{1,9}  = [num2str(ceil(mean(tmp_test_TP))), ' [', num2str(min(tmp_test_TP)), '-', num2str(max(tmp_test_TP)), ']'];
results{1,10} = [num2str(ceil(mean(tmp_test_FP))), ' [', num2str(min(tmp_test_FP)), '-', num2str(max(tmp_test_FP)), ']'];
results{1,11} = [num2str(ceil(mean(tmp_test_TN))), ' [', num2str(min(tmp_test_TN)), '-', num2str(max(tmp_test_TN)), ']'];
results{1,12} = [num2str(ceil(mean(tmp_test_FN))), ' [', num2str(min(tmp_test_FN)), '-', num2str(max(tmp_test_FN)), ']'];

%% Sensitivity, specificity, balanced accuracy
tmp_sensitivity = mean(test_sensitivity) * 100;
tmp_specificity = mean(test_specificity) * 100;
tmp_balAccuracy = mean(test_balAccuracy) * 100;

results{1,13} = [num2str(mean(tmp_sensitivity), '%.02f'), ' ± ', num2str(std(tmp_sensitivity), '%.02f'), ' [', num2str(min(tmp_sensitivity), '%.02f'), '-', num2str(max(tmp_sensitivity), '%.02f'), ']'];
results{1,14} = [num2str(mean(tmp_specificity), '%.02f'), ' ± ', num2str(std(tmp_specificity), '%.02f'), ' [', num2str(min(tmp_specificity), '%.02f'), '-', num2str(max(tmp_specificity), '%.02f'), ']'];
results{1,15} = [num2str(mean(tmp_balAccuracy), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy), '%.02f'), ' [', num2str(min(tmp_balAccuracy), '%.02f'), '-', num2str(max(tmp_balAccuracy), '%.02f'), ']'];

%% Permutation sensitivity, specificity, balanced accuracy
tmp_sensitivity = mean(perm_test_sensitivity) * 100;
tmp_specificity = mean(perm_test_specificity) * 100;
tmp_balAccuracy = mean(perm_test_balAccuracy) * 100;

results{1,16} = [num2str(mean(tmp_sensitivity), '%.02f'), ' ± ', num2str(std(tmp_sensitivity), '%.02f'), ' [', num2str(min(tmp_sensitivity), '%.02f'), '-', num2str(max(tmp_sensitivity), '%.02f'), ']'];
results{1,17} = [num2str(mean(tmp_specificity), '%.02f'), ' ± ', num2str(std(tmp_specificity), '%.02f'), ' [', num2str(min(tmp_specificity), '%.02f'), '-', num2str(max(tmp_specificity), '%.02f'), ']'];
results{1,18} = [num2str(mean(tmp_balAccuracy), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy), '%.02f'), ' [', num2str(min(tmp_balAccuracy), '%.02f'), '-', num2str(max(tmp_balAccuracy), '%.02f'), ']'];
