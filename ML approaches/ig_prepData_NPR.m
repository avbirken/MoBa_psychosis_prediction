%% Prepare NPR data for ML
%% Settings
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
toRead  = 'diagnostic_predictors.csv';
outDir  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';

%% Get all IDs
allIDs = readtable(fullfile(outDir, 'IDList_ParentID.csv'));

%% Get data
data     = readtable(fullfile(workDir, toRead));
[a, b]   = ismember(data.ID_2445, allIDs.ID_2445);
data     = data(a,:);

%% Ensure same ordering etc.
allIDs  = allIDs(ismember(allIDs.ID_2445, data.ID_2445), :);
[~, b]  = ismember(data.ID_2445, allIDs.ID_2445);
allIDs  = allIDs(b, :);

%% Append parent ID to data
data.ParentID = allIDs.parentID;

%% Create case status variable
data.caseStatus = data.any_psychosis_ICD_or_ICPC;

%% Delete any_F2_NPR_or_KUHR 
data.any_F2_NPR_or_KUHR = [];
data.any_psychosis_ICD_or_ICPC = [];

%% Re-order some variables
data = movevars(data, 'ParentID', 'After', 'ID_2445');
data = movevars(data, 'caseStatus', 'After', 'ParentID');

%% Read list of holdout subjects - external set
load(fullfile(outDir, 'holdout_external.mat'));

%% Remove these subjects
% Make sure that anyone with the same parent ID goes to holdout
locs          = ismember(data.ID_2445,  holdout_external.ID_2445);
addLocs       = ismember(data.ParentID, data.ParentID(locs));
NPR_holdout   = data(addLocs,      :);
NPR_workSet   = data(not(addLocs), :);

%% Save
save(fullfile(outDir, 'NPR_holdout.mat'), 'NPR_holdout');
save(fullfile(outDir, 'NPR_workSet.mat'), 'NPR_workSet');