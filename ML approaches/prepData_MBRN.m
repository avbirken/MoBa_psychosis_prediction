%% Prepare MBRN and birth factors data for ML
%% Settings
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
toRead  = 'pre_perinatal_predictors.csv';
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

%% Remove variables that are not necessary
toRemove = {'any_F2_NPR_or_KUHR', 'any_psychosis_ICD_or_ICPC', 'FAAR'};
data(:, ismember(data.Properties.VariableNames, toRemove)) = [];

%% Re-order variables
data = movevars(data, 'ParentID',   'After', 'ID_2445');
data = movevars(data, 'caseStatus', 'After', 'ParentID');

%% Head circumference is the only variable with a handful of fractions - round
data.head_circumfrence = round(data.head_circumfrence,0);

%% There are a few outlier values for head circmference, remove them
locs = data.head_circumfrence < 20 | data.head_circumfrence > 40;
data(locs,:) = [];

%% Separate out sex information
infoSex = data(:,1:4);

%% Remove sex information from MBRN
data(:, ismember(data.Properties.VariableNames, 'sex')) = [];

%% Rename and save
MBRN = data;
save(fullfile(outDir, 'MBRN.mat'), 'MBRN');
save(fullfile(outDir, 'sexInfo_MBRN.mat'), 'infoSex');