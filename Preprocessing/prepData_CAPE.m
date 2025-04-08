%% Prepare CAPE for ML
%% Settings
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
toRead  = 'cape_9_complete_cases.csv';
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

%% Remove age and any_F2_NPR_or_KUHR
% data.any_F2_NPR_or_KUHR = [];
data.any_psychosis_ICD_or_ICPC = [];

%% Re-order variables
data = movevars(data, 'ParentID',   'After', 'ID_2445');
data = movevars(data, 'caseStatus', 'After', 'ParentID');

%% CAPE variables need to be expanded
varsFreq = {'UB252', 'UB254', 'UB256', 'UB258', 'UB260', 'UB262', 'UB264', 'UB266', 'UB268'};

varsDist = {'UB253', 'UB255', 'UB257', 'UB259', 'UB261', 'UB263', 'UB265', 'UB267', 'UB269'};

% Create interaction variables between frequency and distress
newNames = {'FD252', 'FD254', 'FD256', 'FD258', 'FD260', 'FD262', 'FD264', 'FD266', 'FD268'};
for vars = 1:length(newNames)
    data.(newNames{vars}) = data{:,varsDist{vars}} .* data{:, varsFreq{vars}};
end

%% Rename for saving
CAPE = data;

%% Save
save(fullfile(outDir, 'CAPE.mat'), 'CAPE');