%% Prepare Q14 data for ML
%% Settings
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
toRead  = 'Q14_adolescent_predictors.csv';
outDir  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';

%% Get all IDs
allIDs = readtable(fullfile(outDir, 'IDList_ParentID_cutoffInfo_withFollowupData.csv'));

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
data.caseStatus = allIDs.caseStatus;

%% Delete year of response (not a predictor) and any_F2_NPR_or_KUHR 
data.year_of_response   = [];
data.any_F2_NPR_or_KUHR = [];
data.any_psychosis_ICD_or_ICPC = [];

%% Re-order variables
data = movevars(data, 'ParentID',   'After', 'ID_2445');
data = movevars(data, 'caseStatus', 'After', 'ParentID');

% %% Add sex as a variable - select from MBRN
% load(fullfile(outDir, 'sexInfo_MBRN.mat'));
% load(fullfile(outDir, 'NPR.mat'));
% [a, b] = ismember(NPR.ID_2445, data.ID_2445);
% NPR = NPR(a,:);
% 
% % Ensure same ordering
% if sum(strcmpi(data.ID_2445, NPR.ID_2445)) ~= height(data)
%     error('Misaligned data');
% end
% 
% data.sex = NPR.sex;

% %% Reorder sex
% Q14 = movevars(data, 'sex', 'After', 'caseStatus');

%% Save
Q14 = data;
save(fullfile(outDir, 'Q14.mat'), 'Q14');