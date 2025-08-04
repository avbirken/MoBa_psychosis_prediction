%% Split holdout data into two parts: 40% and 60%
%% Settings
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
outDir  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';

%% Get all IDs
allIDs = readtable(fullfile(outDir, 'IDList_ParentID.csv'));

%% Read list of holdout subjects
holdoutSet = readtable(fullfile(outDir, 'HoldoutSample.csv'), 'Delimiter', '\t');

%% Append parent ID to holy grail
[a, b]              = ismember(holdoutSet.ID_2445, allIDs.ID_2445);
holdoutSet.ParentID  = allIDs.parentID(b);

%% Read info on case status
toRead   = 'any_ICD_or_ICPC_psychosis.csv';
dataCase = readtable(fullfile(workDir, toRead));
[a, b]   = ismember(dataCase.ID_2445, allIDs.ID_2445);
dataCase = dataCase(a,:);

%% Append case status to holdout
[a, b]                = ismember(holdoutSet.ID_2445, dataCase.ID_2445);
holdoutSet.caseStatus = dataCase.any_psychosis_ICD_or_ICPC(b);

%% Partitioning into 40-60
seed = 20240817;
frac = 0.40;
[trainIDX, holdoutIDX] = makeHoldout(holdoutSet.ParentID, holdoutSet.caseStatus, frac, seed);

%% Create subsets
holdout_workSet  = holdoutSet(trainIDX,  :);
holdout_external = holdoutSet(holdoutIDX,:);

%% Save
save(fullfile(outDir, 'holdout_workSet.mat'),   'holdout_workSet');
save(fullfile(outDir, 'holdout_external.mat'),  'holdout_external');