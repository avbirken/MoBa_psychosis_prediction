%% Compile results for plotting
dirWork  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
dirRUS   = 'analysis_RUS';
dirSVM   = 'analysis_SVM_balAcc';
dirSMOTE = 'analysis_SMOTE_SVM';

% Results should be organized as:
% sensitivity_RUS
% specificity_RUS
% balAccuracy_RUS
% where each of these are arrays with the rows being repeats (50) and
% columns being models (5)
% Similarly, permutation version
% Scales to three classifiers
% Order of results: CAPE, Q14, Genetics, NPR, MBRN

%% RUS
tmp_RUS_CAPE = load(fullfile(dirWork, dirRUS, 'Results_RUS_CAPE.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                       'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                       'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                       'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_RUS_Q14 = load(fullfile(dirWork, dirRUS, 'Results_RUS_Q14.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                     'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                     'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                     'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_RUS_Genetics = load(fullfile(dirWork, dirRUS, 'Results_RUS_Genetics_SCZ.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                   'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                   'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                   'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_RUS_NPR = load(fullfile(dirWork, dirRUS, 'Results_RUS_NPR.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                     'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                     'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                     'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_RUS_MBRN = load(fullfile(dirWork, dirRUS, 'Results_RUS_MBRN.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                       'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                       'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                       'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

%% SVM
tmp_SVM_balAcc_CAPE = load(fullfile(dirWork, dirSVM, 'Results_SVM_balAcc_CAPE.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                     'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                     'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                     'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SVM_balAcc_Q14 = load(fullfile(dirWork, dirSVM, 'Results_SVM_balAcc_Q14.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                   'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                   'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                   'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SVM_balAcc_Genetics = load(fullfile(dirWork, dirSVM, 'Results_SVM_balAcc_Genetics_SCZ.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                                 'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                                 'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                                 'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SVM_balAcc_NPR = load(fullfile(dirWork, dirSVM, 'Results_SVM_balAcc_NPR.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                   'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                   'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                   'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SVM_balAcc_MBRN = load(fullfile(dirWork, dirSVM, 'Results_SVM_balAcc_MBRN.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                     'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                     'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                     'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

%% SMOTE
tmp_SMOTE_SVM_CAPE = load(fullfile(dirWork, dirSMOTE, 'Results_SMOTE_SVM_CAPE.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                     'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                     'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                     'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SMOTE_SVM_Q14 = load(fullfile(dirWork, dirSMOTE, 'Results_SMOTE_SVM_Q14.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                   'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                   'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                   'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SMOTE_SVM_Genetics = load(fullfile(dirWork, dirSMOTE, 'Results_SMOTE_SVM_Genetics_SCZ.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                                 'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                                 'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                                 'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SMOTE_SVM_NPR = load(fullfile(dirWork, dirSMOTE, 'Results_SMOTE_SVM_NPR.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                   'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                   'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                   'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

tmp_SMOTE_SVM_MBRN = load(fullfile(dirWork, dirSMOTE, 'Results_SMOTE_SVM_MBRN.mat'), 'perm_mean_testSensitivity',  'perm_mean_testSpecificity',  'perm_mean_testBalAccuracy',  ...
                                                                                     'perm_mean_trainSensitivity', 'perm_mean_trainSpecificity', 'perm_mean_trainBalAccuracy', ...
                                                                                     'mean_trainSensitivity',      'mean_trainSpecificity',      'mean_trainBalAccuracy',      ...
                                                                                     'mean_testSensitivity',       'mean_testSpecificity',       'mean_testBalAccuracy');

%% Put RUS results together
% CAPE, Q14, Genetics, NPR, MBRN
train_sensitivity_RUS = [tmp_RUS_CAPE.mean_trainSensitivity, tmp_RUS_Q14.mean_trainSensitivity, tmp_RUS_Genetics.mean_trainSensitivity, tmp_RUS_NPR.mean_trainSensitivity, tmp_RUS_MBRN.mean_trainSensitivity];
train_specificity_RUS = [tmp_RUS_CAPE.mean_trainSpecificity, tmp_RUS_Q14.mean_trainSpecificity, tmp_RUS_Genetics.mean_trainSpecificity, tmp_RUS_NPR.mean_trainSpecificity, tmp_RUS_MBRN.mean_trainSpecificity];
train_balAccuracy_RUS = [tmp_RUS_CAPE.mean_trainBalAccuracy, tmp_RUS_Q14.mean_trainBalAccuracy, tmp_RUS_Genetics.mean_trainBalAccuracy, tmp_RUS_NPR.mean_trainBalAccuracy, tmp_RUS_MBRN.mean_trainBalAccuracy];

test_sensitivity_RUS = [tmp_RUS_CAPE.mean_testSensitivity, tmp_RUS_Q14.mean_testSensitivity, tmp_RUS_Genetics.mean_testSensitivity, tmp_RUS_NPR.mean_testSensitivity, tmp_RUS_MBRN.mean_testSensitivity];
test_specificity_RUS = [tmp_RUS_CAPE.mean_testSpecificity, tmp_RUS_Q14.mean_testSpecificity, tmp_RUS_Genetics.mean_testSpecificity, tmp_RUS_NPR.mean_testSpecificity, tmp_RUS_MBRN.mean_testSpecificity];
test_balAccuracy_RUS = [tmp_RUS_CAPE.mean_testBalAccuracy, tmp_RUS_Q14.mean_testBalAccuracy, tmp_RUS_Genetics.mean_testBalAccuracy, tmp_RUS_NPR.mean_testBalAccuracy, tmp_RUS_MBRN.mean_testBalAccuracy];

perm_train_sensitivity_RUS = [tmp_RUS_CAPE.perm_mean_trainSensitivity, tmp_RUS_Q14.perm_mean_trainSensitivity, tmp_RUS_Genetics.perm_mean_trainSensitivity, tmp_RUS_NPR.perm_mean_trainSensitivity, tmp_RUS_MBRN.perm_mean_trainSensitivity];
perm_train_specificity_RUS = [tmp_RUS_CAPE.perm_mean_trainSpecificity, tmp_RUS_Q14.perm_mean_trainSpecificity, tmp_RUS_Genetics.perm_mean_trainSpecificity, tmp_RUS_NPR.perm_mean_trainSpecificity, tmp_RUS_MBRN.perm_mean_trainSpecificity];
perm_train_balAccuracy_RUS = [tmp_RUS_CAPE.perm_mean_trainBalAccuracy, tmp_RUS_Q14.perm_mean_trainBalAccuracy, tmp_RUS_Genetics.perm_mean_trainBalAccuracy, tmp_RUS_NPR.perm_mean_trainBalAccuracy, tmp_RUS_MBRN.perm_mean_trainBalAccuracy];

perm_test_sensitivity_RUS = [tmp_RUS_CAPE.perm_mean_testSensitivity, tmp_RUS_Q14.perm_mean_testSensitivity, tmp_RUS_Genetics.perm_mean_testSensitivity, tmp_RUS_NPR.perm_mean_testSensitivity, tmp_RUS_MBRN.perm_mean_testSensitivity];
perm_test_specificity_RUS = [tmp_RUS_CAPE.perm_mean_testSpecificity, tmp_RUS_Q14.perm_mean_testSpecificity, tmp_RUS_Genetics.perm_mean_testSpecificity, tmp_RUS_NPR.perm_mean_testSpecificity, tmp_RUS_MBRN.perm_mean_testSpecificity];
perm_test_balAccuracy_RUS = [tmp_RUS_CAPE.perm_mean_testBalAccuracy, tmp_RUS_Q14.perm_mean_testBalAccuracy, tmp_RUS_Genetics.perm_mean_testBalAccuracy, tmp_RUS_NPR.perm_mean_testBalAccuracy, tmp_RUS_MBRN.perm_mean_testBalAccuracy];

%% Put SVM_balAcc results together
% CAPE, Q14, Genetics, NPR, MBRN
train_sensitivity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.mean_trainSensitivity, tmp_SVM_balAcc_Q14.mean_trainSensitivity, tmp_SVM_balAcc_Genetics.mean_trainSensitivity, tmp_SVM_balAcc_NPR.mean_trainSensitivity, tmp_SVM_balAcc_MBRN.mean_trainSensitivity];
train_specificity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.mean_trainSpecificity, tmp_SVM_balAcc_Q14.mean_trainSpecificity, tmp_SVM_balAcc_Genetics.mean_trainSpecificity, tmp_SVM_balAcc_NPR.mean_trainSpecificity, tmp_SVM_balAcc_MBRN.mean_trainSpecificity];
train_balAccuracy_SVM_balAcc = [tmp_SVM_balAcc_CAPE.mean_trainBalAccuracy, tmp_SVM_balAcc_Q14.mean_trainBalAccuracy, tmp_SVM_balAcc_Genetics.mean_trainBalAccuracy, tmp_SVM_balAcc_NPR.mean_trainBalAccuracy, tmp_SVM_balAcc_MBRN.mean_trainBalAccuracy];

test_sensitivity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.mean_testSensitivity, tmp_SVM_balAcc_Q14.mean_testSensitivity, tmp_SVM_balAcc_Genetics.mean_testSensitivity, tmp_SVM_balAcc_NPR.mean_testSensitivity, tmp_SVM_balAcc_MBRN.mean_testSensitivity];
test_specificity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.mean_testSpecificity, tmp_SVM_balAcc_Q14.mean_testSpecificity, tmp_SVM_balAcc_Genetics.mean_testSpecificity, tmp_SVM_balAcc_NPR.mean_testSpecificity, tmp_SVM_balAcc_MBRN.mean_testSpecificity];
test_balAccuracy_SVM_balAcc = [tmp_SVM_balAcc_CAPE.mean_testBalAccuracy, tmp_SVM_balAcc_Q14.mean_testBalAccuracy, tmp_SVM_balAcc_Genetics.mean_testBalAccuracy, tmp_SVM_balAcc_NPR.mean_testBalAccuracy, tmp_SVM_balAcc_MBRN.mean_testBalAccuracy];

perm_train_sensitivity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.perm_mean_trainSensitivity, tmp_SVM_balAcc_Q14.perm_mean_trainSensitivity, tmp_SVM_balAcc_Genetics.perm_mean_trainSensitivity, tmp_SVM_balAcc_NPR.perm_mean_trainSensitivity, tmp_SVM_balAcc_MBRN.perm_mean_trainSensitivity];
perm_train_specificity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.perm_mean_trainSpecificity, tmp_SVM_balAcc_Q14.perm_mean_trainSpecificity, tmp_SVM_balAcc_Genetics.perm_mean_trainSpecificity, tmp_SVM_balAcc_NPR.perm_mean_trainSpecificity, tmp_SVM_balAcc_MBRN.perm_mean_trainSpecificity];
perm_train_balAccuracy_SVM_balAcc = [tmp_SVM_balAcc_CAPE.perm_mean_trainBalAccuracy, tmp_SVM_balAcc_Q14.perm_mean_trainBalAccuracy, tmp_SVM_balAcc_Genetics.perm_mean_trainBalAccuracy, tmp_SVM_balAcc_NPR.perm_mean_trainBalAccuracy, tmp_SVM_balAcc_MBRN.perm_mean_trainBalAccuracy];

perm_test_sensitivity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.perm_mean_testSensitivity, tmp_SVM_balAcc_Q14.perm_mean_testSensitivity, tmp_SVM_balAcc_Genetics.perm_mean_testSensitivity, tmp_SVM_balAcc_NPR.perm_mean_testSensitivity, tmp_SVM_balAcc_MBRN.perm_mean_testSensitivity];
perm_test_specificity_SVM_balAcc = [tmp_SVM_balAcc_CAPE.perm_mean_testSpecificity, tmp_SVM_balAcc_Q14.perm_mean_testSpecificity, tmp_SVM_balAcc_Genetics.perm_mean_testSpecificity, tmp_SVM_balAcc_NPR.perm_mean_testSpecificity, tmp_SVM_balAcc_MBRN.perm_mean_testSpecificity];
perm_test_balAccuracy_SVM_balAcc = [tmp_SVM_balAcc_CAPE.perm_mean_testBalAccuracy, tmp_SVM_balAcc_Q14.perm_mean_testBalAccuracy, tmp_SVM_balAcc_Genetics.perm_mean_testBalAccuracy, tmp_SVM_balAcc_NPR.perm_mean_testBalAccuracy, tmp_SVM_balAcc_MBRN.perm_mean_testBalAccuracy];

%% Put SMOTE_SVM results together
% CAPE, Q14, Genetics, NPR, MBRN
train_sensitivity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.mean_trainSensitivity, tmp_SMOTE_SVM_Q14.mean_trainSensitivity, tmp_SMOTE_SVM_Genetics.mean_trainSensitivity, tmp_SMOTE_SVM_NPR.mean_trainSensitivity, tmp_SMOTE_SVM_MBRN.mean_trainSensitivity];
train_specificity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.mean_trainSpecificity, tmp_SMOTE_SVM_Q14.mean_trainSpecificity, tmp_SMOTE_SVM_Genetics.mean_trainSpecificity, tmp_SMOTE_SVM_NPR.mean_trainSpecificity, tmp_SMOTE_SVM_MBRN.mean_trainSpecificity];
train_balAccuracy_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.mean_trainBalAccuracy, tmp_SMOTE_SVM_Q14.mean_trainBalAccuracy, tmp_SMOTE_SVM_Genetics.mean_trainBalAccuracy, tmp_SMOTE_SVM_NPR.mean_trainBalAccuracy, tmp_SMOTE_SVM_MBRN.mean_trainBalAccuracy];

test_sensitivity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.mean_testSensitivity, tmp_SMOTE_SVM_Q14.mean_testSensitivity, tmp_SMOTE_SVM_Genetics.mean_testSensitivity, tmp_SMOTE_SVM_NPR.mean_testSensitivity, tmp_SMOTE_SVM_MBRN.mean_testSensitivity];
test_specificity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.mean_testSpecificity, tmp_SMOTE_SVM_Q14.mean_testSpecificity, tmp_SMOTE_SVM_Genetics.mean_testSpecificity, tmp_SMOTE_SVM_NPR.mean_testSpecificity, tmp_SMOTE_SVM_MBRN.mean_testSpecificity];
test_balAccuracy_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.mean_testBalAccuracy, tmp_SMOTE_SVM_Q14.mean_testBalAccuracy, tmp_SMOTE_SVM_Genetics.mean_testBalAccuracy, tmp_SMOTE_SVM_NPR.mean_testBalAccuracy, tmp_SMOTE_SVM_MBRN.mean_testBalAccuracy];

perm_train_sensitivity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.perm_mean_trainSensitivity, tmp_SMOTE_SVM_Q14.perm_mean_trainSensitivity, tmp_SMOTE_SVM_Genetics.perm_mean_trainSensitivity, tmp_SMOTE_SVM_NPR.perm_mean_trainSensitivity, tmp_SMOTE_SVM_MBRN.perm_mean_trainSensitivity];
perm_train_specificity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.perm_mean_trainSpecificity, tmp_SMOTE_SVM_Q14.perm_mean_trainSpecificity, tmp_SMOTE_SVM_Genetics.perm_mean_trainSpecificity, tmp_SMOTE_SVM_NPR.perm_mean_trainSpecificity, tmp_SMOTE_SVM_MBRN.perm_mean_trainSpecificity];
perm_train_balAccuracy_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.perm_mean_trainBalAccuracy, tmp_SMOTE_SVM_Q14.perm_mean_trainBalAccuracy, tmp_SMOTE_SVM_Genetics.perm_mean_trainBalAccuracy, tmp_SMOTE_SVM_NPR.perm_mean_trainBalAccuracy, tmp_SMOTE_SVM_MBRN.perm_mean_trainBalAccuracy];

perm_test_sensitivity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.perm_mean_testSensitivity, tmp_SMOTE_SVM_Q14.perm_mean_testSensitivity, tmp_SMOTE_SVM_Genetics.perm_mean_testSensitivity, tmp_SMOTE_SVM_NPR.perm_mean_testSensitivity, tmp_SMOTE_SVM_MBRN.perm_mean_testSensitivity];
perm_test_specificity_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.perm_mean_testSpecificity, tmp_SMOTE_SVM_Q14.perm_mean_testSpecificity, tmp_SMOTE_SVM_Genetics.perm_mean_testSpecificity, tmp_SMOTE_SVM_NPR.perm_mean_testSpecificity, tmp_SMOTE_SVM_MBRN.perm_mean_testSpecificity];
perm_test_balAccuracy_SMOTE_SVM = [tmp_SMOTE_SVM_CAPE.perm_mean_testBalAccuracy, tmp_SMOTE_SVM_Q14.perm_mean_testBalAccuracy, tmp_SMOTE_SVM_Genetics.perm_mean_testBalAccuracy, tmp_SMOTE_SVM_NPR.perm_mean_testBalAccuracy, tmp_SMOTE_SVM_MBRN.perm_mean_testBalAccuracy];

%% Clear up
clear tmp* dir*

%% Save
save('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/2025-02-06_compiledMLResults_unimodal.mat');