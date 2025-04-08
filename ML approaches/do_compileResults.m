%% Get datasets
sourceDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
% sourceDir = 'Z:\cluster\users\parekh\2024-11-11_predictionPsychosis_VB\work';
load(fullfile(sourceDir, 'CAPE.mat'));
load(fullfile(sourceDir, 'Q14.mat'));
load(fullfile(sourceDir, 'Genetics.mat'));
load(fullfile(sourceDir, 'NPR.mat'));
load(fullfile(sourceDir, 'MBRN.mat'));

%% All RUSBoost
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/analysis_RUS';
% workDir = 'Z:\cluster\users\parekh\2024-11-11_predictionPsychosis_VB\work\analysis_RUS';

% RUSBoost - CAPE
results = compileResults(fullfile(workDir, 'Results_RUS_CAPE.mat'), CAPE, 'CAPE', 'RUSBoost');

% RUSBoost - Q14
results = [results; compileResults(fullfile(workDir, 'Results_RUS_Q14.mat'), Q14, 'Q14', 'RUSBoost')];

% RUSBoost - Genetics
results = [results; compileResults(fullfile(workDir, 'Results_RUS_Genetics_SCZ.mat'), Genetics, 'Genetics', 'RUSBoost')];

% RUSBoost - NPR
results = [results; compileResults(fullfile(workDir, 'Results_RUS_NPR.mat'), NPR, 'NPR', 'RUSBoost')];

% RUSBoost - MBRN
results = [results; compileResults(fullfile(workDir, 'Results_RUS_MBRN.mat'), MBRN, 'MBRN', 'RUSBoost')];

%% All SVM - opt cost bal acc
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/analysis_SVM_balAcc';
% workDir = 'Z:\cluster\users\parekh\2024-11-11_predictionPsychosis_VB\work\analysis_SVM_balAcc';

% SVM - CAPE
results = [results; compileResults(fullfile(workDir, 'Results_SVM_balAcc_CAPE.mat'), CAPE, 'CAPE', 'SVM')];

% SVM - Q14
results = [results; compileResults(fullfile(workDir, 'Results_SVM_balAcc_Q14.mat'), Q14, 'Q14', 'SVM')];

% SVM - Genetics
results = [results; compileResults(fullfile(workDir, 'Results_SVM_balAcc_Genetics_SCZ.mat'), Genetics, 'Genetics', 'SVM')];

% SVM - NPR
results = [results; compileResults(fullfile(workDir, 'Results_SVM_balAcc_NPR.mat'), NPR, 'NPR', 'SVM')];

% SVM - MBRN
results = [results; compileResults(fullfile(workDir, 'Results_SVM_balAcc_MBRN.mat'), MBRN, 'MBRN', 'SVM')];

%% All SMOTE
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/analysis_SMOTE_SVM';
% workDir = 'Z:\cluster\users\parekh\2024-11-11_predictionPsychosis_VB\work\analysis_SMOTE_SVM';

% SMOTE - CAPE
results = [results; compileResults(fullfile(workDir, 'Results_SMOTE_SVM_CAPE.mat'), CAPE, 'CAPE', 'SMOTE')];

% SMOTE - Q14
results = [results; compileResults(fullfile(workDir, 'Results_SMOTE_SVM_Q14.mat'), Q14, 'Q14', 'SMOTE')];

% SMOTE - Genetics
results = [results; compileResults(fullfile(workDir, 'Results_SMOTE_SVM_Genetics_SCZ.mat'), Genetics, 'Genetics', 'SMOTE')];

% SMOTE - NPR
results = [results; compileResults(fullfile(workDir, 'Results_SMOTE_SVM_NPR.mat'), NPR, 'NPR', 'SMOTE')];

% SMOTE - MBRN
results = [results; compileResults(fullfile(workDir, 'Results_SMOTE_SVM_MBRN.mat'), MBRN, 'MBRN', 'SMOTE')];

%% Make table
varNames = {'Features', 'Classifier', 'nCases', 'nControls', 'nTrainCases', 'nTrainControls', 'nTestCases', 'nTestControls', ...
            'TP', 'FP', 'TN', 'FN', 'Sensitivity', 'Specificity', 'BalAccuracy', 'PermSensitivity', 'PermSpecificity', 'PermBalAccuracy'};
results  = cell2table(results, 'VariableNames', varNames);

%% Write out
writetable(results, '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/2025-02-06_summary_results_unimodal.csv');
% writetable(results, 'Z:\cluster\users\parekh\2024-11-11_predictionPsychosis_VB\work\summary_results_unimodal.csv', 'Delimiter', '\t');

%%
% writetable(results, 'Z:\cluster\users\parekh\2024-11-11_predictionPsychosis_VB\work\summary_results_unimodal.xlsx');