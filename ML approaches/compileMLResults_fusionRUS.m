%% Compile results for plotting
dirWork  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
dirRUS   = 'analysis_fuse_RUS';

%% Which files to work with?
listFiles = dir(fullfile(dirWork, dirRUS, '*.mat'));

%% Compile results
for ii = 1:length(listFiles)
    % Which variable?
    toLoad = fullfile(dirWork, dirRUS, listFiles(ii).name);

    % Detect modalities
    [modalityString{ii}, firstModality{ii}, secondModality{ii}, thirdModality{ii}] = detectModalities(toLoad);

    % Compile results
    if ii == 1
        if isempty(thirdModality{ii})
            results = compileResults_bimodal(toLoad, modalityString{ii}, firstModality{ii}, secondModality{ii});
        else
            results = compileResults_trimodal(toLoad, modalityString{ii}, firstModality{ii}, secondModality{ii}, thirdModality{ii});
        end
    else
        if isempty(thirdModality{ii})
            results = [results; compileResults_bimodal(toLoad, modalityString{ii}, firstModality{ii}, secondModality{ii})];
        else
            results = [results; compileResults_trimodal(toLoad, modalityString{ii}, firstModality{ii}, secondModality{ii}, thirdModality{ii})];
        end
    end
end

%% Make table
varNames = {'ModelName', 'ModalityName', 'nCases', 'nControls', 'nTrainCases', 'nTrainControls', 'nTestCases', 'nTestControls', ...
            'TP', 'FP', 'TN', 'FN', 'Sensitivity', 'Specificity', 'BalAccuracy', 'PermSensitivity', 'PermSpecificity', 'PermBalAccuracy'};
results  = cell2table(results, 'VariableNames', varNames);

%% Save
writetable(results, '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/summary_results_multimodal_RUSBoost.csv');

function [modalityString, firstModality, secondModality, thirdModality] = detectModalities(toLoad)
    % Variable list
    varList = whos('-file', toLoad);
    varList = {varList(:).name}';

    % Which modalities exist?
    isCAPE      = any(strcmpi(varList, 'CAPE'));
    isQ14       = any(strcmpi(varList, 'Q14'));
    isNPR       = any(strcmpi(varList, 'NPR'));
    isMBRN      = any(strcmpi(varList, 'MBRN'));
    isGenetics  = any(strcmpi(varList, 'Genetics'));

    allModalities  = {'CAPE', 'Q14', 'NPR', 'MBRN', 'Genetics_SCZ'};
    temp1          = strcat(allModalities([isCAPE, isQ14, isNPR, isMBRN, isGenetics]), {'-'});
    modalityString = horzcat(temp1{:});
    modalityString = modalityString(1:end-1);

    % Now load the data
    load(toLoad, 'data1', 'data2', 'data3', 'CAPE', 'Q14', 'NPR', 'MBRN', 'Genetics', 'loc*', 'commonSubjs');

    if not(exist('data3', 'var'))
        thirdModality = '';
    end

    % Now find out which is which modality
    if isCAPE
        try
            if isempty(find(CAPE{ismember(CAPE.ID_2445, commonSubjs), locFeatures_1} - data1{:, locFeatures_1}, 1))
                firstModality = 'CAPE';
            end
        end
        try
            if isempty(find(CAPE{ismember(CAPE.ID_2445, commonSubjs), locFeatures_2} - data2{:, locFeatures_2}, 1))
                secondModality = 'CAPE';
            end
        end
        try
            if isempty(find(CAPE{ismember(CAPE.ID_2445, commonSubjs), locFeatures_3} - data3{:, locFeatures_3}, 1))
                thirdModality = 'CAPE';
            end
        end
    end

    if isQ14
        try
            if isempty(find(Q14{ismember(Q14.ID_2445, commonSubjs), locFeatures_1} - data1{:, locFeatures_1}, 1))
                firstModality = 'Q14';
            end
        end
        try
            if isempty(find(Q14{ismember(Q14.ID_2445, commonSubjs), locFeatures_2} - data2{:, locFeatures_2}, 1))
                secondModality = 'Q14';
            end
        end
        try
            if isempty(find(Q14{ismember(Q14.ID_2445, commonSubjs), locFeatures_3} - data3{:, locFeatures_3}, 1))
                thirdModality = 'Q14';
            end
        end
    end

    if isNPR
        try
            if isempty(find(NPR{ismember(NPR.ID_2445, commonSubjs), locFeatures_1} - data1{:, locFeatures_1}, 1))
                firstModality = 'NPR';
            end
        end
        try
            if isempty(find(NPR{ismember(NPR.ID_2445, commonSubjs), locFeatures_2} - data2{:, locFeatures_2}, 1))
                secondModality = 'NPR';
            end
        end
        try
            if isempty(find(NPR{ismember(NPR.ID_2445, commonSubjs), locFeatures_3} - data3{:, locFeatures_3}, 1))
                thirdModality = 'NPR';
            end
        end
    end

    if isMBRN
        try
            if isempty(find(MBRN{ismember(MBRN.ID_2445, commonSubjs), locFeatures_1} - data1{:, locFeatures_1}, 1))
                firstModality = 'MBRN';
            end
        end
        try
            if isempty(find(MBRN{ismember(MBRN.ID_2445, commonSubjs), locFeatures_2} - data2{:, locFeatures_2}, 1))
                secondModality = 'MBRN';
            end
        end
        try
            if isempty(find(MBRN{ismember(MBRN.ID_2445, commonSubjs), locFeatures_3} - data3{:, locFeatures_3}, 1))
                thirdModality = 'MBRN';
            end
        end
    end

    if isGenetics
        try
            if isempty(find(Genetics{ismember(Genetics.ID_2445, commonSubjs), locFeatures_1} - data1{:, locFeatures_1}, 1))
                firstModality = 'Genetics';
            end
        end
        try
            if isempty(find(Genetics{ismember(Genetics.ID_2445, commonSubjs), locFeatures_2} - data2{:, locFeatures_2}, 1))
                secondModality = 'Genetics';
            end
        end
        try
            if isempty(find(Genetics{ismember(Genetics.ID_2445, commonSubjs), locFeatures_3} - data3{:, locFeatures_3}, 1))
                thirdModality = 'Genetics';
            end
        end
    end
end

% function results = summarizeResults(toLoad)
%     % Get variable list and detect modalities
%     listVariables  = whos('-file', toLoad);
%     [modalityString, firstModality, secondModality, thirdModality] = detectModalities({listVariables(:).name}', toLoad);
% 
%     % Quantify performance
% end
function results = compileResults_bimodal(toLoad, fullName, firstModality, secondModality)
% Initialize
varNames = {'ModelName', 'ModalityName', 'nCases', 'nControls', 'nTrainCases', 'nTrainControls', 'nTestCases', 'nTestControls', ...
            'TP', 'FP', 'TN', 'FN', 'Sensitivity', 'Specificity', 'BalAccuracy', 'PermSensitivity', 'PermSpecificity', 'PermBalAccuracy'};
results  = cell(3, length(varNames));

% Get data
load(toLoad, 'test_TP*', 'test_TN*', 'test_FP*', 'test_FN*', ...
             'test_sensitivity*', 'test_specificity*', 'test_balAccuracy*', ...
             'perm_test_sensitivity*', 'perm_test_specificity*', 'perm_test_balAccuracy*', ...
             'numOuterFolds', 'data1', 'loc*');

% Record basic information
results{1,1} = cellstr(fullName);
results{1,2} = cellstr(firstModality);
results{2,2} = cellstr(secondModality);
results{3,2} = 'multimodal';

% Number of cases and controls - only record once
results{1,3} = sum(data1.caseStatus == 1);
results{1,4} = sum(data1.caseStatus == 0);

% Make one split
[trainIDX, testIDX] = makeCV(data1.ParentID, data1.caseStatus, numOuterFolds);

% How many cases and controls do we get (on average)?
train_numCases    = zeros(numOuterFolds, 1);
train_numControls = zeros(numOuterFolds, 1);
test_numCases     = zeros(numOuterFolds, 1);
test_numControls  = zeros(numOuterFolds, 1);
for folds = 1:numOuterFolds
    tmp_trainData               = data1(trainIDX{folds}, :);
    tmp_testData                = data1(testIDX{folds},  :);
    train_numCases(folds,1)     = sum(tmp_trainData.caseStatus == 1);
    train_numControls(folds,1)  = sum(tmp_trainData.caseStatus == 0);
    test_numCases(folds,1)      = sum(tmp_testData.caseStatus == 1);
    test_numControls(folds,1)   = sum(tmp_testData.caseStatus == 0);    
end

results{1,5}  = ceil(mean(train_numCases));
results{1,6}  = ceil(mean(train_numControls));
results{1,7}  = ceil(mean(test_numCases));
results{1,8}  = ceil(mean(test_numControls));

% TP, FP, TN, FN - data1
tmp_test_TP_1 = ceil(mean(test_TP_1));
tmp_test_TN_1 = ceil(mean(test_TN_1));
tmp_test_FP_1 = ceil(mean(test_FP_1));
tmp_test_FN_1 = ceil(mean(test_FN_1));

results{1,9}  = [num2str(ceil(mean(tmp_test_TP_1))), ' [', num2str(min(tmp_test_TP_1)), '-', num2str(max(tmp_test_TP_1)), ']'];
results{1,10} = [num2str(ceil(mean(tmp_test_FP_1))), ' [', num2str(min(tmp_test_FP_1)), '-', num2str(max(tmp_test_FP_1)), ']'];
results{1,11} = [num2str(ceil(mean(tmp_test_TN_1))), ' [', num2str(min(tmp_test_TN_1)), '-', num2str(max(tmp_test_TN_1)), ']'];
results{1,12} = [num2str(ceil(mean(tmp_test_FN_1))), ' [', num2str(min(tmp_test_FN_1)), '-', num2str(max(tmp_test_FN_1)), ']'];

% TP, FP, TN, FN - data2
tmp_test_TP_2 = ceil(mean(test_TP_2));
tmp_test_TN_2 = ceil(mean(test_TN_2));
tmp_test_FP_2 = ceil(mean(test_FP_2));
tmp_test_FN_2 = ceil(mean(test_FN_2));

results{2,9}  = [num2str(ceil(mean(tmp_test_TP_2))), ' [', num2str(min(tmp_test_TP_2)), '-', num2str(max(tmp_test_TP_2)), ']'];
results{2,10} = [num2str(ceil(mean(tmp_test_FP_2))), ' [', num2str(min(tmp_test_FP_2)), '-', num2str(max(tmp_test_FP_2)), ']'];
results{2,11} = [num2str(ceil(mean(tmp_test_TN_2))), ' [', num2str(min(tmp_test_TN_2)), '-', num2str(max(tmp_test_TN_2)), ']'];
results{2,12} = [num2str(ceil(mean(tmp_test_FN_2))), ' [', num2str(min(tmp_test_FN_2)), '-', num2str(max(tmp_test_FN_2)), ']'];

% TP, FP, TN, FN - multimodal
tmp_test_TP_F = ceil(mean(test_TP_F));
tmp_test_TN_F = ceil(mean(test_TN_F));
tmp_test_FP_F = ceil(mean(test_FP_F));
tmp_test_FN_F = ceil(mean(test_FN_F));

results{3,9}  = [num2str(ceil(mean(tmp_test_TP_F))), ' [', num2str(min(tmp_test_TP_F)), '-', num2str(max(tmp_test_TP_F)), ']'];
results{3,10} = [num2str(ceil(mean(tmp_test_FP_F))), ' [', num2str(min(tmp_test_FP_F)), '-', num2str(max(tmp_test_FP_F)), ']'];
results{3,11} = [num2str(ceil(mean(tmp_test_TN_F))), ' [', num2str(min(tmp_test_TN_F)), '-', num2str(max(tmp_test_TN_F)), ']'];
results{3,12} = [num2str(ceil(mean(tmp_test_FN_F))), ' [', num2str(min(tmp_test_FN_F)), '-', num2str(max(tmp_test_FN_F)), ']'];

% Sensitivity, specificity, balanced accuracy - data1
tmp_sensitivity_1 = mean(test_sensitivity_1) * 100;
tmp_specificity_1 = mean(test_specificity_1) * 100;
tmp_balAccuracy_1 = mean(test_balAccuracy_1) * 100;

results{1,13} = [num2str(mean(tmp_sensitivity_1), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_1), '%.02f'), ' [', num2str(min(tmp_sensitivity_1), '%.02f'), '-', num2str(max(tmp_sensitivity_1), '%.02f'), ']'];
results{1,14} = [num2str(mean(tmp_specificity_1), '%.02f'), ' ± ', num2str(std(tmp_specificity_1), '%.02f'), ' [', num2str(min(tmp_specificity_1), '%.02f'), '-', num2str(max(tmp_specificity_1), '%.02f'), ']'];
results{1,15} = [num2str(mean(tmp_balAccuracy_1), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_1), '%.02f'), ' [', num2str(min(tmp_balAccuracy_1), '%.02f'), '-', num2str(max(tmp_balAccuracy_1), '%.02f'), ']'];

% Sensitivity, specificity, balanced accuracy - data2
tmp_sensitivity_2 = mean(test_sensitivity_2) * 100;
tmp_specificity_2 = mean(test_specificity_2) * 100;
tmp_balAccuracy_2 = mean(test_balAccuracy_2) * 100;

results{2,13} = [num2str(mean(tmp_sensitivity_2), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_2), '%.02f'), ' [', num2str(min(tmp_sensitivity_2), '%.02f'), '-', num2str(max(tmp_sensitivity_2), '%.02f'), ']'];
results{2,14} = [num2str(mean(tmp_specificity_2), '%.02f'), ' ± ', num2str(std(tmp_specificity_2), '%.02f'), ' [', num2str(min(tmp_specificity_2), '%.02f'), '-', num2str(max(tmp_specificity_2), '%.02f'), ']'];
results{2,15} = [num2str(mean(tmp_balAccuracy_2), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_2), '%.02f'), ' [', num2str(min(tmp_balAccuracy_2), '%.02f'), '-', num2str(max(tmp_balAccuracy_2), '%.02f'), ']'];

% Sensitivity, specificity, balanced accuracy - multimodal
tmp_sensitivity_F = mean(test_sensitivity_F) * 100;
tmp_specificity_F = mean(test_specificity_F) * 100;
tmp_balAccuracy_F = mean(test_balAccuracy_F) * 100;

results{3,13} = [num2str(mean(tmp_sensitivity_F), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_F), '%.02f'), ' [', num2str(min(tmp_sensitivity_F), '%.02f'), '-', num2str(max(tmp_sensitivity_F), '%.02f'), ']'];
results{3,14} = [num2str(mean(tmp_specificity_F), '%.02f'), ' ± ', num2str(std(tmp_specificity_F), '%.02f'), ' [', num2str(min(tmp_specificity_F), '%.02f'), '-', num2str(max(tmp_specificity_F), '%.02f'), ']'];
results{3,15} = [num2str(mean(tmp_balAccuracy_F), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_F), '%.02f'), ' [', num2str(min(tmp_balAccuracy_F), '%.02f'), '-', num2str(max(tmp_balAccuracy_F), '%.02f'), ']'];

% Permutation sensitivity, specificity, balanced accuracy - data1
tmp_sensitivity_1 = mean(perm_test_sensitivity_1) * 100;
tmp_specificity_1 = mean(perm_test_specificity_1) * 100;
tmp_balAccuracy_1 = mean(perm_test_balAccuracy_1) * 100;

results{1,16} = [num2str(mean(tmp_sensitivity_1), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_1), '%.02f'), ' [', num2str(min(tmp_sensitivity_1), '%.02f'), '-', num2str(max(tmp_sensitivity_1), '%.02f'), ']'];
results{1,17} = [num2str(mean(tmp_specificity_1), '%.02f'), ' ± ', num2str(std(tmp_specificity_1), '%.02f'), ' [', num2str(min(tmp_specificity_1), '%.02f'), '-', num2str(max(tmp_specificity_1), '%.02f'), ']'];
results{1,18} = [num2str(mean(tmp_balAccuracy_1), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_1), '%.02f'), ' [', num2str(min(tmp_balAccuracy_1), '%.02f'), '-', num2str(max(tmp_balAccuracy_1), '%.02f'), ']'];

% Permutation sensitivity, specificity, balanced accuracy - data2
tmp_sensitivity_2 = mean(perm_test_sensitivity_2) * 100;
tmp_specificity_2 = mean(perm_test_specificity_2) * 100;
tmp_balAccuracy_2 = mean(perm_test_balAccuracy_2) * 100;

results{2,16} = [num2str(mean(tmp_sensitivity_2), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_2), '%.02f'), ' [', num2str(min(tmp_sensitivity_2), '%.02f'), '-', num2str(max(tmp_sensitivity_2), '%.02f'), ']'];
results{2,17} = [num2str(mean(tmp_specificity_2), '%.02f'), ' ± ', num2str(std(tmp_specificity_2), '%.02f'), ' [', num2str(min(tmp_specificity_2), '%.02f'), '-', num2str(max(tmp_specificity_2), '%.02f'), ']'];
results{2,18} = [num2str(mean(tmp_balAccuracy_2), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_2), '%.02f'), ' [', num2str(min(tmp_balAccuracy_2), '%.02f'), '-', num2str(max(tmp_balAccuracy_2), '%.02f'), ']'];

% Permutation sensitivity, specificity, balanced accuracy - multimodal
tmp_sensitivity_F = mean(perm_test_sensitivity_F) * 100;
tmp_specificity_F = mean(perm_test_specificity_F) * 100;
tmp_balAccuracy_F = mean(perm_test_balAccuracy_F) * 100;

results{3,16} = [num2str(mean(tmp_sensitivity_F), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_F), '%.02f'), ' [', num2str(min(tmp_sensitivity_F), '%.02f'), '-', num2str(max(tmp_sensitivity_F), '%.02f'), ']'];
results{3,17} = [num2str(mean(tmp_specificity_F), '%.02f'), ' ± ', num2str(std(tmp_specificity_F), '%.02f'), ' [', num2str(min(tmp_specificity_F), '%.02f'), '-', num2str(max(tmp_specificity_F), '%.02f'), ']'];
results{3,18} = [num2str(mean(tmp_balAccuracy_F), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_F), '%.02f'), ' [', num2str(min(tmp_balAccuracy_F), '%.02f'), '-', num2str(max(tmp_balAccuracy_F), '%.02f'), ']'];
end

function results = compileResults_trimodal(toLoad, fullName, firstModality, secondModality, thirdModality)
% Initialize
varNames = {'ModelName', 'ModalityName', 'nCases', 'nControls', 'nTrainCases', 'nTrainControls', 'nTestCases', 'nTestControls', ...
            'TP', 'FP', 'TN', 'FN', 'Sensitivity', 'Specificity', 'BalAccuracy', 'PermSensitivity', 'PermSpecificity', 'PermBalAccuracy'};
results  = cell(4, length(varNames));

% Get data
load(toLoad, 'test_TP*', 'test_TN*', 'test_FP*', 'test_FN*', ...
             'test_sensitivity*', 'test_specificity*', 'test_balAccuracy*', ...
             'perm_test_sensitivity*', 'perm_test_specificity*', 'perm_test_balAccuracy*', ...
             'numOuterFolds', 'data1', 'loc*');

% Record basic information
results{1,1} = cellstr(fullName);
results{1,2} = cellstr(firstModality);
results{2,2} = cellstr(secondModality);
results{3,2} = cellstr(thirdModality);
results{4,2} = 'multimodal';

% Number of cases and controls - only record once
results{1,3} = sum(data1.caseStatus == 1);
results{1,4} = sum(data1.caseStatus == 0);

% Make one split
[trainIDX, testIDX] = makeCV(data1.ParentID, data1.caseStatus, numOuterFolds);

% How many cases and controls do we get (on average)?
train_numCases    = zeros(numOuterFolds, 1);
train_numControls = zeros(numOuterFolds, 1);
test_numCases     = zeros(numOuterFolds, 1);
test_numControls  = zeros(numOuterFolds, 1);
for folds = 1:numOuterFolds
    tmp_trainData               = data1(trainIDX{folds}, :);
    tmp_testData                = data1(testIDX{folds},  :);
    train_numCases(folds,1)     = sum(tmp_trainData.caseStatus == 1);
    train_numControls(folds,1)  = sum(tmp_trainData.caseStatus == 0);
    test_numCases(folds,1)      = sum(tmp_testData.caseStatus == 1);
    test_numControls(folds,1)   = sum(tmp_testData.caseStatus == 0);    
end

results{1,5}  = ceil(mean(train_numCases));
results{1,6}  = ceil(mean(train_numControls));
results{1,7}  = ceil(mean(test_numCases));
results{1,8}  = ceil(mean(test_numControls));

% TP, FP, TN, FN - data1
tmp_test_TP_1 = ceil(mean(test_TP_1));
tmp_test_TN_1 = ceil(mean(test_TN_1));
tmp_test_FP_1 = ceil(mean(test_FP_1));
tmp_test_FN_1 = ceil(mean(test_FN_1));

results{1,9}  = [num2str(ceil(mean(tmp_test_TP_1))), ' [', num2str(min(tmp_test_TP_1)), '-', num2str(max(tmp_test_TP_1)), ']'];
results{1,10} = [num2str(ceil(mean(tmp_test_FP_1))), ' [', num2str(min(tmp_test_FP_1)), '-', num2str(max(tmp_test_FP_1)), ']'];
results{1,11} = [num2str(ceil(mean(tmp_test_TN_1))), ' [', num2str(min(tmp_test_TN_1)), '-', num2str(max(tmp_test_TN_1)), ']'];
results{1,12} = [num2str(ceil(mean(tmp_test_FN_1))), ' [', num2str(min(tmp_test_FN_1)), '-', num2str(max(tmp_test_FN_1)), ']'];

% TP, FP, TN, FN - data2
tmp_test_TP_2 = ceil(mean(test_TP_2));
tmp_test_TN_2 = ceil(mean(test_TN_2));
tmp_test_FP_2 = ceil(mean(test_FP_2));
tmp_test_FN_2 = ceil(mean(test_FN_2));

results{2,9}  = [num2str(ceil(mean(tmp_test_TP_2))), ' [', num2str(min(tmp_test_TP_2)), '-', num2str(max(tmp_test_TP_2)), ']'];
results{2,10} = [num2str(ceil(mean(tmp_test_FP_2))), ' [', num2str(min(tmp_test_FP_2)), '-', num2str(max(tmp_test_FP_2)), ']'];
results{2,11} = [num2str(ceil(mean(tmp_test_TN_2))), ' [', num2str(min(tmp_test_TN_2)), '-', num2str(max(tmp_test_TN_2)), ']'];
results{2,12} = [num2str(ceil(mean(tmp_test_FN_2))), ' [', num2str(min(tmp_test_FN_2)), '-', num2str(max(tmp_test_FN_2)), ']'];

% TP, FP, TN, FN - data3
tmp_test_TP_3 = ceil(mean(test_TP_3));
tmp_test_TN_3 = ceil(mean(test_TN_3));
tmp_test_FP_3 = ceil(mean(test_FP_3));
tmp_test_FN_3 = ceil(mean(test_FN_3));

results{3,9}  = [num2str(ceil(mean(tmp_test_TP_3))), ' [', num2str(min(tmp_test_TP_3)), '-', num2str(max(tmp_test_TP_3)), ']'];
results{3,10} = [num2str(ceil(mean(tmp_test_FP_3))), ' [', num2str(min(tmp_test_FP_3)), '-', num2str(max(tmp_test_FP_3)), ']'];
results{3,11} = [num2str(ceil(mean(tmp_test_TN_3))), ' [', num2str(min(tmp_test_TN_3)), '-', num2str(max(tmp_test_TN_3)), ']'];
results{3,12} = [num2str(ceil(mean(tmp_test_FN_3))), ' [', num2str(min(tmp_test_FN_3)), '-', num2str(max(tmp_test_FN_3)), ']'];

% TP, FP, TN, FN - multimodal
% TP, FP, TN, FN - data2
tmp_test_TP_F = ceil(mean(test_TP_F));
tmp_test_TN_F = ceil(mean(test_TN_F));
tmp_test_FP_F = ceil(mean(test_FP_F));
tmp_test_FN_F = ceil(mean(test_FN_F));

results{4,9}  = [num2str(ceil(mean(tmp_test_TP_F))), ' [', num2str(min(tmp_test_TP_F)), '-', num2str(max(tmp_test_TP_F)), ']'];
results{4,10} = [num2str(ceil(mean(tmp_test_FP_F))), ' [', num2str(min(tmp_test_FP_F)), '-', num2str(max(tmp_test_FP_F)), ']'];
results{4,11} = [num2str(ceil(mean(tmp_test_TN_F))), ' [', num2str(min(tmp_test_TN_F)), '-', num2str(max(tmp_test_TN_F)), ']'];
results{4,12} = [num2str(ceil(mean(tmp_test_FN_F))), ' [', num2str(min(tmp_test_FN_F)), '-', num2str(max(tmp_test_FN_F)), ']'];

% Sensitivity, specificity, balanced accuracy - data1
tmp_sensitivity_1 = mean(test_sensitivity_1) * 100;
tmp_specificity_1 = mean(test_specificity_1) * 100;
tmp_balAccuracy_1 = mean(test_balAccuracy_1) * 100;

results{1,13} = [num2str(mean(tmp_sensitivity_1), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_1), '%.02f'), ' [', num2str(min(tmp_sensitivity_1), '%.02f'), '-', num2str(max(tmp_sensitivity_1), '%.02f'), ']'];
results{1,14} = [num2str(mean(tmp_specificity_1), '%.02f'), ' ± ', num2str(std(tmp_specificity_1), '%.02f'), ' [', num2str(min(tmp_specificity_1), '%.02f'), '-', num2str(max(tmp_specificity_1), '%.02f'), ']'];
results{1,15} = [num2str(mean(tmp_balAccuracy_1), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_1), '%.02f'), ' [', num2str(min(tmp_balAccuracy_1), '%.02f'), '-', num2str(max(tmp_balAccuracy_1), '%.02f'), ']'];

% Sensitivity, specificity, balanced accuracy - data2
tmp_sensitivity_2 = mean(test_sensitivity_2) * 100;
tmp_specificity_2 = mean(test_specificity_2) * 100;
tmp_balAccuracy_2 = mean(test_balAccuracy_2) * 100;

results{2,13} = [num2str(mean(tmp_sensitivity_2), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_2), '%.02f'), ' [', num2str(min(tmp_sensitivity_2), '%.02f'), '-', num2str(max(tmp_sensitivity_2), '%.02f'), ']'];
results{2,14} = [num2str(mean(tmp_specificity_2), '%.02f'), ' ± ', num2str(std(tmp_specificity_2), '%.02f'), ' [', num2str(min(tmp_specificity_2), '%.02f'), '-', num2str(max(tmp_specificity_2), '%.02f'), ']'];
results{2,15} = [num2str(mean(tmp_balAccuracy_2), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_2), '%.02f'), ' [', num2str(min(tmp_balAccuracy_2), '%.02f'), '-', num2str(max(tmp_balAccuracy_2), '%.02f'), ']'];

% Sensitivity, specificity, balanced accuracy - data3
tmp_sensitivity_3 = mean(test_sensitivity_3) * 100;
tmp_specificity_3 = mean(test_specificity_3) * 100;
tmp_balAccuracy_3 = mean(test_balAccuracy_3) * 100;

results{3,13} = [num2str(mean(tmp_sensitivity_3), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_3), '%.02f'), ' [', num2str(min(tmp_sensitivity_3), '%.02f'), '-', num2str(max(tmp_sensitivity_3), '%.02f'), ']'];
results{3,14} = [num2str(mean(tmp_specificity_3), '%.02f'), ' ± ', num2str(std(tmp_specificity_3), '%.02f'), ' [', num2str(min(tmp_specificity_3), '%.02f'), '-', num2str(max(tmp_specificity_3), '%.02f'), ']'];
results{3,15} = [num2str(mean(tmp_balAccuracy_3), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_3), '%.02f'), ' [', num2str(min(tmp_balAccuracy_3), '%.02f'), '-', num2str(max(tmp_balAccuracy_3), '%.02f'), ']'];

% Sensitivity, specificity, balanced accuracy - multimodal
tmp_sensitivity_F = mean(test_sensitivity_F) * 100;
tmp_specificity_F = mean(test_specificity_F) * 100;
tmp_balAccuracy_F = mean(test_balAccuracy_F) * 100;

results{4,13} = [num2str(mean(tmp_sensitivity_F), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_F), '%.02f'), ' [', num2str(min(tmp_sensitivity_F), '%.02f'), '-', num2str(max(tmp_sensitivity_F), '%.02f'), ']'];
results{4,14} = [num2str(mean(tmp_specificity_F), '%.02f'), ' ± ', num2str(std(tmp_specificity_F), '%.02f'), ' [', num2str(min(tmp_specificity_F), '%.02f'), '-', num2str(max(tmp_specificity_F), '%.02f'), ']'];
results{4,15} = [num2str(mean(tmp_balAccuracy_F), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_F), '%.02f'), ' [', num2str(min(tmp_balAccuracy_F), '%.02f'), '-', num2str(max(tmp_balAccuracy_F), '%.02f'), ']'];

% Permutation sensitivity, specificity, balanced accuracy - data1
tmp_sensitivity_1 = mean(perm_test_sensitivity_1) * 100;
tmp_specificity_1 = mean(perm_test_specificity_1) * 100;
tmp_balAccuracy_1 = mean(perm_test_balAccuracy_1) * 100;

results{1,16} = [num2str(mean(tmp_sensitivity_1), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_1), '%.02f'), ' [', num2str(min(tmp_sensitivity_1), '%.02f'), '-', num2str(max(tmp_sensitivity_1), '%.02f'), ']'];
results{1,17} = [num2str(mean(tmp_specificity_1), '%.02f'), ' ± ', num2str(std(tmp_specificity_1), '%.02f'), ' [', num2str(min(tmp_specificity_1), '%.02f'), '-', num2str(max(tmp_specificity_1), '%.02f'), ']'];
results{1,18} = [num2str(mean(tmp_balAccuracy_1), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_1), '%.02f'), ' [', num2str(min(tmp_balAccuracy_1), '%.02f'), '-', num2str(max(tmp_balAccuracy_1), '%.02f'), ']'];

% Permutation sensitivity, specificity, balanced accuracy - data2
tmp_sensitivity_2 = mean(perm_test_sensitivity_2) * 100;
tmp_specificity_2 = mean(perm_test_specificity_2) * 100;
tmp_balAccuracy_2 = mean(perm_test_balAccuracy_2) * 100;

results{2,16} = [num2str(mean(tmp_sensitivity_2), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_2), '%.02f'), ' [', num2str(min(tmp_sensitivity_2), '%.02f'), '-', num2str(max(tmp_sensitivity_2), '%.02f'), ']'];
results{2,17} = [num2str(mean(tmp_specificity_2), '%.02f'), ' ± ', num2str(std(tmp_specificity_2), '%.02f'), ' [', num2str(min(tmp_specificity_2), '%.02f'), '-', num2str(max(tmp_specificity_2), '%.02f'), ']'];
results{2,18} = [num2str(mean(tmp_balAccuracy_2), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_2), '%.02f'), ' [', num2str(min(tmp_balAccuracy_2), '%.02f'), '-', num2str(max(tmp_balAccuracy_2), '%.02f'), ']'];

% Permutation sensitivity, specificity, balanced accuracy - data3
tmp_sensitivity_3 = mean(perm_test_sensitivity_3) * 100;
tmp_specificity_3 = mean(perm_test_specificity_3) * 100;
tmp_balAccuracy_3 = mean(perm_test_balAccuracy_3) * 100;

results{3,16} = [num2str(mean(tmp_sensitivity_3), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_3), '%.02f'), ' [', num2str(min(tmp_sensitivity_3), '%.02f'), '-', num2str(max(tmp_sensitivity_3), '%.02f'), ']'];
results{3,17} = [num2str(mean(tmp_specificity_3), '%.02f'), ' ± ', num2str(std(tmp_specificity_3), '%.02f'), ' [', num2str(min(tmp_specificity_3), '%.02f'), '-', num2str(max(tmp_specificity_3), '%.02f'), ']'];
results{3,18} = [num2str(mean(tmp_balAccuracy_3), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_3), '%.02f'), ' [', num2str(min(tmp_balAccuracy_3), '%.02f'), '-', num2str(max(tmp_balAccuracy_3), '%.02f'), ']'];

% Permutation sensitivity, specificity, balanced accuracy - multimodal
tmp_sensitivity_F = mean(perm_test_sensitivity_F) * 100;
tmp_specificity_F = mean(perm_test_specificity_F) * 100;
tmp_balAccuracy_F = mean(perm_test_balAccuracy_F) * 100;

results{4,16} = [num2str(mean(tmp_sensitivity_F), '%.02f'), ' ± ', num2str(std(tmp_sensitivity_F), '%.02f'), ' [', num2str(min(tmp_sensitivity_F), '%.02f'), '-', num2str(max(tmp_sensitivity_F), '%.02f'), ']'];
results{4,17} = [num2str(mean(tmp_specificity_F), '%.02f'), ' ± ', num2str(std(tmp_specificity_F), '%.02f'), ' [', num2str(min(tmp_specificity_F), '%.02f'), '-', num2str(max(tmp_specificity_F), '%.02f'), ']'];
results{4,18} = [num2str(mean(tmp_balAccuracy_F), '%.02f'), ' ± ', num2str(std(tmp_balAccuracy_F), '%.02f'), ' [', num2str(min(tmp_balAccuracy_F), '%.02f'), '-', num2str(max(tmp_balAccuracy_F), '%.02f'), ']'];
end